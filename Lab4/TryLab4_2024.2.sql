--TryLab4 - 2024.2
SET SERVEROUTPUT ON;

--PREGUNTA 1
/
SELECT * FROM DETALLE_ORD_PEDIDO;
SELECT * FROM ORDEN_PRODUCCION;
/

/
CREATE OR REPLACE PROCEDURE SP_ACTUALIZA_PRECIO_VENTA
AS
     CURSOR c_cursor IS
        SELECT o.costo_produccion_unitario, d.id_orden_produccion
        FROM DETALLE_ORD_PEDIDO d, ORDEN_PRODUCCION O
        WHERE d.id_orden_produccion = o.id_orden_produccion ;

BEGIN
    FOR r in c_cursor LOOP
        UPDATE DETALLE_ORD_PEDIDO
        SET DETALLE_ORD_PEDIDO.PRECIO_VENTA_UNITARIO = r.costo_produccion_unitario*(1.3)
        WHERE DETALLE_ORD_PEDIDO.id_orden_produccion = r.id_orden_produccion;
    END LOOP;

END;
/

EXEC SP_ACTUALIZA_PRECIO_VENTA;

--PREGUNTA 2
SELECT * FROM ORDEN_PEDIDO;
SELECT * FROM DETALLE_ORD_PEDIDO;
SELECT * FROM TIPO_BUS;
DESC ORDEN_PEDIDO;
/
CREATE OR REPLACE PROCEDURE SP_IMPRIMIR_DETALLE_PEDIDO(p_id CHAR)
AS
    v_existe_pedido NUMBER;
    
    CURSOR registro_cursor IS
        SELECT t.id_tipo_bus,t.nombre,d.cantidad, d.precio_venta_unitario
        FROM ORDEN_PEDIDO o, DETALLE_ORD_PEDIDO d, TIPO_BUS t
        WHERE p_id = o.id_orden_pedido and o.id_orden_pedido = d.id_orden_pedido and d.id_tipo_bus = t.id_tipo_bus ; 
    
BEGIN
    SELECT COUNT (*) INTO v_existe_pedido
    FROM ORDEN_PEDIDO o
    WHERE o.id_orden_pedido = p_id ;
    
    IF v_existe_pedido!=0 THEN
        --ENTRA AL CURSOR Y MUESTRA LOS DATOS
        --dbms_output.put_line('Existe');
        FOR r IN registro_cursor LOOP
            dbms_output.put_line(r.id_tipo_bus || '  -  ' || r.nombre || '   -   '  || r.cantidad  || '  -  ' || r.precio_venta_unitario);
        END LOOP;
        
    ELSE
        dbms_output.put_line('El pedido no existe');
    END IF;
    
END;
/
EXEC SP_IMPRIMIR_DETALLE_PEDIDO(10);


--PREGUNTA 3
SELECT * FROM SEDE;
/
CREATE OR REPLACE TRIGGER TR_FECHAS
BEFORE INSERT OR UPDATE ON SEDE
FOR EACH ROW
DECLARE
    
BEGIN
    IF inserting THEN
        :new.FECHA_CREACION := SYSDATE;
    ELSIF updating THEN
        :new.FECHA_CREACION := SYSDATE;
    END IF;
    :new.fecha_ultima_modificacion := SYSDATE;
END;
/
insert into SEDE (id_sede, nombre_sede, distrito, provincia, area_sede, direccion, telefono) values (9,'Almacen Lima Centro', 'Cercado de Lima', 'Lima', 1200, 'Av Andahuaylas 1258', '999654123'); 


--Pregunta 4
SELECT * FROM ORDEN_PRODUCCION;
SELECT * FROM DETALLE_ORD_PEDIDO WHERE ID_ORDEN_PRODUCCION=5;
/
CREATE OR REPLACE TRIGGER TR_ACTUALIZAR_COSTO
BEFORE UPDATE OF COSTO_PRODUCCION_UNITARIO ON ORDEN_PRODUCCION 
FOR EACH ROW
DECLARE

BEGIN
    UPDATE DETALLE_ORD_PEDIDO
    SET PRECIO_VENTA_UNITARIO = PRECIO_VENTA_UNITARIO*(1.3);
END;
/
update ORDEN_PRODUCCION set costo_produccion_unitario=160000 where id_orden_produccion=5;

