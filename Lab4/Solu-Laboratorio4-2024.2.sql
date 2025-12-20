--PREGUNTA 1
SET SERVEROUTPUT ON;
/
SELECT * FROM DETALLE_ORD_PEDIDO;
SELECT * FROM ORDEN_PRODUCCION;

/
CREATE OR REPLACE PROCEDURE sp_actualiza_precio_venta
            
AS
    CURSOR c_registro IS
    SELECT ord.costo_produccion_unitario, d.id_orden_produccion
    FROM DETALLE_ORD_PEDIDO d , ORDEN_PRODUCCION ord
    WHERE d.id_orden_produccion = ord.id_orden_produccion;
BEGIN
    
    FOR r IN c_registro LOOP
        update DETALLE_ORD_PEDIDO
        SET  DETALLE_ORD_PEDIDO.precio_venta_unitario = r.costo_produccion_unitario*1.3
        WHERE r.id_orden_produccion = detalle_ord_pedido.id_orden_produccion;
    END LOOP;
END;
/

EXEC sp_actualiza_precio_venta;

--PREGUNTA 2


SELECT * FROM ORDEN_PEDIDO;

/
CREATE OR REPLACE PROCEDURE sp_imprimir_detalle_pedido
                        (v_id_ped IN NUMBER)
AS
    --DECLARACION DEL CURSOR
    existe_pedido NUMBER :=0;
    CURSOR ped_info IS
    SELECT bus.id_tipo_bus, bus.nombre, detalle.cantidad, detalle.precio_venta_unitario
    FROM orden_pedido orden, detalle_ord_pedido detalle, tipo_bus bus
    WHERE orden.id_orden_pedido = v_id_ped and orden.id_orden_pedido = detalle.id_orden_pedido
    and detalle.id_tipo_bus = bus.id_tipo_bus;
    

BEGIN
    SELECT COUNT(*) INTO existe_pedido
    FROM ORDEN_PEDIDO ord
    WHERE ord.id_orden_pedido = v_id_ped;
    IF existe_pedido>0 THEN
        --PROCESO
        --USO DEL CURSOR
        FOR r IN ped_info LOOP
            --concatenar 
            dbms_output.put_line(r.nombre);
            
        END LOOP;   
    ELSE
        dbms_output.put_line('El pedido no existe');
    END IF;
END;
/

EXEC sp_imprimir_detalle_pedido(10);
/

SELECT * FROM SEDE;


-- PREGUNTA 3
--TRIGGERS
/
CREATE OR REPLACE TRIGGER first_triger
BEFORE UPDATE OR INSERT ON SEDE
FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.FECHA_CREACION := SYSDATE;
    END IF;
    :new.FECHA_ULTIMA_MODIFICACION:= SYSDATE;
END;
/

insert into SEDE (id_sede, nombre_sede, distrito, provincia, area_sede, direccion, telefono) values (11,
'Almacen Lima Centro', 'Cercado de Lima', 'Lima', 1200, 'Av Andahuaylas 1258', '999654123');


--PREGUNTA 4
SELECT * FROM DETALLE_ORD_PEDIDO;
SELECT * FROM ORDEN_PRODUCCION;
/
CREATE OR REPLACE TRIGGER second_triger
AFTER UPDATE ON ORDEN_PRODUCCION
FOR EACH ROW
DECLARE
    precio_insertar NUMBER;
BEGIN 
    --IF updating THEN
        precio_insertar:= :new.costo_produccion_unitario*1.30;
        UPDATE DETALLE_ORD_PEDIDO SET precio_venta_unitario = precio_insertar
        WHERE id_orden_produccion = :new.id_orden_produccion;
    --END IF;
END;
/

update ORDEN_PRODUCCION set costo_produccion_unitario=160000 where id_orden_produccion=5; 