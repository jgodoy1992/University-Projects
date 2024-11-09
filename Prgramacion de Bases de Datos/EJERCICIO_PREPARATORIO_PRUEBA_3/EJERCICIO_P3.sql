create or replace procedure pl(
    cadena varchar2
) as
begin
    dbms_output.put_line(cadena);
end;

/
/*********** fucnion para el id de movilizacion ************/

create or replace function fn_retorno_com(
    p_codcomuna number
)return number
as
    v_idmov number;
begin
    select indmovilidad
    into v_idmov
    from comuna
    where codcomuna=p_codcomuna;
    return v_idmov;
end fn_retorno_com;

/
/*********** fucnion asignacion antiguedad ************/
create or replace function fn_antig(
    p_antig number, p_ventas number
)return number
as
    v_pct_antig number;
    v_sql varchar2(400);
    v_correlativo number;
    v_subrut varchar(400);
    v_msgerr varchar2(400);
begin
   v_sql:='
        select PORC_ANTIGUEDAD/100
        from PORC_ANTIGUEDAD_EMPLEADO
        where :1 between ANNOS_ANTIGUEDAD_INF and ANNOS_ANTIGUEDAD_SUP
        ';
        execute immediate v_sql into v_pct_antig using p_antig;  
    return round(p_ventas*v_pct_antig);
exception
    when others then
        v_correlativo:=seq_error.nextval;
        v_subrut:='Error en la fucnión '||$$PLSQL_UNIT||' al recuperar el porcentaje asociado a '||p_antig||' años de antiguedad';
        v_msgerr:=sqlerrm;
        pkg_constructores.sp_captura_error(v_correlativo,v_subrut,v_msgerr);
        return 0;        
end fn_antig;

/
/*********** testeo fucnion antiguedad ************/
exec pl(fn_antig(7,2237605));
exec pl(fn_antig(18,2378200));
exec pl(fn_antig(15,1652370));

/
/*********** pkg de constructores y procedimiento caprtura error ************/
create or replace package pkg_constructores as
    v_monto_ventas number;
    procedure sp_captura_error(p_correlativo number, p_subrut varchar2, p_msgerr varchar2);
    function fn_total_ventas( p_runemp varchar2, p_fecha varchar2)return number;
end pkg_constructores;

/

create or replace package body pkg_constructores as
    procedure sp_captura_error(
        p_correlativo number, p_subrut varchar2, p_msgerr varchar2
    )as
        v_sql varchar2(400);
    begin
        v_sql:='
            insert into ERROR_CALC
            values(:1,:2,:3)
        ';
        execute immediate v_sql using p_correlativo, p_subrut, p_msgerr;
    end sp_captura_error;
    
    function fn_total_ventas(
        p_runemp varchar2, p_fecha varchar2
    )return number
    as
    begin
        select sum(db.totallinea)
        into v_monto_ventas
        from boleta b join detalle_boleta db on b.numboleta=db.numboleta
        where b.run_empleado=p_runemp and to_char(b.fecha, 'mmyyyy')=p_fecha;
        return v_monto_ventas;
    end fn_total_ventas;
end pkg_constructores;

/
/*********** procedimiento principal ************/
create or replace procedure sp_principal(
    p_fecha varchar2, p_mov number, p_colacion number,p_pct_salud number
)as
    cursor c_detalle is
    select e.run_empleado, e.paterno||' '||e.materno||' '||e.nombre nombre,
        e.sueldo_base,e.fecha_contrato, e.codcomuna, e.codafp
    from empleado e join boleta b on e.run_empleado=b.run_empleado
    where to_char(b.fecha, 'mmyyyy')=p_fecha
    group by e.run_empleado, e.paterno,e.materno,e.nombre,
        e.sueldo_base,e.fecha_contrato, e.codcomuna, e.codafp
    order by e.paterno;
    
    v_tbl DETALLE_PAGO_MENSUAL%rowtype;
    
    v_annos_antig number;
    v_tot_ventas number;
    v_pct_ventas number;
    v_pct_afp number;
    v_sql varchar2(400);
    v_haberes number;
begin
    
    execute immediate 'truncate table DETALLE_PAGO_MENSUAL';
    execute immediate 'truncate table ERROR_CALC';
    execute immediate 'truncate table CALIFICACION_MENSUAL_EMPLEADO';
    
    for r_detalle in c_detalle loop
        
        v_tbl.mes:=substr(p_fecha, 2,1);
        v_tbl.anno:=substr(p_fecha, 3);
        v_tbl.run_empleado:=r_detalle.run_empleado;
        v_tbl.nombre_empleado:=r_detalle.nombre;
        v_tbl.sueldo_base:=r_detalle.sueldo_base;
        v_tbl.asig_colacion:=p_colacion;
        
        
        v_tbl.asig_movilizacion:=p_mov+round(r_detalle.sueldo_base*case fn_retorno_com(r_detalle.codcomuna)
                                                when 10 then 0.1
                                                when 20 then 0.12
                                                when 30 then 0.14
                                                else 0.15
                                            end);
                                            
        v_annos_antig:=round(substr(p_fecha,3)-to_char(r_detalle.fecha_contrato, 'yyyy'));
        --v_annos_antig:=round(months_between(sysdate, r_detalle.fecha_contrato)/12);
        
        v_tbl.asig_especial:=fn_antig(v_annos_antig,pkg_constructores.fn_total_ventas(r_detalle.run_empleado, p_fecha));
        
        v_tot_ventas:=pkg_constructores.fn_total_ventas(r_detalle.run_empleado, p_fecha);
        
        select PORC_COMISION/100
        into v_pct_ventas
        from PORCENTAJE_COMISION_VENTA
        where v_tot_ventas between VENTA_INF and VENTA_SUP;
        
        v_tbl.comision_ventas:=round(v_tot_ventas*v_pct_ventas);
        
        select PORCAFP/100
        into v_pct_afp
        from PREVISION_AFP
        where CODAFP = r_detalle.codafp;
        
        v_tbl.sueldo_imponible:=r_detalle.sueldo_base+v_tbl.asig_colacion+v_tbl.asig_movilizacion+v_tbl.asig_especial+v_tbl.comision_ventas;
        
        v_tbl.total_descuentos:=round(v_tbl.sueldo_imponible*v_pct_afp)+round(v_tbl.sueldo_imponible*p_pct_salud);
        
        v_tbl.sueldo_liquido:=v_tbl.sueldo_imponible-v_tbl.total_descuentos;
        
        pl(
            v_tbl.mes
            ||' '||v_tbl.anno
            ||' '||v_tbl.run_empleado
            ||' '||v_tbl.nombre_empleado
            ||' '||v_tbl.sueldo_base
            ||' '||v_tbl.asig_colacion
            ||' '||v_tbl.asig_movilizacion
            ||' '||v_tbl.asig_especial
            ||' '||v_tbl.comision_ventas
            ||' '||v_tbl.sueldo_imponible
            ||' '||v_tbl.total_descuentos
            ||' '||v_tbl.sueldo_liquido
            );
            
            v_sql:='
                insert into DETALLE_PAGO_MENSUAL
                values(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)
            ';
            execute immediate v_sql using v_tbl.mes,v_tbl.anno,v_tbl.run_empleado,v_tbl.nombre_empleado
                                    ,v_tbl.sueldo_base
                                    ,v_tbl.asig_colacion
                                    ,v_tbl.asig_movilizacion
                                    ,v_tbl.asig_especial
                                    ,v_tbl.comision_ventas
                                    ,v_tbl.sueldo_imponible
                                    ,v_tbl.total_descuentos
                                    ,v_tbl.sueldo_liquido;
    end loop;
end sp_principal;

/
create or replace trigger tr_calificacion
after insert or update or delete on DETALLE_PAGO_MENSUAL
for each row
declare 
    v_haberes number;
    v_califica varchar2(100);
begin
    v_haberes:=:new.sueldo_liquido;
    --v_haberes:=:new.ASIG_COLACION+:new.ASIG_MOVILIZACION+:new.ASIG_ESPECIAL+:new.COMISION_VENTAS;
    if inserting then
        v_califica:=case
                    when v_haberes between 400000 and 700000 then 
                        'Empleado con Salario menor al Promedio'
                    when v_haberes between 700001 and 900000 then
                        'Empleado con Salario Promedio'
                    when v_haberes > 900000 then
                        'Empleado con Salario Sobre el Promedio'
                end;
    end if;
    insert into CALIFICACION_MENSUAL_EMPLEADO
    values(:new.mes, :new.anno, :new.run_empleado,v_haberes, v_califica);
end tr_calificacion;
/

begin
    sp_principal('042021', 60000, 75000, 7/100);
    execute immediate 'drop sequence SEQ_ERROR';
    execute immediate 'create sequence SEQ_ERROR minvalue 1 maxvalue 9999999999 increment by 1';
end;
/
 select e.run_empleado, e.paterno||' '||e.materno||' '||e.nombre nombre,
        e.sueldo_base, sum(db.totallinea) total
from empleado e join boleta b on e.run_empleado=b.run_empleado
    join detalle_boleta db on b.numboleta=db.numboleta
where to_char(b.fecha, 'mmyyyy')='042021'
group by e.run_empleado, e.paterno,e.materno,e.nombre,
        e.sueldo_base
order by e.paterno;
/