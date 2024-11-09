ALTER SESSION DISABLE PARALLEL DML;
ALTER SESSION DISABLE PARALLEL DDL;
ALTER SESSION DISABLE PARALLEL query;

create or replace procedure sp_gc_cero(
    p_tbl gasto_comun_pago_cero%rowtype
)as
begin
    insert into GASTO_COMUN_PAGO_CERO
    values p_tbl;
end sp_gc_cero;

create or replace procedure sp_gc_pc(
    p_fecha varchar2
)