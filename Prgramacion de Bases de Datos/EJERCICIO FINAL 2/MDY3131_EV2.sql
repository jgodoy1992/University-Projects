create or replace procedure pl(
    cadena varchar2
) as

begin
    dbms_output.put_line(cadena);
end;

--varaibles bind

variable b_anno_proc number;
exec :b_anno_proc:=extract(year from sysdate);

variable b_mes_proc number;
exec :b_mes_proc:=extract(month from sysdate);

variable b_anno number;
exec :b_anno:=2021;

variable b_mes number;
exec :b_mes:=6;

variable b_mas_10 number;
exec :b_mas_10:=0.35;

variable b_9_10 number;
exec :b_9_10:=0.30;

variable b_6_8 number;
exec :b_6_8:=0.25;

variable b_3_5 number;
exec :b_3_5:=0.20;

variable b_1_2 number;
exec :b_1_2:=0.15;

declare

    v_min_id number;
    v_max_id number;

    v_emp empleado%rowtype;
    v_det_venta detalle_venta_empleado%rowtype;
    v_comision comision_venta_empleado%rowtype;
    
    v_pct_bono_equipo number;
    v_pct_categorizacion number;
    v_test number;
    v_pct_comision number;
    
begin

    execute immediate 'truncate table detalle_venta_empleado';
    execute immediate 'truncate table comision_venta_empleado';

    --cursor recuperacion valor maximo y minimo
    
    select
        min(id_empleado),
        max(id_empleado)
    into v_min_id, v_max_id
    from empleado;

    while v_min_id <= v_max_id loop
    
    --recuepracion datos empleado
    
        select
            *
        into v_emp
        from empleado
        where id_empleado=v_min_id;
        
        v_det_venta.id_empleado:=v_min_id;
        v_det_venta.anno:=:b_anno;
        v_det_venta.mes:=:b_mes;
        v_det_venta.nombre:=v_emp.nombres||' '||v_emp.apellidos;
        
        --recuperacion  nombre del equipo
        
        select
            nom_equipo
        into v_det_venta.equipo_emp
        from equipo
        where id_equipo=v_emp.id_equipo;
        
        --cantidad de ventas realizadas
        
        select
            count(id_empleado)
        into v_det_venta.nro_ventas
        from pedido
        where id_empleado=v_emp.id_empleado and extract(year from fecha_pedido)=:b_anno
        and extract(month from fecha_pedido)=:b_mes;
        
        --monto total de ventas realizadas en el mes de junio
        
        select
            sum(dp.cantidad*pr.precio)
        into v_det_venta.ventas_netas_mes
        from pedido p join detallepedido dp
        on p.id_pedido=dp.id_pedido
        join producto pr
        on dp.id_producto=pr.id_producto
        where p.id_empleado=v_min_id and extract(year from p.fecha_pedido)=:b_anno
        and extract(month from p.fecha_pedido)=:b_mes;
        
        --calculo bono por equipo
        
        select
            porc/100
        into v_pct_bono_equipo
        from equipo
        where id_equipo=v_emp.id_equipo;
        
        v_det_venta.bono_equipo:=v_pct_bono_equipo*v_det_venta.ventas_netas_mes;
        
        --calculo asignacion por ventas
        
        select
            porcentaje/100
        into v_pct_categorizacion
        from categorizacion
        where id_categorizacion=v_emp.id_categorizacion;
        
        v_det_venta.incentivo_categorizacion:=v_det_venta.ventas_netas_mes*v_pct_categorizacion;
        
        --asignacion por ventas
            
        v_det_venta.asignacion_vtas:=v_det_venta.ventas_netas_mes*case
                                                                        when v_det_venta.nro_ventas between 1 and 2 then :b_1_2
                                                                        when v_det_venta.nro_ventas between 3 and 5 then :b_3_5 
                                                                        when v_det_venta.nro_ventas between 6 and 8 then :b_6_8  
                                                                        when v_det_venta.nro_ventas between 9 and 10 then :b_9_10  
                                                                        when v_det_venta.nro_ventas >10 then :b_mas_10
                                                                        else 0
                                                                    end;

        --asignacion por antigüedad
        
        v_det_venta.asignacion_antig:=v_det_venta.ventas_netas_mes*case
                                                                        when :b_anno-extract(year from v_emp.feccontrato)>15 then 0.27
                                                                        when :b_anno-extract(year from v_emp.feccontrato) between 7 and 15 then 0.14
                                                                        when :b_anno-extract(year from v_emp.feccontrato) between 3 and 7 then 0.04
                                                                        else 0
                                                                    end;
                                                                    
        --descuentos!!!
        
        select
            sum(monto)
        into v_det_venta.descuentos
        from descuento
        where id_empleado=v_emp.id_empleado and mes=:b_mes-1; 
        
        --total
        
        v_det_venta.totales_mes:=v_det_venta.ventas_netas_mes+
                                v_det_venta.bono_equipo+
                                v_det_venta.incentivo_categorizacion+
                                v_det_venta.asignacion_vtas+
                                v_det_venta.asignacion_antig-
                                v_det_venta.descuentos;
                                
        --comision por venta mensual
        
        select
            comision/100
        into v_pct_comision
        from comisionempleado
        where v_det_venta.totales_mes between ventaminima and ventamaxima;
        
        v_comision.anno:=:b_anno;
        v_comision.mes:=:b_mes;
        v_comision.id_empleado:=v_min_id;
        v_comision.total_ventas:=v_det_venta.totales_mes;        
        v_comision.monto_comision:=v_det_venta.totales_mes*v_pct_comision;
        
        /*pl(v_det_venta.anno||' '||v_det_venta.mes||' '||v_det_venta.id_empleado||' '||
        v_det_venta.nombre||' '||v_det_venta.equipo_emp||' '||v_det_venta.nro_ventas||' '||
        v_det_venta.ventas_netas_mes||' '||v_det_venta.bono_equipo|| ' '||
        v_det_venta.incentivo_categorizacion||' '||v_det_venta.asignacion_vtas||' '||
        v_det_venta.asignacion_antig||' '||v_det_venta.descuentos||' '||v_det_venta.totales_mes);*/
        
        --insercion de datos en tablas
        
        insert into detalle_venta_empleado
        values v_det_venta;
        
        insert into comision_venta_empleado
        values v_comision;
        
        v_min_id:=v_min_id+2;
        
    end loop;

end;