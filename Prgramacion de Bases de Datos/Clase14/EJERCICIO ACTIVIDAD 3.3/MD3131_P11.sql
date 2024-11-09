create or replace procedure pl(
    cadena varchar2
) as
begin
    dbms_output.put_line(cadena);
end;

--caso1

select p.pac_run, p.dv_run,
        p.pnombre||' '||p.snombre||' '||p.apaterno||' '||p.amaterno pac_nombre,
        a.ate_id, pa.fecha_venc_pago, pa.fecha_pago,
        round(pa.fecha_pago-pa.fecha_venc_pago) dias_atraso,
        a.costo
from paciente p join atencion a on p.pac_run=a.pac_run
    join pago_atencion pa on a.ate_id=pa.ate_id
where to_char(pa.fecha_pago, 'yyyy')=to_char(sysdate, 'yyyy')-1 and round(pa.fecha_pago-pa.fecha_venc_pago)>0
order by pa.fecha_venc_pago, p.apaterno;

/

create or replace function fn_nom_esp(
    p_ate_id number
) return varchar2
as
    v_nom_esp varchar2(20);
begin
    select e.nombre
    into v_nom_esp
    from atencion a join medico m on a.med_run=m.med_run
        join especialidad e on m.esp_id=e.esp_id
    where a.ate_id=p_ate_id;
    return v_nom_esp;
end fn_nom_esp;

/

create or replace package pkg_multas as
    v_valor_multa number;
    v_valor_dscto number;
    function fn_dscto_edad(p_edad number, p_valor_multa number) return number;
end pkg_multas;

create or replace package body pkg_multas as
    function fn_dscto_edad(
        p_edad number, p_valor_multa number
    ) return number
    as
        v_dscto number;
        v_pct_dscto number;
    begin
        select porcentaje_descto/100
        into v_pct_dscto
        from PORC_DESCTO_3RA_EDAD
        where p_edad between anno_ini and anno_ter;
        v_dscto:=p_valor_multa*v_pct_dscto;
        return v_dscto;
    end fn_dscto_edad;
end pkg_multas;

create or replace procedure sp_info_atemed(
    p_anno_proc number
)
as
    cursor c_info(p_anno number) is
    select p.pac_run, p.dv_run,
        p.pnombre||' '||p.snombre||' '||p.apaterno||' '||p.amaterno pac_nombre,
        p.fecha_nacimiento nac,a.ate_id, pa.fecha_venc_pago, pa.fecha_pago,
        round(pa.fecha_pago-pa.fecha_venc_pago) dias_atraso,
        a.costo
    from paciente p join atencion a on p.pac_run=a.pac_run
        join pago_atencion pa on a.ate_id=pa.ate_id
    where to_char(pa.fecha_pago, 'yyyy')=p_anno-1 and round(pa.fecha_pago-pa.fecha_venc_pago)>0
    order by pa.fecha_venc_pago, p.apaterno;
    
    type t_multas is varray(7) of number;
    v_multas t_multas:=t_multas(1200,1300,1700,1900,1100,2000,2300);
    
    v_multa number;
    v_edad number;
    v_obs varchar2(100):=null;
    
begin
    execute immediate 'truncate table PAGO_MOROSO';
    for r_info in c_info(p_anno_proc) loop
    
        v_obs:=null;
    
        v_multa:=r_info.dias_atraso*case
                                        when fn_nom_esp(r_info.ate_id) = 'Medicina General' 
                                            then v_multas(1)
                                        when fn_nom_esp(r_info.ate_id) ='Traumatologia' 
                                            then v_multas(2)
                                        when fn_nom_esp(r_info.ate_id) in ('Neurologia','Pediatria')
                                            then v_multas(3)
                                        when fn_nom_esp(r_info.ate_id)= 'Oftalmologia'
                                            then v_multas(4)
                                        when fn_nom_esp(r_info.ate_id)='Geriatria'
                                            then v_multas(5)
                                        when fn_nom_esp(r_info.ate_id) in ('Ginecologia','Gastroenterologia')
                                            then v_multas(6)
                                        when fn_nom_esp(r_info.ate_id)='Dermatologia'
                                            then v_multas(7)
                                        else 0
                                    end;
        
        v_edad:=round(months_between(sysdate, r_info.nac)/12);
        
        if v_edad > 70 then
            v_multa:=v_multa-pkg_multas.fn_dscto_edad(v_edad, v_multa);
            v_obs:='Paciente tenía '||v_edad||' a la fecha de atención. Se aplicó descuento paciente mayor a 70 años';
        end if;
        
        pl(r_info.pac_run
        ||' '||r_info.dv_run
        ||' '||r_info.pac_nombre
        ||' '||r_info.ate_id
        ||' '||r_info.fecha_venc_pago
        ||' '||r_info.fecha_pago
        ||' '||r_info.dias_atraso
        ||' '||fn_nom_esp(r_info.ate_id)
        ||' '||r_info.costo
        ||' '||v_multa
        ||' '||v_obs);
        
        insert into PAGO_MOROSO
        values (
            r_info.pac_run
        ,r_info.dv_run
        ,r_info.pac_nombre
        ,r_info.ate_id
        ,r_info.fecha_venc_pago
        ,r_info.fecha_pago
        ,r_info.dias_atraso
        ,fn_nom_esp(r_info.ate_id)
        ,r_info.costo
        ,v_multa
        ,v_obs
        );
    end loop;
end sp_info_atemed;
/
exec sp_info_atemed(2023);

/

--caso 2

create or replace procedure sp_tbl_resumen(
    p_tbl RESUMEN_ATENMEDICAS_MENSUALES%rowtype
)as
begin
    insert into RESUMEN_ATENMEDICAS_MENSUALES
    values p_tbl;
    commit;
end sp_tbl_resumen;

/

create or replace function fn_unidad(
    p_medrun number
)return varchar2
as
    v_unidad UNIDAD.nombre%type;
begin
    select u.nombre
    into v_unidad
    from medico m join unidad u on m.uni_id=u.uni_id
    where m.med_run=p_medrun;
    return v_unidad;
end fn_unidad;

/

create or replace function fn_especialidad(
    p_medrun number
)return varchar2
as
    v_esp ESPECIALIDAD.nombre%type;
begin
    select e.nombre
    into v_esp
    from medico m join especialidad e on m.esp_id=e.esp_id
    where m.med_run=p_medrun;
    return v_esp;
end fn_especialidad;

/

create or replace function fn_paciente(
    p_pacienterun number
)return varchar2
as
    v_nompac varchar(90);
begin
    select pnombre||' '||snombre||' '||apaterno||' '||amaterno
    into v_nompac
    from paciente
    where pac_run=p_pacienterun;
    return v_nompac;
end fn_paciente;

/

create or replace function fn_salud_paciente(
    p_pacienterun number
)return varchar2
as
    v_tipo_sal TIPO_SALUD.descripcion%type;
begin
    select ts.descripcion
    into v_tipo_sal
    from paciente p join salud s on p.sal_id=s.sal_id
        join tipo_salud ts on s.tipo_sal_id=ts.tipo_sal_id
    where p.pac_run=p_pacienterun;
    return v_tipo_sal;
end fn_salud_paciente;

/

create or replace function fn_sistema_salud(
    p_pacienterun number
)return varchar2
as
    v_sist_sal SALUD.descripcion%type;
begin
    select s.descripcion
    into v_sist_sal
    from paciente p join salud s on p.sal_id=s.sal_id
    where p.pac_run=p_pacienterun;
    return v_sist_sal;
end fn_sistema_salud;

/

create or replace package pkg_porcentajes as
    v_valor_real number;
    v_descuento number;
    procedure sp_captura_error(p_msg varchar2,p_correlativo number,p_desc varchar2);
    function fn_obt_porc_descto_3ra_edad(p_edad number,p_pacrun number)return number;
    function fn_valor_real(p_edad number, p_pacrun number, p_costo number, p_salud varchar2)return number;
end pkg_porcentajes;

/

create or replace package body pkg_porcentajes as
    procedure sp_captura_error(
        p_msg varchar2,p_correlativo number,p_desc varchar2
    )as
    begin
        insert into ERRORES_PROCESO
        values(
            p_correlativo,
            p_desc,
            p_msg
        );
        commit;
    end sp_captura_error;
    
    function fn_obt_porc_descto_3ra_edad(
        p_edad number,p_pacrun number
    )return number
    as
        v_pct_3ra_edad number;
        v_msg varchar2(500);
        v_desc varchar2(500);
        v_correlativo number;
    begin
        if p_edad > 60 then
            begin
                select PORCENTAJE_DESCTO / 100
                into v_pct_3ra_edad
                from PORC_DESCTO_3RA_EDAD
                where p_edad between anno_ini and anno_ter;
            return v_pct_3ra_edad;
            exception
                when too_many_rows then
                    v_pct_3ra_edad := 0;
                    v_msg := sqlerrm;
                    v_desc:='Error en FN_OBT_PORC_DESCTO_3RA_EDAD al obtener el porc.descto con '||p_edad||' a�os para el paciente '||p_pacrun;
                    v_correlativo := MDY3131_P11.SEQ_ERROR.nextval;
                    sp_captura_error(v_msg, v_correlativo, v_desc);
                    return v_pct_3ra_edad;
            end;
        else v_pct_3ra_edad:=0;
        end if;
        return v_pct_3ra_edad;
    end fn_obt_porc_descto_3ra_edad;
    
    function fn_valor_real(
        p_edad number, p_pacrun number, p_costo number, p_salud varchar2
    )return number
    as
        v_pct_costo number;
        v_pago_real number;
    begin
        select costo_pago/100
        into v_pct_costo
        from salud
        where descripcion=p_salud;
        v_pago_real:=round(p_costo*v_pct_costo*(1-fn_obt_porc_descto_3ra_edad(p_edad, p_pacrun)));
        return v_pago_real;
    end fn_valor_real;
    
end pkg_porcentajes;

/

create or replace procedure sp_atemeds(
    p_anno_proc number
)
as
    cursor c_resumen is
    select to_char(fecha_atencion, 'MM/YYYY') fecha
    from atencion
    where to_char(fecha_atencion, 'YYYY')=p_anno_proc-1
    group by to_char(fecha_atencion, 'MM/YYYY')
    order by to_char(fecha_atencion, 'MM/YYYY');
    
    cursor c_detalle(p_fecha varchar2) is
    select a.ate_id, a.fecha_atencion, a.hr_atencion, a.med_run,a.pac_run,
        m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno nombre,
        a.costo,p.fecha_nacimiento, m.car_id
    from atencion a join medico m on a.med_run=m.med_run
        join paciente p on a.pac_run=p.pac_run
    where to_char(a.fecha_atencion, 'mm/yyyy')=p_fecha
    order by a.fecha_atencion, a.hr_atencion;
    
    v_cont number:=0;
    
    --varaibles escalares
    
    v_apagar number;
    v_cargo CARGO.NOMBRE%type;
    v_edad number;
    v_tbl RESUMEN_ATENMEDICAS_MENSUALES%rowtype;
    v_diferencia number;
begin
    execute immediate 'truncate table DETALLE_ATENMEDICAS_MENSUALES';
    execute immediate 'truncate table RESUMEN_ATENMEDICAS_MENSUALES';
    execute immediate 'truncate table ERRORES_PROCESO';
    execute immediate 'drop sequence MDY3131_P11.SEQ_ERROR';
    execute immediate 'create sequence MDY3131_P11.SEQ_ERROR';
    
    for r_resumen in c_resumen loop
        
        v_tbl.TOTAL_ATEN_UNID_AMBUL:=0;
        v_tbl.TOTAL_ATEN_UNID_URGEN:=0;
        v_tbl.TOTAL_ATEN_UNID_PACRITICO:=0;
        v_tbl.TOTAL_ATEN_UNID_ADULTO:=0;
        v_tbl.TOTAL_ATEN_UNID_INFANTIL:=0;
        v_tbl.TOTAL_ATEN_UNID_MATERNIDAD:=0;
        v_tbl.TOTAL_ATEN_UNID_CIRUGIA:=0;
        v_tbl.TOTAL_ATEN_UNID_CIRUGIA_PLAST:=0;
        v_tbl.TOTAL_ATEN_UNID_SOBREP_OBES:=0;
        
        for r_detalle in c_detalle(r_resumen.fecha) loop
            v_cont:=v_cont+1;
            
            select valor_a_pagar
            into v_apagar
            from pago_atencion
            where ate_id=r_detalle.ate_id;
            
            select nombre
            into v_cargo
            from cargo
            where car_id=r_detalle.car_id;
            
            v_edad:=round(months_between(sysdate, r_detalle.fecha_nacimiento)/12);
            
            v_diferencia:=v_apagar-pkg_porcentajes.fn_valor_real(v_edad,r_detalle.pac_run, r_detalle.costo,fn_sistema_salud(r_detalle.pac_run));
            
            pl(v_cont
            ||' '||r_resumen.fecha
            ||' '||r_detalle.ate_id
            ||' '||r_detalle.fecha_atencion
            ||' '||r_detalle.hr_atencion
            ||' '||fn_unidad(r_detalle.med_run)
            ||' '||fn_especialidad(r_detalle.med_run)
            ||' '||r_detalle.nombre
            ||' '||v_cargo
            ||' '||fn_paciente(r_detalle.pac_run)
            ||' '||fn_salud_paciente(r_detalle.pac_run)
            ||' '||fn_sistema_salud(r_detalle.pac_run)
            ||' '||r_detalle.costo
            ||' '||v_apagar
            ||' '||pkg_porcentajes.fn_valor_real(v_edad,r_detalle.pac_run, r_detalle.costo,fn_sistema_salud(r_detalle.pac_run))
            ||' '||v_diferencia);
            
            insert into DETALLE_ATENMEDICAS_MENSUALES
            values (
                r_resumen.fecha
                ,r_detalle.ate_id
                ,r_detalle.fecha_atencion
                ,r_detalle.hr_atencion
                ,fn_unidad(r_detalle.med_run)
                ,fn_especialidad(r_detalle.med_run)
                ,r_detalle.nombre
                ,v_cargo
                ,fn_paciente(r_detalle.pac_run)
                ,fn_salud_paciente(r_detalle.pac_run)
                ,fn_sistema_salud(r_detalle.pac_run)
                ,r_detalle.costo
                ,v_apagar
                ,pkg_porcentajes.fn_valor_real(v_edad,r_detalle.pac_run, r_detalle.costo,fn_sistema_salud(r_detalle.pac_run))
                ,v_diferencia
            );
            
            v_tbl.MES_ANNO_ATENCION:=r_resumen.fecha;
            if fn_unidad(r_detalle.med_run)='Atencion Ambulatoria' then
                v_tbl.TOTAL_ATEN_UNID_AMBUL:=v_tbl.TOTAL_ATEN_UNID_AMBUL+1;
            elsif fn_unidad(r_detalle.med_run)='Atencion Urgencia' then
                 v_tbl.TOTAL_ATEN_UNID_URGEN:=v_tbl.TOTAL_ATEN_UNID_URGEN+1;
            elsif fn_unidad(r_detalle.med_run)='Paciente Critico' then
                v_tbl.TOTAL_ATEN_UNID_PACRITICO:=v_tbl.TOTAL_ATEN_UNID_PACRITICO+1;
            elsif fn_unidad(r_detalle.med_run)='Atencion Adulto' then
                v_tbl.TOTAL_ATEN_UNID_ADULTO:=v_tbl.TOTAL_ATEN_UNID_ADULTO+1;
            elsif fn_unidad(r_detalle.med_run)='Atencion Infantil' then
                v_tbl.TOTAL_ATEN_UNID_INFANTIL:=v_tbl.TOTAL_ATEN_UNID_INFANTIL+1;
            elsif fn_unidad(r_detalle.med_run)='Maternidad' then
                v_tbl.TOTAL_ATEN_UNID_MATERNIDAD:=v_tbl.TOTAL_ATEN_UNID_MATERNIDAD+1;
            elsif fn_unidad(r_detalle.med_run)='Cirugia' then
                v_tbl.TOTAL_ATEN_UNID_CIRUGIA:=v_tbl.TOTAL_ATEN_UNID_CIRUGIA+1;
            elsif fn_unidad(r_detalle.med_run)='Cirugia Plastica' then
                v_tbl.TOTAL_ATEN_UNID_CIRUGIA_PLAST:=v_tbl.TOTAL_ATEN_UNID_CIRUGIA_PLAST+1;
            elsif fn_unidad(r_detalle.med_run)='Sobrepreso y Obesidad' then
                v_tbl.TOTAL_ATEN_UNID_SOBREP_OBES:=v_tbl.TOTAL_ATEN_UNID_SOBREP_OBES+1;
            end if;
            v_tbl.FECHA_GRABACION:=sysdate;
        end loop;
        sp_tbl_resumen(v_tbl);
    end loop;
end sp_atemeds;
/
exec sp_atemeds(2023);
/

