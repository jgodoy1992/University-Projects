variable b_limite number;
exec :b_limite := 50000;
variable b_tramo1 number;
exec :b_tramo1 := 100000;
variable b_tramo2 number;
exec :b_tramo2 := 400000;
variable b_tramo3 number;
exec :b_tramo3 := 800000;
variable b_tramo4 number;
exec :b_tramo4 := 1200000;
declare
   -- DECLARAMOS UNA VARIABLE DE CURSOR
   v_resumen sys_refcursor;
   v_fecha varchar2(6);
   v_codtran number;
   v_nomtran tipo_transaccion_tarjeta.nombre_tptran_tarjeta%type;
   
   -- cursor explicito nro 2
   -- LLENA LA TABLA DE DETALLE
   cursor c_transa (p_fecha varchar2, p_codtran number) is
   select cl.numrun, cl.dvrun, cl.cod_tipo_cliente,
          tc.nro_tarjeta, ttc.nro_transaccion,
          ttc.fecha_transaccion, 
          ttc.monto_total_transaccion monto,
          ttc.total_cuotas_transaccion cuotas
   from transaccion_tarjeta_cliente ttc join tarjeta_cliente tc
   on ttc.nro_tarjeta = tc.nro_tarjeta
   join cliente cl on cl.numrun = tc.numrun
   where to_char(ttc.fecha_transaccion, 'MMYYYY') = p_fecha
   and ttc.cod_tptran_tarjeta = p_codtran
   order by ttc.fecha_transaccion, cl.numrun;
   
   -- DECLARACION DEL VARRAY 
   type t_datos is varray(4) of number;
   v_datos t_datos := t_datos(0.04, 0.06, 0.08, 0.12);
   
   -- VARIABLE DE TIPO ROWTYPE EQUIVALENTE AL CURSOR
   r_transa c_transa%rowtype;
   
   -- variables escalares
   v_counter number := 0;
   v_tipocliente varchar2(30);
   v_code number;
   v_msg varchar2(400);
   v_pctadicional number;
   v_intereses number;
   
   -- variable de tipo exception
   e_limite exception;
begin
   execute immediate 'TRUNCATE TABLE error_proceso';
   execute immediate 'DROP SEQUENCE SEQ_ERROR';
   execute immediate 'CREATE SEQUENCE SEQ_ERROR';
   
   -- abrimos el cursor
   open v_resumen for
     select to_char(ttc.fecha_transaccion, 'MMYYYY') fecha,
            ttt.cod_tptran_tarjeta, ttt.nombre_tptran_tarjeta
     from transaccion_tarjeta_cliente ttc 
        join tipo_transaccion_tarjeta ttt
     on ttc.cod_tptran_tarjeta = ttt.cod_tptran_tarjeta
     where to_char(ttc.fecha_transaccion, 'YYYY') =
           to_char(sysdate, 'YYYY')
     and ttt.nombre_tptran_tarjeta like '%Avance%'      
     group by to_char(ttc.fecha_transaccion, 'MMYYYY'),
           ttt.cod_tptran_tarjeta, ttt.nombre_tptran_tarjeta
     order by to_char(ttc.fecha_transaccion, 'MMYYYY'); 
     
    loop
        fetch v_resumen into v_fecha,v_codtran,v_nomtran;
        exit when v_resumen%notfound;
        
        open c_transa (v_fecha, v_codtran);
        loop
            fetch c_transa into r_transa;
            exit when c_transa%notfound;
            
            v_counter := v_counter + 1;
            
            begin
                select nombre_tipo_cliente
                into v_tipocliente
                from tipo_cliente
                where cod_tipo_cliente = r_transa.cod_tipo_cliente;
            exception
               when others then
                  v_code := sqlcode;
                  v_msg := sqlerrm;
                  v_tipocliente := 'NO ASIGNADO';
                  insert into error_proceso
                  values (seq_error.nextval,
                          v_code, v_msg, 
                          'No se encontr? tipo para el cliente');
            end;
            
            -- recupero el % para el calculo del adicional
            select pct / 100
            into v_pctadicional
            from adicional_cuotas
            where r_transa.cuotas 
              between nro_cuotas_inf and nro_cuotas_sup;
            
            v_intereses := round(r_transa.monto * 
              case
                 when r_transa.monto between :b_tramo1
                   and :b_tramo2 then v_datos(1)
                 when r_transa.monto between :b_tramo2 + 1
                   and :b_tramo3 then v_datos(2)
                 when r_transa.monto between :b_tramo3 + 1
                   and :b_tramo4 then v_datos(3)
                 when r_transa.monto > :b_tramo4 then v_datos(4)
                 else 0
              end); 
            
            begin
                if v_intereses > :b_limite then
                   raise e_limite;
                end if;
            exception
               when others then
                  v_code := 20001;
                  v_msg := 'Error de capa 8';
                  v_intereses := :b_limite;
                  insert into error_proceso
                  values (seq_error.nextval,
                          v_code, v_msg, 
                          'Se excedio el limite, Se asigna $50.000');
            end;
            
            pl(v_counter
               || ' ' || r_transa.numrun
               || ' ' || r_transa.dvrun
               || ' ' || r_transa.nro_tarjeta
               || ' ' || r_transa.nro_transaccion
               || ' ' || r_transa.fecha_transaccion
               || ' ' || v_tipocliente
               || ' ' || v_nomtran
               || ' ' || r_transa.monto
               || ' ' || round(r_transa.monto * v_pctadicional)
               || ' ' || v_intereses
               );
        end loop;
        close c_transa;
    end loop;
end;

