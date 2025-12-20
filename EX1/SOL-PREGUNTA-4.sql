--
SELECT *FROM EX1_CLIENTE;

SELECT *FROM EX1_FACTURA;

SELECT *FROM EX1_VENDEDOR;

SELECT *FROM EX1_ZONA;


--RANKING DE TOP10 VENDEDOR <- ROWNUM DESC 
SELECT *
FROM (SELECT v.id_vendedor as "CODIGO" , v.nombre AS "Nombre Vendedor",
COUNT (DISTINCT f.id_cliente) as "CLIENTES DISTINTOS"
FROM EX1_VENDEDOR v, EX1_CLIENTE C, EX1_FACTURA F
WHERE f.id_cliente = c.id_cliente and 
c.id_zona = v.id_zona and 
f.fecha>='01-04-2025' and fecha<='30-04-2025'
GROUP BY v.id_vendedor ,  v.nombre
ORDER BY "CLIENTES DISTINTOS" desc)
WHERE ROWNUM <=10;


--PREGUNTA B

SELECT v.id_vendedor as "CODIGO VENDEDOR" , v.nombre 
as "NOMBRE VENDEDOR" , SUM(f.total)
FROM EX1_VENDEDOR v, EX1_FACTURA f, EX1_CLIENTE c
WHERE v.id_zona = c.id_zona and f.id_cliente = c.id_cliente 
and f.fecha>= '01-04-2025' and fecha<='30-04-2025'
GROUP BY v.id_vendedor, v.nombre
HAVING SUM(f.total)>=4500
ORDER BY SUM(f.total) desc;
