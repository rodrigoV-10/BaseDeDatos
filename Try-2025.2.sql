--2025.2
SET SERVEROUTPUT ON;
--PREGUNTA 1
SELECT * FROM HORARIOS;
SELECT * FROM SERVICIOS_MEDICOS;
/
CREATE OR REPLACE FUNCTION FN_OBTENER_PRECIO_SERVICIO
(p_id_servicio NUMBER)
return NUMBER 
AS
    resultado NUMBER;

BEGIN
    
    SELECT s.precio INTO RESULTADO
    FROM servicios_medicos s
    WHERE s.servicio_id=p_id_servicio;
    RETURN resultado;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 0;
END;
/

SELECT fn_obtener_precio_servicio (111) AS PRECIO FROM DUAL;
SELECT SERVICIO_ID, fn_obtener_precio_servicio(SERVICIO_ID) AS PRECIO 
FROM servicios_medicos;


--Pregunta 2
/
CREATE OR REPLACE FUNCTION FN_TOTAL_ATENCIONES_ESPE
(p_id_especialidad NUMBER)
RETURN NUMBER
AS
    cantidad NUMBER;
BEGIN
    SELECT COUNT(*) INTO cantidad 
    FROM PERSONALES_MEDICOS pm , ATENCIONES_MEDICAS a
    WHERE pm.especialidad_id = p_id_especialidad and a.personal_id=pm.personal_id;
    RETURN CANTIDAD;
    

END;
/
SELECT * FROM ATENCIONES_MEDICAS;
SELECT ESPECIALIDAD_ID, DENOMINACION, 
FN_TOTAL_ATENCIONES_ESPE(ESPECIALIDAD_ID) AS TOTAL_ATENCIONES 
FROM ESPECIALIDADES; 


--PREGUNTA 3
SELECT * FROM BOLETAS_SERVICIOS;
SELECT * FROM BOLETAS_MEDICAMENTOS;
/
CREATE OR REPLACE FUNCTION FN_CALCULAR_MONTO_BOLETA 
(p_id_boleta NUMBER)
RETURN NUMBER
AS
    cant1 NUMBER;
    cant2 NUMBER;
    monto_servicios NUMBER :=0;
    monto_medicamentos NUMBER :=0;
    
BEGIN
    
    SELECT COUNT(*) INTO cant1
    FROM BOLETAS_SERVICIOS bs, BOLETAS b
    WHERE b.boleta_id= p_id_boleta and bs.boleta_id=p_id_boleta;
    
    --ME ASEGURO QUE EXISTA LA CANTIDAD
    IF cant1!=0 THEN
        --LUEGO CALCULO EL VALOR
        SELECT nvl(bs.subtotal,0) into monto_servicios
        FROM BOLETAS_SERVICIOS bs, BOLETAS b
        WHERE b.boleta_id= p_id_boleta and bs.boleta_id=p_id_boleta;
    END IF;
    
    SELECT COUNT(*) INTO cant2
    FROM BOLETAS_MEDICAMENTOS bm , BOLETAS b
    WHERE bm.boleta_id = p_id_boleta and p_id_boleta=b.boleta_id;
    
    
    IF cant2!=0 THEN
        SELECT nvl(bm.subtotal,0) into monto_medicamentos
        FROM BOLETAS_MEDICAMENTOS bm , BOLETAS b
        WHERE bm.boleta_id = p_id_boleta and p_id_boleta=b.boleta_id;
    END IF;
    
    
    RETURN monto_medicamentos+monto_servicios;
    
END;
/
SELECT FN_CALCULAR_MONTO_BOLETA(111) AS MONTO FROM DUAL;
SELECT BOLETA_ID, FN_CALCULAR_MONTO_BOLETA(BOLETA_ID) AS MONTO_CALCULADO  
FROM BOLETAS  
WHERE BOLETA_ID <= 418; 



--Pregunta 4
SELECT * FROM CITAS_MEDICAS;
DESC CITAS_MEDICAS;
/
CREATE OR REPLACE PROCEDURE SP_INSERTAR_CITA_MEDICA
(p_id_cita NUMBER,p_id_paciente NUMBER,p_id_personal NUMBER,p_fecha DATE,p_hora citas_medicas.hora_cita%type
,p_estado VARCHAR2)
AS
  existe_cita NUMBER;  
BEGIN
    
    SELECT COUNT(*) INTO existe_cita
    FROM CITAS_MEDICAS c
    WHERE p_id_cita = c.cita_id;
    
    IF existe_cita!=0 THEN
        INSERT INTO CITAS_MEDICAS (cita_id,paciente_id,personal_id,fecha_cita,hora_cita,estado) 
        VALUES (p_id_cita,p_id_paciente,p_id_personal,p_fecha,p_hora,p_estado);
        dbms_output.put_line('Cita médica registrada exitosamente');
    ELSE
        dbms_output.put_line('Error: Ya existe una cita para este paciente en la misma fecha y hora');
    END IF;
    
END SP_INSERTAR_CITA_MEDICA;
/
SELECT * FROM CITAS_MEDICAS;
ROLLBACK;

exec SP_INSERTAR_CITA_MEDICA(1001,201,101,TO_DATE('01-12-2025', 'DD-MM-YYYY'),TO_DATE('01-12-2025 09:00', 'DD-MM-YYYY HH24:MI'),'Programada');

exec SP_INSERTAR_CITA_MEDICA(951,201,101,TO_DATE('12-05-2025', 'DD-MM-YYYY'),TO_DATE('01-11-2025 08:00', 'DD-MM-YYYY HH24:MI'),'Programada');


--Pregunta 5
DESC ATENCIONES_MEDICAS;
CREATE OR REPLACE PROCEDURE SP_UPD_DIAGNOSTICO_ATENCION
(p_id_atencion NUMBER,p_diagnostico ATENCIONES_MEDICAS.DIAGNOSTICO%TYPE)
AS
--VARIABLES
--SI LA ATENCION MEDICA EXISTE EL DIAGNOSITVO DEBE ACTUALIZARSE
--CASO CONTRARIO DEBE DE MOSTRAR EL MENSAJE DE ERROR
    existe NUMBER;
BEGIN
--PROCESO
   SELECT COUNT(*) INTO existe
   FROM ATENCIONES_MEDICAS a
   WHERE a.atencion_id = p_id_atencion ;
   
   IF existe=0 THEN
        dbms_output.put_line('Error: La atención medica no existe');
   ELSE
        UPDATE ATENCIONES_MEDICAS
        SET DIAGNOSTICO = p_diagnostico
        WHERE atencion_id = p_id_atencion;
        dbms_output.put_line('Cita medica actualizada');
   END IF;
   
END SP_UPD_DIAGNOSTICO_ATENCION;
/
exec SP_UPD_DIAGNOSTICO_ATENCION(501,'Gripe viral sin complicaciones adversas');
exec SP_UPD_DIAGNOSTICO_ATENCION(9999,'Covid'); 

--Pregunta 6
/
CREATE OR REPLACE PROCEDURE SP_CALC_ESTA_EDAD_PACIENTES
(p_id_especialidad NUMBER)
AS
cantidad_pacientes NUMBER;
total NUMBER;
RINI NUMBER;
RFIN NUMBER;
PROM NUMBER;

BEGIN
    SELECT COUNT(*) INTO cantidad_pacientes
    FROM PERSONALES_MEDICOS p, CITAS_MEDICAS c, ESPECIALIDADES e, PACIENTES pa
    WHERE p_id_especialidad = e.especialidad_id and p.especialidad_id = e.especialidad_id 
    and c.personal_id = p.personal_id and c.paciente_id = pa.paciente_id;
    
    dbms_output.put_line(' ================================================================== ');
    dbms_output.put_line(' ESTADÍSTICAS DE EDAD - ESPECIALIDAD ID:  '||p_id_especialidad);
    dbms_output.put_line(' ================================================================== ');
    dbms_output.put_line('Cantidad de pacientes por especialidad ' || cantidad_pacientes);
    
    IF cantidad_pacientes!=0 THEN
    --PROMEDIO DE EDAD - TOTAL PACIENTES - RANGO DE EDADES
        SELECT MIN(EXTRACT (YEAR FROM SYSDATE ) - EXTRACT (YEAR FROM p.fecha_nacimiento)),
        MAX ( EXTRACT (YEAR FROM SYSDATE) - EXTRACT (YEAR FROM p.fecha_nacimiento))
        COUNT (*), AVG (EXTRACT (YEAR FROM SYSDATE) - EXTRACT (YEAR FROM p.fecha_nacimiento))
        INTO RINI, RFIN, TOTAL, PROM
        FROM PERSONALES_MEDICOS p, CITAS_MEDICAS c, ESPECIALIDADES e, PACIENTES pa
        WHERE p_id_especialidad = e.especialidad_id and pa.especialidad_id = e.especialidad_id 
        and c.personal_id = pa.personal_id and c.paciente_id = p.paciente_id and c.estado!='Cancelada';
        --esto ya es impresion
    END IF; 
    
    
    

END SP_CALC_ESTA_EDAD_PACIENTES;
/

exec SP_CALC_ESTA_EDAD_PACIENTES(1);
SELECT * FROM PACIENTES;
SELECT * FROM CITAS_MEDICAS;
SELECT * FROM PERSONALES_MEDICOS;
SELECT * FROM ESPECIALIDADES;