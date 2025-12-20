--PREGUNTA 1

SELECT  UPPER(e.nombre || ' ' || e.ape_paterno || ' ' || e.ape_materno ) 
AS NOMBRE_COMPLETO ,e.fecha_fin_contrato
from EMPLEADO e
WHERE  e.fecha_fin_contrato<ADD_MONTHS(SYSDATE,6) and e.activo='S'
ORDER BY e.fecha_fin_contrato DESC;

--PREGUNTA 2

SELECT o.id_orden_produccion, o.fecha_culminacion,
ROUND (MONTHS_BETWEEN(SYSDATE,o.fecha_culminacion),2) as CANTIDAD_MESES
FROM ORDEN_PRODUCCION o
WHERE e.fecha_culminacion between date '2024-01-01' and date '2024-06-30'
ORDER BY fecha_culminacion;