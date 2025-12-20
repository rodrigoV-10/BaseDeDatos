--EXAMEN 1 - 2025.1
SELECT V.vuelo_id, A1.nombre, A2.nombre,    
              TO_CHAR( V.fecha_hora_partida,'DD.MM.YYYY HH:MM'), 
              TO_CHAR( V.fecha_hora_llegada,'DD.MM.YYYY HH:MM'), 
              E.nro_documento,E.nombres, E.ap_paterno, E.detalle_cargo 
FROM AP_VUELOS V, AP_EMPLEADOS E, AP_EMPLEADOS_VUELOS EV,  
            AP_AEROPUERTOS A1,  AP_AEROPUERTOS A2, AP_CARGOS C 
WHERE V.vuelo_id = EV.vuelo_id  AND E.empleado_id = EV.empleado_id 
               AND V.aeropuerto_partida_id = A1.aeropuerto_id 
               AND V.aeropuerto_llegada_id = A2.aeropuerto_id 
               AND  E.cargo_id = C.cargo_id 

--VUELO ID - AEORPUERTO PARTIDA - AEROPUERTO LLEGADA 
-- HORA PARTIDA - HORA LLEGADA
-- NUMERO DOCUMENTO - NOMBRE - AP PATERNO - DETALLE CARGO