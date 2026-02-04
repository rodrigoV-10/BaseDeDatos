--Nuevo intento 2025.1

--Pregunta 1
SELECT * FROM AP_VUELOS;
SELECT * FROM AP_AVIONES;
SELECT * FROM AP_MARCAS;


SELECT v.vuelo_id, v.fecha_hora_partida, v.fecha_hora_llegada, v.aeropuerto_partida_id, v.aeropuerto_llegada_id, a.nro_placa, a.modelo
FROM AP_VUELOS v, AP_AVIONES a 
WHERE v.avion_id = a.avion_id and a.modelo Like '%Boeing 737 MAX%';

--Pregunta 2

SELECT * FROM AP_PASAJEROS;
SELECT * FROM AP_BOLETOS;
SELECT * FROM AP_VUELOS;

SELECT v.vuelo_id, v.fecha_hora_partida, v.fecha_hora_llegada, p.tipo_documento,
p.nombres, p.ap_materno, p.ap_materno, p.fecha_nacimiento,p.sexo,
p.email,v.aeropuerto_partida_id, v.fecha_hora_llegada
FROM  AP_PASAJEROS p, AP_BOLETOS b, AP_VUELOS v
WHERE p.pasajero_id=b.pasajero_id and b.vuelo_id=v.vuelo_id and p.nombres='Clara' 
and p.ap_paterno='Rojo' and p.ap_materno='Campos'; 

--Pregunta 3
SELECT * 
FROM AP_PASAJEROS p
--A la fecha le incremento los meses => 18 años * 12 meses
                                            --     1 año
-- y si supera la fecha actual significa que no pasó los 18 años
--la fecha en que cumple 18 años es mayor a la actual
--entonces es menor de edad
WHERE  ADD_MONTHS(p.fecha_nacimiento,12*18)>SYSDATE;

--Pregunta 4

SELECT * FROM AP_AVIONES;
SELECT * FROM AP_MARCAS;
SELECT * FROM AP_MANT_AVIONES;
SELECT * FROM AP_TIPOS_MANTENIMIENTO;

SELECT a.avion_id, a.modelo, m.fecha_fin_est, ROUND (MONTHS_BETWEEN(SYSDATE,m.fecha_fin_est),2) AS CANTIDAD_MESES
FROM AP_AVIONES a, AP_MANT_AVIONES m
WHERE  a.avion_id = m.avion_id and a.modelo LIKE 'Airbus%'
GROUP BY a.avion_id, a.modelo, m.fecha_fin_est;

--Pregunta 5

SELECT * FROM AP_BOLETOS;
SELECT * FROM AP_PASAJEROS;
SELECT * FROM AP_PARENTESCOS;

SELECT
   p2.nombres || ' ' || p2.ap_paterno || ' ' || p2.ap_materno AS nombre_completo,
   b.boleto_id,
   b.nro_serie,
   b.correlativo,
   b.fecha_emision
FROM AP_PASAJEROS p
JOIN AP_PARENTESCOS pa ON p.pasajero_id = pa.pasajero_id
JOIN AP_PASAJEROS p2 ON pa.pariente_id = p2.pasajero_id
JOIN AP_BOLETOS b ON p2.pasajero_id = b.pasajero_id
WHERE UPPER(p.nombres) = 'JORGE'
  AND UPPER(p.ap_paterno) LIKE 'CH%VEZ';
--POR ANALIZAR

--PREGUNTA 6
INSERT INTO AP_VUELOS (VUELO_ID,FECHA_HORA_PARTIDA,FECHA_HORA_LLEGADA,AVION_ID,AEROPUERTO_PARTIDA_ID,AEROPUERTO_LLEGADA_ID) 
VALUES ('VM4001',TO_DATE('20-05-2025','DD-MM-YYYY'),TO_DATE('20-05-2025','DD-MM-YYYY'),105,1,6);

INSERT INTO AP_VUELOS (VUELO_ID,FECHA_HORA_PARTIDA,FECHA_HORA_LLEGADA,AVION_ID,AEROPUERTO_PARTIDA_ID,AEROPUERTO_LLEGADA_ID) 
VALUES ('XY0402',TO_DATE('21-05-2025','DD-MM-YYYY'),TO_DATE('21-05-2025','DD-MM-YYYY'),104,2,3);

INSERT INTO AP_VUELOS (VUELO_ID,FECHA_HORA_PARTIDA,FECHA_HORA_LLEGADA,AVION_ID,AEROPUERTO_PARTIDA_ID,AEROPUERTO_LLEGADA_ID) 
VALUES ('ZK0083',TO_DATE('22-05-2025','DD-MM-YYYY'),TO_DATE('22-05-2025','DD-MM-YYYY'),112,3,10);

--PREGUNTA 7
SELECT * FROM AP_PASAJEROS;

DELETE FROM AP_PASAJEROS
WHERE nro_documento='USA654321' and tipo_documento = 'P';


DELETE FROM AP_PASAJEROS
WHERE NRO_DOCUMENTO = 'USA654321' AND TIPO_DOCUMENTO='P';

ROLLBACK;
DESC AP_VUELOS;
--Pregunta 8
SELECT * FROM AP_EMPLEADOS;

UPDATE AP_EMPLEADOS
SET EMAIL = 'carlos.ruiz@example.com'
WHERE NOMBRES like '%Carlos%' and AP_PATERNO like '%Ruiz%' and AP_MATERNO like '%Díaz%';



--Pregunta 9
SELECT * FROM AP_CARGOS;
SELECT * FROM AP_EMPLEADOS;
UPDATE AP_EMPLEADOS
SET SALARIO = SALARIO + SALARIO*0.15
WHERE CARGO_ID = (SELECT CARGO_ID FROM AP_CARGOS WHERE DETALLE_CARGO = 'Piloto');

--Pregunta 10
SELECT UPPER(e.ap_paterno||' '||e.ap_materno||','||e.nombres) as NOMBRE_COMPLETO, e.fecha_ingreso
FROM AP_EMPLEADOS e
WHERE e.activo=1  and EXTRACT (YEAR FROM e.fecha_ingreso) in ('2024','2025')
ORDER BY FECHA_INGRESO ASC;
