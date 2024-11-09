create or replace procedure pl(
    cadena varchar2
) as
begin
    dbms_output.put_line(cadena);
end;
/

/********************PROCEDIMIENTO INSERTAR TABLA*****************************/
create or replace procedure sp_insert(
    p_tbl PAGO_MENSUAL_CREDITO%rowtype
)as
begin
    insert into PAGO_MENSUAL_CREDITO
    values p_tbl;
end sp_insert;

/
/******************** FUNCION ULTIMA CUOTA*****************************/
create or replace function fn_ultima_cuota(
    p_nrosol number
)return date
as
    v_fecha date;
begin
    select max(FECHA_VENC_CUOTA)
    into v_fecha
    from CUOTA_CREDITO_SOCIO
    where NRO_SOLIC_CREDITO=p_nrosol;
    return v_fecha;
end fn_ultima_cuota;
/
/******************** FUNCION DEVOLUCION*****************************/
create or replace function fn_devolucion(
    p_codev number,p_run number, p_nrosol number
)return number
as
    v_monto number;
    v_subrut varchar(400);
    v_msg varchar2(400);
begin
    select MONTO_DEVOLUCION
    into v_monto
    from DEVOLUCION_PROGRAMADA
    where COD_DEVOLUCION=p_codev;
    return v_monto;
exception
    when others then
        v_subrut:='Error en la funcion '||$$PLSQL_UNIT||' al obtener el monto de devolucion del codigo Nro. '||p_codev;
        v_msg:=sqlerrm;
        pkg_constructores.sp_captura_error(p_run, p_nrosol, v_subrut, v_msg);
        return 0;
end fn_devolucion;

/
/******************** FUNCION PAGO MES ANTERIOR *****************************/
create or replace function fn_saldo_mes_anterior(
    p_fecha date, p_nrosol number
)return number
as
begin
    select SALDO_POR_PAGAR
    into pkg_constructores.v_monto_mes_anterior
    from CUOTA_CREDITO_SOCIO
    where FECHA_VENC_CUOTA=p_fecha and NRO_SOLIC_CREDITO=p_nrosol;
    return pkg_constructores.v_monto_mes_anterior;
end fn_saldo_mes_anterior;
/
/******************** FUNCION RECUPERA COMUNA *****************************/
create or replace function fn_comuna(
    p_codcomuna number,p_codprovincia number, p_codregion number
)return varchar2
as
    v_comuna varchar2(20);
    v_sql varchar2(400);
begin
    v_sql:='
        select NOMBRE_COMUNA
        from COMUNA
        where COD_COMUNA=:1 and COD_PROVINCIA=:2 and COD_REGION=:3
    ';
    execute immediate v_sql into v_comuna using p_codcomuna, p_codprovincia, p_codregion;
    return v_comuna;
end fn_comuna;

/
/******************** FUNCION RECUPERA PROVINCIA *****************************/
create or replace function fn_provincia(
    p_codprovincia number, p_codregion number
)return varchar2
as
    v_provincia varchar2(20);
    v_sql varchar2(400);
begin
    v_sql:='
        select NOMBRE_PROVINCIA
        from PROVINCIA
        where COD_PROVINCIA=:1 and COD_REGION=:2
    ';
    execute immediate v_sql into v_provincia using p_codprovincia, p_codregion;
    return v_provincia;
end fn_provincia;

/

/******************** PACKAGE CONTRUNCTORES *****************************/
create or replace package pkg_constructores as
    v_multa number;
    v_monto_mes_anterior number;
    v_dias_de_atraso number;
    procedure sp_captura_error(p_run number, p_nrosocio number, p_subrut varchar2, p_msg varchar2);
    function fn_dias_atraso(p_fecha date, p_nrosol number)return number;
    function fn_getmulta(p_dias_atraso number, p_monto number, p_run number, p_nrosol number)return number;
end pkg_constructores;
/

create or replace package body pkg_constructores as
    procedure sp_captura_error(
        p_run number, p_nrosocio number, p_subrut varchar2, p_msg varchar2
    )as
        v_sql varchar2(400);
    begin
        v_sql:='
            insert into ERROR_PROCESO
            values(:1,:2,:3,:4)
        ';
        execute immediate v_sql using p_run, p_nrosocio, p_subrut, p_msg;
    end sp_captura_error;
    
    function fn_dias_atraso(
        p_fecha date, p_nrosol number
    )return number
    as
        v_sql varchar2(400);
    begin
        v_sql:='
            select FECHA_PAGO_CUOTA-FECHA_VENC_CUOTA
            from CUOTA_CREDITO_SOCIO
            where FECHA_VENC_CUOTA=:1 and NRO_SOLIC_CREDITO=:2
        ';
        execute immediate v_sql into v_dias_de_atraso using p_fecha, p_nrosol;
        if v_dias_de_atraso <=0 then
            v_dias_de_atraso:=0;
        end if;
        return v_dias_de_atraso;
    end fn_dias_atraso;
    
    function fn_getmulta(
        p_dias_atraso number, p_monto number,p_run number, p_nrosol number
    )return number
    as
        v_subrut varchar(400);
        v_msg varchar2(400);
    begin
        if p_dias_atraso>0 then        
            select round(p_monto*PORC_MULTA/100)
            into v_multa
            from MULTA_MORA
            where p_dias_atraso between TRAMO_DIA_MIN_ATRASO and TRAMO_DIA_MAX_ATRASO;
        else v_multa:=0;
        end if;
        return v_multa;
    exception
        when others then
            v_subrut:='Error en la funcion '||$$PLSQL_UNIT||' al obtener el porcentaje de multa por '||p_dias_atraso||' dias de atraso';
            v_msg:=sqlerrm;
            sp_captura_error(p_run, p_nrosol, v_subrut, v_msg);
            return 0;
    end fn_getmulta;
end pkg_constructores;

/

/******************** PROCEDIMIENTO PRINCIPAL *****************************/
create or replace procedure sp_principal(
    p_fecha varchar2
)as
    cursor c_det is
    select ccs.fecha_venc_cuota, s.nro_socio, s.numrun,s.dvrun,
            s.direccion, s.cod_provincia, s.cod_comuna, s.cod_region, cs.nro_solic_credito,
            c.nombre_credito, cs.monto_total_credito, cs.total_cuotas_credito, ccs.nro_cuota,
            ccs.valor_cuota, s.fecha_nacimiento, cs.cod_devolucion
    from socio s join credito_socio cs on s.nro_socio=cs.nro_socio
        join cuota_credito_socio ccs on cs.NRO_SOLIC_CREDITO=ccs.NRO_SOLIC_CREDITO
        join credito c on cs.cod_credito=c.cod_credito
    where to_char(ccs.fecha_venc_cuota, 'mmyyyy')=p_fecha
    order by ccs.fecha_venc_cuota,s.nro_socio;
    
    v_cont number:=0;
    v_fecha_anterior date;
    v_dias_atraso number;
    v_edad number;
    
    v_tbl PAGO_MENSUAL_CREDITO%rowtype;
begin
    execute immediate 'truncate table ERROR_PROCESO';
    execute immediate 'truncate table PAGO_MENSUAL_CREDITO';
    execute immediate 'truncate table STATUS_SOCIO';
    
    for r_det in c_det loop
        v_cont:=v_cont+1;
        
        v_tbl.fecha_proceso:=to_char(r_det.fecha_venc_cuota, 'mm/yyyy');
        v_tbl.nro_socio:=r_det.nro_socio;
        v_tbl.run_socio:=r_det.numrun||'-'||r_det.dvrun;
        v_tbl.direccion_socio:=r_det.direccion||' '||
                                fn_provincia(r_det.cod_provincia, r_det.cod_region)
                                ||', '||fn_comuna(r_det.cod_comuna, r_det.cod_provincia, r_det.cod_region);
        v_tbl.nro_solic_credito:=r_det.nro_solic_credito;
        v_tbl.tipo_credito:=r_det.nombre_credito;
        v_tbl.monto_total_credito:=r_det.monto_total_credito;
        v_tbl.nro_total_cuotas:=r_det.total_cuotas_credito;
        v_tbl.nro_cuota_mes:=r_det.nro_cuota;
        v_tbl.valor_cuota_mes:=r_det.valor_cuota;
        v_tbl.fecha_venc_cuota_mes:=r_det.fecha_venc_cuota;
        
        v_fecha_anterior:=add_months(r_det.fecha_venc_cuota,-1);
        
        v_tbl.saldo_pago_mes_ant:=fn_saldo_mes_anterior(v_fecha_anterior, r_det.nro_solic_credito);
        v_tbl.dias_atraso_pago_mes_ant:=pkg_constructores.fn_dias_atraso(v_fecha_anterior, r_det.nro_solic_credito);
        
        v_dias_atraso:=v_tbl.dias_atraso_pago_mes_ant;
        
        v_tbl.multa_atraso_pago_mes_ant:=pkg_constructores.fn_getmulta(v_dias_atraso,r_det.monto_total_credito,r_det.numrun, r_det.nro_solic_credito);
        
        v_edad:=round(months_between(sysdate, r_det.fecha_nacimiento)/12);
        
        if v_edad >=65 and v_tbl.saldo_pago_mes_ant=0 and v_dias_atraso=0 then
            v_tbl.valor_rebaja_65_annos:=round(r_det.valor_cuota*0.05);
        else v_tbl.valor_rebaja_65_annos:=0;
        end if;
        
        if r_det.cod_devolucion is not null then
            v_tbl.monto_devolucion:=fn_devolucion(r_det.cod_devolucion,r_det.numrun, r_det.nro_solic_credito);
        else v_tbl.monto_devolucion:=0;
        end if;
        
        v_tbl.valor_total_cuota_mes:=v_tbl.valor_cuota_mes+v_tbl.saldo_pago_mes_ant
                            +v_tbl.multa_atraso_pago_mes_ant-v_tbl.valor_rebaja_65_annos
                            -v_tbl.monto_devolucion;
                            
        v_tbl.fecha_venc_ult_cuota:=fn_ultima_cuota(r_det.nro_solic_credito);
    
        sp_insert(v_tbl);
    end loop;
end sp_principal;

/
/******************** TRIGGER *****************************/

create or replace trigger tr_status
after insert or update or delete on PAGO_MENSUAL_CREDITO
for each row
declare
    v_monto_atrasado number;
    v_estado varchar2(50);
begin
    v_monto_atrasado:=:new.SALDO_PAGO_MES_ANT+:new.MULTA_ATRASO_PAGO_MES_ANT;
    if inserting then
        if v_monto_atrasado <> 0 then
            v_estado:='SOCIO CON MORA';
        else v_estado:='SOCIO AL DIA';
        end if;
    end if;
    insert into STATUS_SOCIO
    values (:new.NRO_SOCIO, substr(:new.RUN_SOCIO, 1, 8), v_monto_atrasado, v_estado);
end tr_status;

/
/******************** EJECUCION PROCEDIMIENTO PRINCIPAL *****************************/
begin
    sp_principal('052023');
    execute immediate 'drop sequence SEQ_ERROR';
    execute immediate 'create sequence SEQ_ERROR minvalue 1 maxvalue 9999999999 increment by 1';
end;

/

select to_char(ccs.fecha_venc_cuota, 'mm/yyyy') fecha, s.nro_socio, s.numrun||'-'||s.dvrun run,
            s.direccion, s.cod_provincia, s.cod_comuna, s.cod_region, cs.nro_solic_credito,
            c.nombre_credito, cs.monto_total_credito, cs.total_cuotas_credito, ccs.nro_cuota,
            ccs.valor_cuota,ccs.fecha_venc_cuota, ccs.saldo_por_pagar, add_months(ccs.fecha_venc_cuota,-1)
    from socio s join credito_socio cs on s.nro_socio=cs.nro_socio
        join cuota_credito_socio ccs on cs.NRO_SOLIC_CREDITO=ccs.NRO_SOLIC_CREDITO
        join credito c on cs.cod_credito=c.cod_credito
    where to_char(ccs.fecha_venc_cuota, 'mmyyyy')='052023'
    order by ccs.fecha_venc_cuota,s.nro_socio;
/
