-- PREG 1
select UPPER(nombre) || ' ' || UPPER(ape_paterno) || ' ' || UPPER(ape_materno) as nombre_completo, fecha_fin_contrato
from Empleado e
WHERE fecha_fin_contrato < ADD_MONTHS(SYSDATE,6) and e.activo = 'S'
ORDER BY 2 DESC;

-- PREG 2
select 	o.id_orden_produccion  , o.fecha_culminacion,
round(MONTHS_BETWEEN(sysdate, o.fecha_culminacion), 2) as cantidad_meses
from ORDEN_PRODUCCION o
where to_number(to_char(o.fecha_culminacion,'YYYY') ) = 2024 
and to_number(to_char(o.fecha_culminacion,'MM') ) between 1 and 6;


-- PREG 3
SELECT articulo, MIN(cantidad) as Minimo, MAX(cantidad) as Maximo
FROM DETALLE_ORD_PRODUCCION
GROUP BY articulo;


-- PREG 4
select s.id_sede , s.nombre_sede, count(*) 
from ORDEN_PEDIDO o, SEDE s
where o.id_sede = s.id_sede
and to_number(to_char(o.fecha_entrega,'YYYY')) = 2024 
group by s.id_sede, s.nombre_sede;


-- PREG 5
select distinct c.id_cliente, c.razon_social
from CLIENTE c, ORDEN_PEDIDO o, DETALLE_ORD_PEDIDO d
where o.id_cliente = c.id_cliente
and o.id_orden_pedido = d.id_orden_pedido
and d.id_tipo_bus in (1,2);


-- PREG 6
select t.nombre, sum(d.cantidad) as cantidad
from DETALLE_ORD_PEDIDO d, TIPO_BUS t
where d.id_tipo_bus = t.id_tipo_bus
group by t.nombre
having sum(d.cantidad) > 40;


-- PREG 7
select f.nombre_forma_pago , sum(d.cantidad) as cantidad  
from ORDEN_PEDIDO o, DETALLE_ORD_PEDIDO d, FORMA_PAGO f
where o.id_orden_pedido = d.id_orden_pedido
and o.id_forma_pago= f.id_forma_pago
group by f.nombre_forma_pago;

