CREATE OR REPLACE TRIGGER tr_califica
BEFORE INSERT ON detalle_pago_mensual
FOR EACH ROW
DECLARE
   v_msg VARCHAR2(200);
BEGIN
   v_msg := CASE
               WHEN :NEW.sueldo_liquido BETWEEN 400000 AND 700000 THEN 'Empleado con Salario menor al Promedio'
               WHEN :NEW.sueldo_liquido BETWEEN 700001 AND 900000 THEN 'Empleado con Salario Promedio'
               WHEN :NEW.sueldo_liquido > 900000 THEN 'Empleado con Salario Sobre el Promedio'
            END; 
   INSERT INTO calificacion_mensual_empleado
   VALUES (:NEW.mes, :NEW.anno, :NEW.run_empleado, :NEW.sueldo_liquido, v_msg);           
END tr_califica;
/

CREATE OR REPLACE PACKAGE pkg_asigna AS
   vp_ventas NUMBER;
   PROCEDURE sp_salvaerrores(p_num number, p_subp VARCHAR2, p_msg VARCHAR2);
   FUNCTION fn_ventas (p_run VARCHAR2, p_fec VARCHAR2) RETURN NUMBER;
END pkg_asigna;
/

CREATE OR REPLACE PACKAGE BODY pkg_asigna AS

   FUNCTION fn_ventas (
      p_run VARCHAR2, p_fec VARCHAR2
   ) RETURN NUMBER
   AS
      v_mtoventas NUMBER;
      v_sql VARCHAR2(300);
   BEGIN
      v_sql := 'SELECT SUM(db.totallinea)
                FROM boleta bo JOIN detalle_boleta db
                ON bo.numboleta = db.numboleta
                WHERE bo.run_empleado = :1
                  AND TO_CHAR(bo.fecha, ''yyyymm'') = :2';
      EXECUTE IMMEDIATE v_sql INTO v_mtoventas USING p_run, p_fec;
      RETURN v_mtoventas;
   END fn_ventas;
   
   PROCEDURE sp_salvaerrores(
     p_num number, p_subp VARCHAR2, p_msg VARCHAR2
   )
   AS
       v_sql VARCHAR2(300);
   BEGIN
       v_sql := 'INSERT INTO error_calc
                  VALUES (:1, :2, :3)';
       EXECUTE IMMEDIATE v_sql USING p_num, p_subp, p_msg;           
   END sp_salvaerrores;
   
END pkg_asigna;
/

CREATE OR REPLACE FUNCTION fn_asianti (
  p_anti NUMBER, p_ventas NUMBER
) RETURN NUMBER
AS
   v_pct NUMBER;
   v_sql VARCHAR2(300);
   v_msg VARCHAR2(300);
BEGIN
   BEGIN 
       v_sql := 'SELECT porc_antiguedad / 100
                 FROM porc_antiguedad_empleado
                 WHERE :1 BETWEEN annos_antiguedad_inf AND annos_antiguedad_sup';
       EXECUTE IMMEDIATE v_sql INTO v_pct USING p_anti;          
   EXCEPTION
      WHEN OTHERS THEN
         v_msg := SQLERRM;
         v_pct := 0;
         pkg_asigna.sp_salvaerrores(seq_error.NEXTVAL,
           'Error en la funcion ' || $$PLSQL_UNIT || ' al recuperar el % '
           || ' asociado a ' || p_anti || ' años de antiguedad', v_msg);
   END;
   RETURN ROUND(p_ventas * v_pct);
END fn_asianti;
/

CREATE OR REPLACE FUNCTION fn_indmov (
   p_codcomuna NUMBER  
) RETURN NUMBER
AS
   v_indmov NUMBER;
BEGIN
   EXECUTE IMMEDIATE 'SELECT indmovilidad
                      FROM comuna
                      WHERE codcomuna = :1'
   INTO v_indmov USING p_codcomuna;
   RETURN v_indmov;
END fn_indmov;
/

CREATE OR REPLACE FUNCTION fn_comision (
  p_ventas number 
) RETURN NUMBER
AS
   v_pct NUMBER; 
BEGIN
   SELECT porc_comision / 100
   INTO v_pct
   FROM porcentaje_comision_venta
   WHERE p_ventas BETWEEN venta_inf AND venta_sup;
   RETURN ROUND(p_ventas * v_pct);
END fn_comision;
/

CREATE OR REPLACE FUNCTION fn_prevision (
  p_codafp NUMBER
) RETURN NUMBER
AS
    v_pct NUMBER;
BEGIN
    SELECT porcafp / 100
    INTO v_pct
    FROM prevision_afp
    WHERE codafp = p_codafp;
    RETURN v_pct;
END fn_prevision;
/

CREATE OR REPLACE PROCEDURE sp_procesa_empleados (
  p_fecha VARCHAR2, p_col NUMBER, p_mov NUMBER, p_salud NUMBER
)
AS
    CURSOR c1 IS
    SELECT run_empleado, paterno, materno, nombre, sueldo_base,
           codcomuna, fecha_contrato, codafp
    FROM empleado
    ORDER BY paterno, materno, nombre;
    
    v_nom VARCHAR2(80);
    v_movil NUMBER;
    v_anti NUMBER;
    v_asianti NUMBER;
    v_comision number;
    v_imponible NUMBER;
    v_descuentos NUMBER;
    v_liquido NUMBER;
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE calificacion_mensual_empleado';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE detalle_pago_mensual';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE error_calc';
    
    FOR r1 IN c1 LOOP
    
        v_nom := r1.paterno||' '||r1.materno||' '||r1.nombre;
        
        -- calculo de la asignacion de movilizacion
        v_movil := p_mov + ROUND(r1.sueldo_base *
                           CASE fn_indmov(r1.codcomuna)
                               WHEN 10 THEN 0.1
                               WHEN 20 THEN 0.12
                               WHEN 30 THEN 0.14
                               ELSE 0.15
                           END);
                           
        -- uso de la variable publica del package
        pkg_asigna.vp_ventas := pkg_asigna.fn_ventas(r1.run_empleado, p_fecha);
        
        -- calculo de la asignacion especial o por antiguedad
        v_anti := ROUND(MONTHS_BETWEEN(sysdate, r1.fecha_contrato) / 12);
        v_asianti := fn_asianti(v_anti, pkg_asigna.vp_ventas);
        
        -- CALCULO DE LA COMISION
        v_comision := fn_comision(pkg_asigna.vp_ventas);
        
        -- TOTALIZAMOS EL IMPONIBLE
        v_imponible := r1.sueldo_base + p_col + v_movil + v_asianti + v_comision;
        
        -- CALCULO DE LOS DESCUENTOS
        v_descuentos := ROUND(v_imponible * fn_prevision(r1.codafp) +
                        v_imponible * p_salud);
        
        v_liquido := v_imponible - v_descuentos;
        
        pl(SUBSTR(p_fecha, -2)
           || ' ' || SUBSTR(p_fecha, 1, 4)
           || ' ' || r1.run_empleado
           || ' ' || v_nom
           || ' ' || r1.sueldo_base
           || ' ' || p_col
           || ' ' || v_movil     
           || ' ' || v_asianti     
           || ' ' || v_comision     
           || ' ' || v_imponible
           || ' ' || v_descuentos
           || ' ' || v_liquido
           );
           
        INSERT INTO detalle_pago_mensual
        VALUES (SUBSTR(p_fecha, -2)
               ,SUBSTR(p_fecha, 1, 4)
               ,r1.run_empleado
               ,v_nom
               ,r1.sueldo_base
               ,p_col
               ,v_movil     
               ,v_asianti     
               ,v_comision     
               ,v_imponible
               ,v_descuentos
               ,v_liquido
               );
    END LOOP;
    COMMIT;
END sp_procesa_empleados;
/

BEGIN
   sp_procesa_empleados('202104', 75000, 60000, 7/100);
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_error';
   EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_error';
END;
/
