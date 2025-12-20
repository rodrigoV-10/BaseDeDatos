--
select  A.nombre as Pais_origen, T.descripcion as Tipo, count(*) 
Cantidad 
from l1_tipocanal T, l1_canal C, l1_pais A 
where T.id_tipocanal=C.id_tipocanal and A.id_pais= C.id_pais 
group by  A.nombre , T.descripcion 
having count(*)>1 
order by 1;

SELECT *
FROM (
    SELECT rat.id_canal as NUMERO, c.nombre as NOMBRE, cat.nombre AS CATEGORIA
    FROM L1_CANAL c, L1_CATEGORIA cat, L1_RATING rat
    WHERE c.id_categoria = cat.id_categoria 
    and rat.id_canal = c.id_canal  and to_char(rat.fechahorainicio,'HH24')>='18' and 
    to_char(rat.fechaHorafin,'HH24')<='22'
    GROUP BY rat.id_canal, c.nombre, cat.nombre)
    --ORDER BY 4 DESC
WHERE ROWNUM <=5;