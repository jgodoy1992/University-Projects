create or replace procedure pl(
    cadena varchar2
) as
begin
    dbms_output.put_line(cadena);
end;
/
create or replace function fn_calcula_edad(
    p_fecnac date
)return number
as
begin
    return round(months_between(sysdate, p_fecnac)/12);
end fn_calcula_edad;
/
create or replace function fn_bono_antig(
    p_pct_1 number, p_pct_2 number, p_sueldo number, p_antig number
)return number
as
    v_bono_antig number;
begin
    if p_antig > 15 then
        v_bono_antig:=round(p_sueldo*p_pct_1);
    else
        v_bono_antig:=round(p_sueldo*p_pct_2);
    end if;
    return v_bono_antig;
end fn_bono_antig;
/
create or replace function fn_comision(
    p_sueldo number, p_proy number
)return number
as
    type t_pcts is varray(4) of number;
    v_pcts t_pcts:=t_pcts(0.3,0.2,0.1,0.05);
    v_comproy number;
begin
    v_comproy:=round(p_sueldo*case
                                    when p_proy > 8 then v_pcts(1)
                                    when p_proy > 6 then v_pcts(2)
                                    when p_proy > 3 then v_pcts(3)
                                    when p_proy > 1 then v_pcts(4)
                                    else 0
                                end);
    return v_comproy;
end fn_comision;
/
create or replace package pkg_asig_cat as
    v_nombre EMPRESA.RAZONSOCIAL%type;
    v_pct_cat number;
    function fn_nom_emp(p_rutemp number)return varchar2;
    function fn_pct_asig(p_puntaje number)return number;
end pkg_asig_cat;
/
create or replace package body pkg_asig_cat as
    function fn_nom_emp(
        p_rutemp number
    )return varchar2
    as
    begin
            select razonsocial
            into v_nombre
            from empresa
            where rut=p_rutemp;
            return v_nombre;
    end fn_nom_emp;
    
    function fn_pct_asig(
        p_puntaje number
    )return number
    as
    begin
            select pct
            into v_pct_cat
            from lista
            where p_puntaje between punt_min and punt_max;
            return v_pct_cat;
    end fn_pct_asig;
end pkg_asig_cat;
/
create or replace procedure sp_captura_error(
    p_num number, p_sub varchar2, p_msgerr varchar2, p_msgusr varchar2
)as
    v_sql varchar2(400);
begin
    v_sql:='
        insert into ERRORES
        values(:1,:2,:3,:4)
    ';
    execute immediate v_sql using p_num, p_sub, p_msgerr, p_msgusr;
end sp_captura_error;
/
create or replace procedure sp_tabla_resumen(
    p_tbl resumen_bonos%rowtype
)as
begin
    insert into RESUMEN_BONOS
    values p_tbl;
end sp_tabla_resumen;
/
create or replace procedure sp_principal(
    p_fecha date, p_pct_edad_1 number, p_pct_edad_2 number
)as
    cursor c_resumen is
    select razonsocial, rut
    from empresa;
    
    cursor c_detalle(p_run_emp number) is
    select e.rut||'-'||e.dv run, e.nombres||' '||e.apellidos nombre,
        ep.razonsocial, e.sueldo, e.fecnac,e.fecingreso,e.numproyectos,
        e.puntaje
    from empleado e join empresa ep on e.rutempresa=ep.rut
    where e.rutempresa=p_run_emp;
    
    v_cont number:=0;
    
    --varaibles escalares
    v_antig number;
    v_asig_edad number;
    v_total_asig number;
    
    --varaibles totalizadoras
    
    v_tbl RESUMEN_BONOS%rowtype;

begin
    execute immediate 'truncate table DETALLE_BONOS';
    execute immediate 'truncate table RESUMEN_BONOS';

    for r_resumen in c_resumen loop
    
        v_tbl.NUMEMPLEADOS:=0;
        v_tbl.TOT_SUELDOS:=0;
        v_tbl.TOT_BONOANTIG:=0;
        v_tbl.TOT_COMISION:=0;
        v_tbl.TOT_ASIGEDAD:=0;
        v_tbl.TOT_ASIGCAT:=0;
        v_tbl.TOTAL_ASIGNACIONES:=0;
    
        for r_detalle in c_detalle(r_resumen.rut) loop
            
            v_cont:=v_cont+1;
            
            v_antig:=round(months_between(p_fecha, r_detalle.fecingreso)/12);
            
            if fn_calcula_edad(r_detalle.fecnac) > 50 then
                v_asig_edad:=round(r_detalle.sueldo*case
                                                        when fn_calcula_edad(r_detalle.fecnac) >= 65
                                                            then 0.08
                                                        when fn_calcula_edad(r_detalle.fecnac) >= 55
                                                            then 0.05
                                                        when fn_calcula_edad(r_detalle.fecnac) >= 50
                                                            then 0.03
                                                    end);
            else v_asig_edad:=0;
            end if;
            
            v_total_asig:=fn_bono_antig(p_pct_edad_1, p_pct_edad_2,r_detalle.sueldo,v_antig)+fn_comision(r_detalle.sueldo, r_detalle.numproyectos) 
                           + v_asig_edad+round(r_detalle.sueldo*pkg_asig_cat.fn_pct_asig(r_detalle.puntaje));
        
            pl(
                v_cont
                ||' '||to_char(p_fecha, 'mmyyyy')
                ||' '||r_detalle.run
                ||' '||r_detalle.nombre
                ||' '||pkg_asig_cat.fn_nom_emp(r_resumen.rut)
                ||' '||r_detalle.sueldo
                ||' '||fn_calcula_edad(r_detalle.fecnac)
                ||' '||v_antig
                ||' '||fn_bono_antig(p_pct_edad_1, p_pct_edad_2,r_detalle.sueldo,v_antig)
                ||' '||fn_comision(r_detalle.sueldo, r_detalle.numproyectos)
                ||' '||v_asig_edad
                ||' '||round(r_detalle.sueldo*pkg_asig_cat.fn_pct_asig(r_detalle.puntaje))
                ||' '||v_total_asig
            );
            
            insert into DETALLE_BONOS
            values(
                to_char(p_fecha, 'mmyyyy')
                ,r_detalle.run
                ,r_detalle.nombre
                ,pkg_asig_cat.fn_nom_emp(r_resumen.rut)
                ,r_detalle.sueldo
                ,fn_calcula_edad(r_detalle.fecnac)
                ,v_antig
                ,fn_bono_antig(p_pct_edad_1, p_pct_edad_2,r_detalle.sueldo,v_antig)
                ,fn_comision(r_detalle.sueldo, r_detalle.numproyectos)
                ,v_asig_edad
                ,round(r_detalle.sueldo*pkg_asig_cat.fn_pct_asig(r_detalle.puntaje))
                ,v_total_asig
            );
            
            v_tbl.MES_ANNO_PROCESO:=to_char(p_fecha, 'mmyyyy');
            v_tbl.EMPRESA:=pkg_asig_cat.fn_nom_emp(r_resumen.rut);
            v_tbl.NUMEMPLEADOS:=v_tbl.NUMEMPLEADOS+1;
            v_tbl.TOT_SUELDOS:=v_tbl.TOT_SUELDOS+r_detalle.sueldo;
            v_tbl.TOT_BONOANTIG:=v_tbl.TOT_BONOANTIG+fn_bono_antig(p_pct_edad_1, p_pct_edad_2,r_detalle.sueldo,v_antig);
            v_tbl.TOT_COMISION:=v_tbl.TOT_COMISION+fn_comision(r_detalle.sueldo, r_detalle.numproyectos);
            v_tbl.TOT_ASIGEDAD:=v_tbl.TOT_ASIGEDAD+v_asig_edad;
            v_tbl.TOT_ASIGCAT:=v_tbl.TOT_ASIGCAT+round(r_detalle.sueldo*pkg_asig_cat.fn_pct_asig(r_detalle.puntaje));
            v_tbl.TOTAL_ASIGNACIONES:=v_tbl.TOTAL_ASIGNACIONES+v_total_asig;
            
        end loop;
        sp_tabla_resumen(v_tbl);
    end loop;
end sp_principal;
/
exec sp_principal(sysdate, 30/100, 15/100);
/
select to_char(sysdate, 'mmyyyy'),e.rut||'-'||e.dv run, e.nombres||' '||e.apellidos nombre,
        nvl(ep.razonsocial, 'Sin empresa asignada'), e.sueldo, e.fecnac,e.fecingreso,e.numproyectos,
        e.puntaje
    from empleado e left join empresa ep on e.rutempresa=ep.rut