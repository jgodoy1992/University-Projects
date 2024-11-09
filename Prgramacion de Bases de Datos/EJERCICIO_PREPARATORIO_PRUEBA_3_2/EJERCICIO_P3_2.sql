ALTER SESSION DISABLE PARALLEL DML;
ALTER SESSION DISABLE PARALLEL DDL;
ALTER SESSION DISABLE PARALLEL query;
/

create or replace procedure pl(
    cadena varchar2
) as
begin
    dbms_output.put_line(cadena);
end;

/

create or replace function fn_consumos(
    p_idhuesp number
)return number
as
    v_tot_consumo number;
    v_sql varchar2(400);
    v_subrut varchar2(400);
    v_msgerr varchar2(400);
begin
    v_sql:='
        select monto_consumos
        from total_consumos
        where id_huesped=:1
    ';
    execute immediate v_sql into v_tot_consumo using p_idhuesp;
    return v_tot_consumo;
exception
    when no_data_found then
        v_subrut:='Error en la función '||$$PLSQL_UNIT||' al recuperar los consumos del huesped con id '||p_idhuesp;
        v_msgerr:=sqlerrm;
        pkg_constructores.sp_captura_error(SQ_ERROR.nextval, v_subrut, v_msgerr);
        return 0;
end fn_consumos;

/

create or replace package pkg_constructores as
    v_monto_tours number;
    function fn_tours(p_idhuesp number)return number;
    procedure sp_captura_error(p_iderr number, p_subrut varchar2, p_msgerr varchar2);
end pkg_constructores;

/

create or replace package body pkg_constructores as
    function fn_tours(
        p_idhuesp number
    )return number
    as
        v_cantidad number;
        v_Valor_tour number;
    begin
        select sum(ht.num_personas),t.valor_tour
        into v_cantidad, v_valor_tour
        from huesped_tour ht join tour t on ht.id_tour=t.id_tour
        where ht.id_huesped=p_idhuesp
        group by t.valor_tour;
        return (v_cantidad*v_valor_tour);
    exception
        when no_data_found then
        return 0;
    end fn_tours;

    procedure sp_captura_error(
        p_iderr number, p_subrut varchar2, p_msgerr varchar2
    )as
        v_sql varchar2(400);
    begin
        v_sql:='
            insert into REG_ERRORES
            values (:1,:2,:3)
        ';
        execute immediate v_sql using p_iderr, p_subrut, p_msgerr;
    end sp_captura_error;
end pkg_constructores;

/

create or replace function fn_nombre_agencia(
    p_idagen number, p_idhuesp number
)return varchar2
as
    v_nom_agencia varchar2(50);
    v_sql varchar2(400);
    v_subrut varchar2(400);
    v_msgerr varchar2(400);
begin
    v_sql:='
        select nom_agencia
        from AGENCIA
        where id_agencia=:1
    ';
    execute immediate v_sql into v_nom_agencia using p_idagen;
    return v_nom_agencia;
exception
    when no_data_found then
        v_subrut:='Error en la función '||$$PLSQL_UNIT||' al recuperar la agencia del huesped con id '||p_idhuesp;
        v_msgerr:=sqlerrm;
        pkg_constructores.sp_captura_error(SQ_ERROR.nextval, v_subrut, v_msgerr);
        v_nom_agencia:='NO REGISTRA AGENCIA';
        return v_nom_agencia;
end fn_nombre_agencia;

/

create or replace procedure sp_principal(
    p_fecha varchar2, p_dolar number
)as
    cursor c_detalle is
    select h.id_huesped, h.appat_huesped||' '||h.apmat_huesped||' '||h.nom_huesped nombre,
        h.id_agencia, r.estadia, r.id_reserva, sum(ha.valor_habitacion+ha.valor_minibar) alojamiento
    from huesped h join reserva r on h.id_huesped=r.id_huesped
        join detalle_reserva dr on r.id_reserva=dr.id_reserva
        join habitacion ha on dr.id_habitacion=ha.id_habitacion
    where to_char((r.ingreso+r.estadia),'mmyyyy')=p_fecha
    group by h.id_huesped, h.appat_huesped,h.apmat_huesped,h.nom_huesped,
        h.id_agencia, r.estadia, r.id_reserva
    order by h.appat_huesped;
    
    v_cont number:=0;
    
    v_agencia varchar2(20);
    v_alojamiento number;
    v_consumo number;
    v_cons number;
    v_subtotal number;
    v_pct_consumos number;
    v_dscto_consumos number;
    v_dscto_agencia number;
    v_total number;
    
    v_sql varchar2(400);
begin
    execute immediate 'truncate table DETALLE_MENSUAL_HUESPEDES';
    execute immediate 'truncate table REG_ERRORES';

    for r_detalle in c_detalle loop
        
        v_cont:=v_cont+1;
        
        v_agencia:=fn_nombre_agencia(r_detalle.id_agencia, r_detalle.id_huesped);
        v_alojamiento:=r_detalle.alojamiento*r_detalle.estadia;
        v_consumo:=fn_consumos(r_detalle.id_huesped);
        pkg_constructores.v_monto_tours:=pkg_constructores.fn_tours(r_detalle.id_huesped);
        
        v_subtotal:=v_alojamiento+v_consumo+pkg_constructores.v_monto_tours;
        
        select pct
        into v_pct_consumos
        from TRAMOS_CONSUMOS
        where v_consumo between VMIN_TRAMO and VMAX_TRAMO;
        
        v_dscto_consumos:=round(v_consumo*v_pct_consumos);
        
        v_dscto_agencia:=round(v_subtotal*case v_agencia
                                            when 'VIAJES ALBERTI' then 0.1
                                            when 'VIAJES ENIGMA' then 0.2
                                            else 0
                                        end);
        
        v_total:=v_subtotal-v_dscto_consumos-v_dscto_agencia;
        
        v_sql:='
            insert into DETALLE_MENSUAL_HUESPEDES
            values (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10)
        ';
        execute immediate v_sql using r_detalle.id_huesped
            ,r_detalle.nombre
            ,v_agencia
            ,v_alojamiento*p_dolar
            ,v_consumo*p_dolar
            ,pkg_constructores.v_monto_tours*p_dolar
            ,v_subtotal*p_dolar
            ,v_dscto_consumos*p_dolar
            ,v_dscto_agencia*p_dolar
            ,v_total*p_dolar;
    end loop;
end sp_principal;

/

create or replace trigger tr_agencia
after insert or update or delete on DETALLE_MENSUAL_HUESPEDES
for each row
declare
begin
    if inserting then
        update INFORME_AGENCIA
            set monto_alojamiento=monto_alojamiento+:new.alojamiento,
                monto_consumos=monto_consumos+:new.consumos,
                monto_tours=monto_tours+:new.tours,
                monto_descuentos=monto_descuentos+:new.consumos,
                monto_mensual_agencia=monto_mensual_agencia+:new.total
            where nombre_agencia=:new.agencia;
    end if;
end tr_agencia;

/
begin
    sp_principal('082021', 840);
    execute immediate 'drop sequence SQ_ERROR';
    execute immediate 'create sequence SQ_ERROR minvalue 1 maxvalue 9999999999 increment by 1';
end;
/

select agencia, sum(alojamiento), sum(consumos), sum(tours), sum(descuento_consumos), sum(total)
from DETALLE_MENSUAL_HUESPEDES
group by agencia;

/
select h.id_huesped, h.appat_huesped||' '||h.apmat_huesped||' '||h.nom_huesped nombre,
    r.ingreso, r.estadia, r.ingreso+r.estadia salida, sum(ha.valor_habitacion+ha.valor_minibar)
    from huesped h join reserva r on h.id_huesped=r.id_huesped
    join detalle_reserva dr on r.id_reserva=dr.id_reserva
    join habitacion ha on dr.id_habitacion=ha.id_habitacion
    where to_char((r.ingreso+r.estadia),'mmyyyy')='082021'
    group by h.id_huesped, h.appat_huesped,h.apmat_huesped,h.nom_huesped,
    r.ingreso, r.estadia, r.ingreso+r.estadia
    order by h.appat_huesped;