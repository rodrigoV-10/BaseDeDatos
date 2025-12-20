--LABORATORIO 2 2025.2

--PREGUNTA 1

INSERT INTO PACIENTES
(PACIENTE_ID , NOMBRE , PRIMER_APELLIDO , TIPO_DOCUMENTO , 
	NRO_DOCUMENTO , FECHA_NACIMIENTO , SEXO , SEGUNDO_APELLIDO , 
	USUARIO_CREACION , FECHA_CREACION , USUARIO_ULT_MODIF , 
	FECHA_ULT_MODIF )
VALUES ('999','Brenda','Salas','DNI','74851236','15-04-1997','F','Campos',1,SYSDATE,1,SYSDATE); 


INSERT INTO PACIENTES
(PACIENTE_ID , NOMBRE , PRIMER_APELLIDO , TIPO_DOCUMENTO , 
	NRO_DOCUMENTO , FECHA_NACIMIENTO , SEXO , SEGUNDO_APELLIDO , 
	USUARIO_CREACION , FECHA_CREACION , USUARIO_ULT_MODIF , 
	FECHA_ULT_MODIF )
VALUES ('1000','Marcela','Parras','CE','00006754','20-05-1991','F','Guzman',1,SYSDATE,1,SYSDATE); 


--PREGUNTA 2
INSERT INTO BOLETAS
(BOLETA_ID,NRO_SERIE,PACIENTE_ID,FECHA_EMISION
,MONTO_TOTAL,METODO_PAGO)
VALUES ('9201','BMS-9201','201','10-09-2025','91','Tarjeta');

INSERT INTO BOLETAS_SERVICIOS
(BOLETA_ID,SERVICIO_ID,PRECIO_UNITARIO,CANTIDAD)
VALUES (9201,301,40.50,1);

INSERT INTO BOLETAS_SERVICIOS
(BOLETA_ID,SERVICIO_ID,PRECIO_UNITARIO,CANTIDAD)
VALUES (9201,302,50.50,1);

--PREGUNTA 3
--INCREMENTAR EN 10% LOS PRECIOS DE LA ESPECLIDAD CARDIOLOGÍA
UPDATE SERVICIOS_MEDICOS
SET PRECIO = PRECIO + (PRECIO*0.1)
WHERE ESPECIALIDAD_ID = (SELECT ESPECIALIDAD_ID FROM ESPECIALIDADES 
WHERE DENOMINACION = 'Cardiología');


--PREGUNTA 4

DELETE FROM CITAS_MEDICAS
WHERE (ESTADO = 'Cancelada' and FECHA_CITA < '01-09-2025');

--PREGUNTA 5
SELECT B.nro_serie, B.fecha_emision ,P.paciente_id , B.monto_total
FROM PACIENTES P, BOLETAS B
WHERE B.paciente_id = P.paciente_id
ORDER BY fecha_emision desc;

--PREGUNTA 6
--PIDE CANTSERVICIOS , PRECIOMIN, PRECIOMAX , PRECIONPROM
SELECT e.denominacion, COUNT(s.servicio_id) ,AVG(s.precio) as PRECIO_PROM, MIN(s.precio) as PRECIO_MIN, MAX (s.precio)
FROM ESPECIALIDADES e, SERVICIOS_MEDICOS s
WHERE e.especialidad_id = s.especialidad_id
GROUP BY e.denominacion
ORDER BY AVG(s.precio) desc;



--PREGUNTA 7



--PREGUNTA 9
--todos los medicamentos que se vendieron durante el mes de mayo
SELECT m.medicamento_id , m.denominacion ,SUM(bm.cantidad) AS CANTIDAD_VENDIDA
, SUM(bm.subtotal) as MONTO_VENDIDO
FROM MEDICAMENTOS m, BOLETAS_MEDICAMENTOS bm, BOLETAS b
WHERE m.medicamento_id = bm.medicamento_id and  bm.boleta_id = b.boleta_id and 
b.fecha_emision < '31-05-2025'
GROUP BY m.medicamento_id , m.denominacion
ORDER BY SUM(bm.cantidad) DESC;


--PREGUNTA 8

SELECT p.paciente_id, (p.nombre || ' ' || p.primer_apellido || ' ' || p.segundo_apellido) , SUM(bs.subtotal)
FROM PACIENTES p, BOLETAS b, BOLETAS_SERVICIOS bs
WHERE p.paciente_id = b.paciente_id and bs.boleta_id = b.boleta_id
GROUP BY p.paciente_id , (p.nombre || ' ' || p.primer_apellido || ' ' || p.segundo_apellido) ;


--PREGUNTA 7

SELECT e.denominacion AS ESPECIAIDAD ,COUNT(*) AS ATENCIONES,
MIN(a.hora_fin - a.hora_inicio) as MIN_MINUTOS,
MAX(a.hora_fin - a.hora_inicio) as MAX_MINUTOS,
AVG(a.hora_fin - a.hora_inicio) as AVG_MINUTOS
FROM ESPECIALIDADES e, ATENCIONES_MEDICAS a, PERSONALES_MEDICOS p
WHERE e.especialidad_id = p.especialidad_id and a.personal_id = p.personal_id
GROUP BY e.denominacion;




