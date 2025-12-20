--PREGUNTA 5
--
SELECT v.vuelo_id, a1.nombre , a2.nombre , 
TO_CHAR(v.fecha_hora_partida,'DD.MM.YYYY HH:MM'),
TO_CHAR(v.fecha_hora_llegada,'DD.MM.YYYY HH:MM'),
e.nro_documento, e.nombres, e.ap_paterno
FROM AP_VUELOS v,AP_EMPLEADOS e,AP_EMPLEADOS_VUELOS ev,
AP_AEROPUERTOS A1, AP_AEROPUERTOS A2, AP_CARGOS C
WHERE v.vuelo_id = ev.vuelo_id and e.empleado_id = ev.empleado_id
and v.aeropuerto_partida_id = a1.aeropuerto_id and v.aeropuerto_llegada_id 
= a2.aeropuerto_id and e.cargo_id = c.cargo_id

UNION

SELECT v.vuelo_id, a1.nombre, a2.nombre, 
TO_CHAR(v.fecha_hora_partida,'DD.MM.YYYY HH:MM')
, TO_CHAR (v.fecha_hora_llegada,'DD.MM.YYYY HH:MM'),
p.nro_documento, p.nombres, p.ap_paterno
FROM AP_VUELOS v, AP_PASAJEROS p, AP_BOLETOS B, AP_AEROPUERTOS a1,
AP_AEROPUERTOS A2
WHERE v.aeropuerto_partida_id = a1.aeropuerto_id and v.aeropuerto_llegada_id 
= a2.aeropuerto_id;