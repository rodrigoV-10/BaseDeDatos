--Nuevo intento 2025.2


--Pregunta 1
SELECT * FROM PACIENTES;
DESC PACIENTES;
--INSERT INTO PACIENTES VALUES(999,'Brenda','Salas','DNI',
--'74851236',to_date('1997-04-15','DD-MM-YYYY'),'F','Campos',1,SYSDATE,'1',SYSDATE);


INSERT INTO PACIENTES
(PACIENTE_ID,
NOMBRE,
PRIMER_APELLIDO,
TIPO_DOCUMENTO,
NRO_DOCUMENTO,
FECHA_NACIMIENTO,
SEXO,
SEGUNDO_APELLIDO,
USUARIO_CREACION,
FECHA_CREACION,
USUARIO_ULT_MODIF,
FECHA_ULT_MODIF)
VALUES (999,'Brenda','Salas','DNI','74851236',to_date('15-04-1997','DD-MM-YYYY')
,'F','Campos',1,SYSDATE,1,SYSDATE);

INSERT INTO PACIENTES (PACIENTE_ID, NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, TIPO_DOCUMENTO,NRO_DOCUMENTO, FECHA_NACIMIENTO, SEXO, USUARIO_CREACION,USUARIO_ULT_MODIF,FECHA_CREACION,FECHA_ULT_MODIF) 
VALUES (1000,'Marcela','Parras','Guzman','CE','00006754',TO_DATE('20-05-1991','DD-MM-YYYY'),'F',1,1,SYSDATE,SYSDATE);

--Pregunta 2
DESC BOLETAS;
INSERT INTO BOLETAS VALUES (9201,'BMS-9201',201,TO_DATE('10-09-2025','DD-MM-YYYY'),91,'Tarjeta');

DESC BOLETAS_SERVICIOS;
INSERT INTO BOLETAS_SERVICIOS (BOLETA_ID,SERVICIO_ID,PRECIO_UNITARIO,CANTIDAD) VALUES (9201,301,40.50,1);
INSERT INTO BOLETAS_SERVICIOS (BOLETA_ID,SERVICIO_ID,PRECIO_UNITARIO,CANTIDAD) VALUES (9201,302,50.50,1);

--Pregunta 3
SELECT * FROM SERVICIOS_MEDICOS;
SELECT * FROM ESPECIALIDADES;

UPDATE SERVICIOS_MEDICOS
SET precio = precio+(precio*0.1)
WHERE especialidad_id = (SELECT especialidad_id 
                         FROM ESPECIALIDADES e
                         WHERE e.denominacion='Cardiología' );
                         
--Pregunta 4
SELECT * FROM CITAS_MEDICAS;
--Eliminar citas canceladas anteriores al 01-09-2025
DELETE FROM CITAS_MEDICAS
WHERE ESTADO='Cancelada' and fecha_cita<'01-09-2025';

--Pregunta 5
SELECT * FROM PACIENTES;
SELECT * FROM BOLETAS;

SELECT b.nro_serie, b.fecha_emision, b.paciente_id , p.nombre ||' '||p.primer_apellido||' '|| p.segundo_apellido AS PACIENTE , b.monto_total
FROM BOLETAS b , PACIENTES p
WHERE  b.paciente_id = p.paciente_id
ORDER BY b.fecha_emision DESC;

--Pregunta 6
--MOMENTO SUM, AVG , MAX , MIN
SELECT * FROM ESPECIALIDADES;
SELECT * FROM SERVICIOS_MEDICOS;

SELECT e.denominacion, COUNT (s.especialidad_id) AS CANT_SERVICIOS, 
MIN(s.precio) as PRECIO_MIN , MAX (s.precio) AS PRECIO_MAX ,
AVG(s.precio)
FROM SERVICIOS_MEDICOS s , ESPECIALIDADES e
WHERE s.especialidad_id = e.especialidad_id
GROUP BY e.denominacion
ORDER BY PRECIO_MIN DESC;

--Pregunta 7

SELECT * FROM CITAS_MEDICAS;
SELECT * FROM ATENCIONES_MEDICAS;
SELECT * FROM ESPECIALIDADES;
SELECT * FROM HORARIOS;
SELECT * FROM PERSONALES_MEDICOS;

SELECT e.denominacion, COUNT (p.especialidad_id) AS ATENCIONES,
ROUND (MIN ((a.hora_fin - a.hora_inicio)*24*60),0) AS MIN_MINUTOS,
ROUND (MAX ((a.hora_fin - a.hora_inicio)*24*60),0) AS MAX_MINUTOS,
ROUND (AVG ((a.hora_fin - a.hora_inicio)*24*60),0) AS AVG_MINUTOS
FROM ESPECIALIDADES e, ATENCIONES_MEDICAS a ,PERSONALES_MEDICOS p
WHERE e.especialidad_id = p.especialidad_id and p.personal_id=a.personal_id 
GROUP BY e.denominacion
ORDER BY ATENCIONES;


--Pregunta 8
SELECT * FROM PACIENTES;
SELECT * FROM BOLETAS;
SELECT * FROM BOLETAS_SERVICIOS;

SELECT p.paciente_id,  p.nombre ||' '||p.primer_apellido||' '|| p.segundo_apellido AS PACIENTE , SUM(s.subtotal) AS TOTAL_GASTADO
FROM PACIENTES p , BOLETAS b, BOLETAS_SERVICIOS s
WHERE p.paciente_id = b.paciente_id and b.boleta_id = s.boleta_id
GROUP BY p.paciente_id , p.nombre ||' '||p.primer_apellido||' '|| p.segundo_apellido
ORDER BY TOTAL_GASTADO DESC;


--Pregunta 9
SELECT * FROM MEDICAMENTOS;
SELECT * FROM RECETAS_MEDICAMENTOS;
SELECT * FROM BOLETAS_MEDICAMENTOS;

SELECT m.medicamento_id, m.denominacion, SUM(b.cantidad) AS CANTIDAD_VENDIDA, SUM (b.subtotal)
FROM MEDICAMENTOS m, BOLETAS_MEDICAMENTOS b
WHERE  m.medicamento_id=b.medicamento_id 
GROUP BY m.medicamento_id, m.denominacion
ORDER BY CANTIDAD_VENDIDA DESC;