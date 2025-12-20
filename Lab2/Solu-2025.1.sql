--PREGUNTA1

SELECT * FROM AP_VUELOS;

SELECT * FROM AP_MARCAS;

SELECT * FROM AP_AVIONES;

SELECT A.vuelo_id , A.fecha_hora_partida, A.fecha_hora_llegada,
A.aeropuerto_partida_id, A.aeropuerto_llegada_id, B.nro_placa,B.modelo
FROM AP_VUELOS A, AP_AVIONES B
WHERE A.avion_id = B.avion_id and B.modelo like '%737 MAX%';

--PREGUNTA 2
SELECT C.VUELO_ID, C.FECHA_HORA_PARTIDA, C.FECHA_HORA_LLEGADA,
A.AP_PATERNO , A.AP_MATERNO, A.FECHA_NACIMIENTO, A.SEXO,A.CELULAR,
A.EMAIL
FROM AP_PASAJEROS A,AP_BOLETOS B, AP_VUELOS C
WHERE A.PASAJERO_ID = B.PASAJERO_ID AND C.VUELO_ID = B.VUELO_ID AND
A.AP_PATERNO LIKE '%Rojo%' and A.AP_MATERNO LIKE '%Campos%';

--PREGUNTA 3
--SE NECESITA CONOCER LOS MENOS DE 18 AÑOS QUE HAN VIAJADO EN ALGUN VUELO
SELECT a.nro_documento, a.nombres, a.ap_paterno, a.ap_materno, a.fecha_nacimiento,
a.sexo, a.celular , a.email
FROM AP_PASAJEROS A
WHERE ADD_MONTHS(a.fecha_nacimiento,12*18)>SYSDATE;

--PREGUNTA 4
SELECT a.avion_id, b.modelo, a.fecha_fin_est,
ROUND (MONTHS_BETWEEN(SYSDATE,a.fecha_fin_est),2) AS CANTIDAD_MESES
FROM AP_MANT_AVIONES a, AP_AVIONES b
WHERE a.avion_id = b.avion_id and b.modelo like 'Airbus%';


--PREGUNTA 5
SELECT a.nombres ||' '|| a.ap_paterno||' '|| a.ap_materno as NOMBRE_COMPLETO,
b.boleto_id, b.nro_serie, b.correlativo, b.fecha_emision
FROM AP_PASAJEROS a, AP_BOLETOS b
WHERE a.ap_paterno IN ('Chávez','Portocarrero')
and a.nombres<>'Jorge';

--PREGUNTA 6
SELECT *
FROM AP_VUELOS;

INSERT INTO AP_VUELOS VALUES ('VM4001','20/05/2025','20/05/2025',105,1,6);
INSERT INTO AP_VUELOS VALUES ('XY0402','21/05/2025','21/05/2025',104,2,3);
INSERT INTO AP_VUELOS VALUES ('ZK0083','22/05/2025','22/05/2025',112,3,10);

--PREGUNTA 7
SELECT *FROM AP_PASAJEROS;
DELETE FROM AP_PASAJEROS
WHERE nro_documento='USA654321' and tipo_documento = 'P';

--PREGUNTA 8
UPDATE AP_EMPLEADOS
SET EMAIL = 'carlos.ruiz.@example.com'
where NOMBRES LIKE '%Carlos%' and AP_PATERNO LIKE '%Ruiz%' and 
AP_MATERNO LIKE '%Díaz%';


--PREGUNTA 9
SELECT * FROM AP_EMPLEADOS;
UPDATE AP_EMPLEADOS
SET SALARIO = SALARIO + SALARIO*0.15;

--PREGUNTA 10
SELECT UPPER( a.ap_paterno || ' ' || a.ap_materno || ',' || a.nombres) 
as NOMBRE_COMPLETO, a.fecha_ingreso
FROM AP_EMPLEADOS a
WHERE (a.fecha_ingreso>='01/01/2024' and a.fecha_ingreso<='31/12/2024') 
and a.activo = 1
ORDER BY a.fecha_ingreso ASC;

