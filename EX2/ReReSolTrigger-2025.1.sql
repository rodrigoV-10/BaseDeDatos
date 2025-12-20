--
SET SERVEROUTPUT ON;
/
CREATE OR REPLACE PROCEDURE sp_actualiza_precio_venta
IS
          --declaration_section
          /*
          Actualiar columna precio_venta_unitario
          para TODOS (CURSOR) los registros de la tabla detalle_ord_pedido
          el campo precio_venta_unitario es igual al costo_produccion_unitario
          de la tabla ORDEN PRODUCCION AUMENTADO UN 30%
          */
          CURSOR c_registro IS
            SELECT o.costo_produccion_unitario, o.id_orden_produccion
            FROM DETALLE_ORD_PEDIDO d,ORDEN_PRODUCCION o
            WHERE d.id_orden_produccion = o.id_orden_produccion;

BEGIN
            FOR r IN c_registro LOOP
                UPDATE DETALLE_ORD_PEDIDO 
                SET DETALLE_ORD_PEDIDO.precio_venta_unitario = r.costo_produccion_unitario*1.3
                WHERE DETALLE_ORD_PEDIDO.id_orden_produccion = r.id_orden_produccion ;
            END LOOP;
END sp_actualiza_precio_venta;   
/

SELECT * FROM DETALLE_ORD_PEDIDO;
SELECT * FROM ORDEN_PRODUCCION;
SELECT * FROM ORDEN_PEDIDO;

EXEC sp_actualiza_precio_venta;

/
CREATE OR REPLACE PROCEDURE sp_imprimir_detalle_pedido
                (v_id_pedido IN NUMBER)
IS
    CURSOR c_registro IS
        SELECT d.id_tipo_bus, t.nombre , d.cantidad , d.precio_venta_unitario
        FROM DETALLE_ORD_PEDIDO d, TIPO_BUS t
        WHERE d.id_orden_pedido = v_id_pedido and
        d.id_tipo_bus = t.id_tipo_bus
        ;
    v_inicio DATE;
    v_fin DATE;
BEGIN
    SELECT o.fecha_registro, o.fecha_entrega INTO v_inicio, v_fin
    FROM ORDEN_PEDIDO o
    WHERE o.id_orden_pedido=v_id_pedido;
    
    dbms_output.put_line('Pedido: ' || v_id_pedido);
    dbms_output.put_line('Fecha Registro: ' || TO_CHAR(TRUNC(v_inicio),'DD/MM/YYYY') );
    dbms_output.put_line('Fecha Entrega: ' || TO_CHAR(TRUNC(v_fin),'DD/MM/YYYY' )  );
    dbms_output.put_line(' ****************************************** ');
    dbms_output.put_line('ID  TIPO BUS - NOMBRE TIPO BUS -  CANTIDAD - PRECIO VENTA UNITARIO ');
    FOR r IN c_registro LOOP
        dbms_output.put_line(r.id_tipo_bus || '   - ' || r.nombre || '    ' || r.cantidad || '   ' || r.precio_venta_unitario);
    END LOOP;

END sp_imprimir_detalle_pedido;
/

EXEC sp_imprimir_detalle_pedido(10);


--TRIGGERS
--PREGUNTA 3
/
CREATE OR REPLACE TRIGGER first_trigger
BEFORE UPDATE OR INSERT ON SEDE
FOR EACH ROW
DECLARE
--VARIABLES
BEGIN
--PROCESO
    IF updating THEN
        :NEW.FECHA_CREACION := SYSDATE; 
    END IF;
    
    IF inserting THEN
        :NEW.FECHA_CREACION := SYSDATE;
    END IF;
    
    :NEW.FECHA_ULTIMA_MODIFICACION := SYSDATE;
    
END;
/
SELECT * FROM SEDE;

insert into SEDE (id_sede, nombre_sede, distrito, provincia, area_sede, direccion, telefono) values (9, 'Almacen Lima Centro', 'Cercado de Lima', 'Lima', 1200, 'Av Andahuaylas 1258', '999654123'); 


-- PREGUNTA 4


SELECT * FROM ORDEN_PRODUCCION;
SELECT * FROM ORDEN_PEDIDO;
SELECT * FROM DETALLE_ORD_PEDIDO;

CREATE OR REPLACE TRIGGER segundoTrigger
AFTER UPDATE OF COSTO_PRODUCCION_UNITARIO ON ORDEN_PRODUCCION
FOR EACH ROW
DECLARE
--
    aumento NUMBER;
--CUANDO SE ACTUALIZA EL CAMPO DE COSTO_PRODUCCION DE LA TABLA ORDEN_PRODUCCION
--TENGO QUE ACTUALIZAR EL PRECIO_VENTA_UNITARIO DE DETALLE_ORD_PEDIDO
BEGIN
    UPDATE DETALLE_ORD_PEDIDO
    SET PRECIO_VENTA_UNITARIO = :NEW.COSTO_PRODUCCION_UNITARIO*1.30
    WHERE id_orden_produccion = :NEW.id_orden_produccion;
    
END;

update ORDEN_PRODUCCION set costo_produccion_unitario=160000 where id_orden_produccion=5; 

SELECT * FROM DETALLE_ORD_PEDIDO WHERE id_orden_produccion=5;