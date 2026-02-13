--Try 2024.2
--Pregunta 1
SELECT * FROM CLIENTE;
SELECT * FROM EMPLEADO;
SELECT *
FROM EMPLEADO
WHERE fecha_fin_contrato >= ADD_MONTHS(SYSDATE,6);

--Pregunta 2
SELECT * FROM ORDEN_PRODUCCION;
SELECT o.id_orden_produccion,o.fecha_culminacion ,round(MONTHS_BETWEEN(SYSDATE,o.fecha_culminacion),2) as cantidad_meses
FROM ORDEN_PRODUCCION o
WHERE EXTRACT (MONTH FROM o.fecha_culminacion) IN (1,2,3,4,5,6); 

--pregunta 3
SELECT * FROM ORDEN_PRODUCCION;
SELECT * FROM DETALLE_ORD_PRODUCCION;

SELECT d.articulo, MIN(d.cantidad) AS MINIMO , MAX (d.cantidad) AS MAXIMO 
FROM DETALLE_ORD_PRODUCCION d , ORDEN_PRODUCCION o
WHERE o.id_orden_produccion = d.id_orden_produccion 
GROUP BY d.articulo;

--Pregunta 4
SELECT * FROM SEDE;
SELECT * FROM ORDEN_PEDIDO;

SELECT s.id_sede, s.nombre_sede, COUNT(o.id_sede)
FROM SEDE s, ORDEN_PEDIDO o
WHERE s.id_sede = o.id_sede and 
EXTRACT (YEAR FROM o.fecha_entrega) = 2024
GROUP BY s.id_sede, s.nombre_sede;


--Pregunto 5
SELECT * FROM CLIENTE;
SELECT * FROM TIPO_BUS;
SELECT * FROM ORDEN_PEDIDO;
SELECT * FROM DETALLE_ORD_PEDIDO;
--listar los clientes que adquirieron tipo de bus 1 y 2

SELECT DISTINCT c.id_cliente, c.razon_social
FROM CLIENTE c, tipo_bus t, orden_pedido o, detalle_ord_pedido d
WHERE c.id_cliente = o.id_cliente and o.id_orden_pedido=d.id_orden_pedido and t.id_tipo_bus in (1,2) ;


--Pregunta 6
SELECT * FROM CLIENTE;
SELECT * FROM TIPO_BUS;
SELECT * FROM ORDEN_PEDIDO;
SELECT * FROM DETALLE_ORD_PEDIDO;

SELECT t.nombre, SUM(d.cantidad) as CANTIDAD
FROM  tipo_bus t, detalle_ord_pedido d
WHERE d.id_tipo_bus = t.id_tipo_bus
GROUP BY t.nombre
HAVING SUM(d.cantidad)>40;

--Pregunta 7
SELECT * FROM FORMA_PAGO;
SELECT * FROM ORDEN_PEDIDO;
SELECT * FROM DETALLE_ORD_PEDIDO;
SELECT * FROM CLIENTE;

SELECT f.nombre_forma_pago , SUM(d.cantidad)
FROM FORMA_PAGO f, ORDEN_PEDIDO o, DETALLE_ORD_PEDIDO d
WHERE f.id_forma_pago = o.id_forma_pago and d.id_orden_pedido = o.id_orden_pedido
GROUP BY f.nombre_forma_pago ;
