CREATE OR REPLACE PACKAGE pkg_asignaciones AS
   PROCEDURE sp_guarda_errores (p_num number, p_subp VARCHAR2, p_desc varchar2);
   FUNCTION fn_ventas (p_run VARCHAR2, p_fec VARCHAR2) RETURN NUMBER;
END pkg_asignaciones;
/

CREATE OR REPLACE PACKAGE BODY pkg_asignaciones AS

   FUNCTION fn_ventas (
     p_run VARCHAR2, p_fec VARCHAR2
   ) RETURN NUMBER
   AS
       v_mtoventas NUMBER;
   BEGIN
       SELECT SUM(db.totallinea)
       INTO v_mtoventas
       FROM boleta bo JOIN detalle_boleta db
       ON bo.numboleta = db.numboleta
       WHERE bo.run_empleado = p_run
         AND TO_CHAR(bo.fecha, 'YYYYMM') = p_fec;
       RETURN v_mtoventas;   
   END fn_ventas;


   PROCEDURE sp_guarda_errores (
    p_num number, p_subp VARCHAR2, p_desc varchar2
   )
   AS
      v_sql VARCHAR2(300);
   BEGIN
      V_SQL := 'INSERT INTO error_calc
                VALUES (:1, :2, :3)';
      EXECUTE IMMEDIATE V_SQL USING p_num, p_subp, p_desc;          
   END sp_guarda_errores;
END pkg_asignaciones;
/


CREATE OR REPLACE FUNCTION fn_indmov (
  p_codcomuna NUMBER
) RETURN NUMBER
AS
   v_indmov NUMBER;
   v_sql VARCHAR2(300);
BEGIN
   EXECUTE IMMEDIATE 'SELECT INDMOVILIDAD
                      FROM COMUNA
                      WHERE CODCOMUNA = :1'
   INTO v_indmov USING p_codcomuna;
   RETURN v_indmov;
END fn_indmov;
/

CREATE OR REPLACE FUNCTION fn_asianti (
  p_anti number, p_ventas number 
) return NUMBER
AS
   v_pct NUMBER;
   v_sql VARCHAR2(300); 
   v_msg VARCHAR2(300);
BEGIN
   BEGIN
       v_sql := 'SELECT PORC_ANTIGUEDAD / 100 
                 FROM PORC_ANTIGUEDAD_EMPLEADO
                 WHERE :1 BETWEEN ANNOS_ANTIGUEDAD_INF 
                 AND ANNOS_ANTIGUEDAD_SUP';
       execute immediate V_SQL INTO v_pct USING P_ANTI; 
   EXCEPTION
      WHEN OTHERS THEN
         v_msg := sqlerrm;
         v_pct := 0;
         pkg_asignaciones.sp_guarda_errores(seq_error.nextval,
          'ERROR EN LA FUNCION ' || $$PLSQL_UNIT 
          || ' AL RECUPERAR PORCENTAJE ASOCIADO A '
          || P_ANTI || ' AÑOS DE ANTIGUEDAD', V_MSG);
   END;
   RETURN ROUND(p_ventas * v_pct);
END fn_asianti;
/

CREATE OR REPLACE PROCEDURE sp_procesa_empleados (
  p_fecha VARCHAR2, p_col number, p_mov number, p_sal number
)
AS
  CURSOR c1 IS
  SELECT run_empleado, nombre, paterno, materno,
         sueldo_base, codcomuna, fecha_contrato
  FROM empleado 
  ORDER BY paterno, materno, nombre;
  
  v_movil NUMBER;
  v_anti number;
  v_asianti NUMBER;
BEGIN
  FOR r1 IN c1 LOOP
  
     -- CALCULO DE LA ASIGNACION DE MOVILIZACION
     v_movil := P_MOV + ROUND(r1.sueldo_base *
                                CASE fn_indmov(r1.codcomuna)
                                   WHEN 10 THEN 0.1
                                   WHEN 20 THEN 0.12
                                   WHEN 30 THEN 0.14
                                   ELSE 0.15
                                END);
  
     -- CALCULO DE LA ASIGNACION POR ANTIGUEDAD
     v_anti := ROUND(months_between(sysdate,r1.fecha_contrato) / 12);
     v_asianti := fn_asianti(v_anti,
             pkg_asignaciones.fn_ventas(r1.run_empleado, p_fecha));
     
     pl(SUBSTR(p_fecha, -2)
        || ' ' || SUBSTR(p_fecha,1, 4)
        || ' ' || r1.run_empleado
        || ' ' || r1.paterno||' '||r1.materno||' '||r1.nombre
        || ' ' || r1.sueldo_base
        || ' ' || p_col
        || ' ' || v_movil
        );
  END LOOP;
END sp_procesa_empleados;
/

begin
  sp_procesa_empleados('202104', 75000, 60000, 7/100);
  EXECUTE IMMEDIATE 'drop sequence seq_error'; 
  EXECUTE IMMEDIATE 'create sequence seq_error'; 
end;
/