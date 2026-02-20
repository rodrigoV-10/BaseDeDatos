-- 2025-0:

-- PREGUNTA 1:

SELECT* FROM L5_VENTAS;

create or replace PROCEDURE SP_CREAR_CABECERA_DOCUMENTO (  
    p_cliente_id    NUMBER,
    p_fecha_ventas  DATE
) AS
    v_nueva_venta_id NUMBER;
BEGIN
    -- NVL: En caso la informacion devuelta sea NULL => Devolver DEFAULT
   SELECT NVL(MAX(VENTA_ID),0) + 1 
   INTO v_nueva_venta_id
   FROM L5_VENTAS;
   
   INSERT INTO L5_VENTAS(
    VENTA_ID, CLIENTE_ID,FECHA_VENTA,TOTAL_BRUTO,TOTAL_DESCUENTOS, TOTAL_NETO, 
    METODO_PAGO,CODIGO_AUTORIZACION, CENTRO_COSTO
   ) VALUES (
    v_nueva_venta_id, p_cliente_id, p_fecha_ventas,
    0,0,0,'EFECTIVO','AUT012','CC-BIB-2024'
   );
END;

EXEC SP_CREAR_CABECERA_DOCUMENTO(2,'08/11/2025');

-- PREGUNTA 2:

CREATE OR REPLACE FUNCTION FN_APLICAR_DESCUENTO(
    v_cliente   NUMBER,
    v_fecha     DATE,
    v_producto  NUMBER
) RETURN VARCHAR2 AS 
    v_desc_tipo_cliente NUMBER;
    v_desc_campania NUMBER;
    v_desc_campania_PRODUCTO NUMBER;
BEGIN

    SELECT PORCENTAJE_DESCUENTO INTO v_desc_tipo_cliente
    FROM L5_CLIENTES C, L5_TIPOS_CLIENTE CL, L5_PRECIOS_TIPO_CLIENTE TC
    WHERE C.TIPO_CLIENTE_ID = CL.TIPO_CLIENTE_ID
    AND CL.TIPO_CLIENTE_ID = TC.TIPO_CLIENTE_ID
    AND C.CLIENTE_ID = v_cliente AND tc.producto_id=v_producto;
    
    SELECT MAX(C.PORCENTAJE_DESCUENTO) INTO v_desc_campania
    FROM L5_CAMPANIAS C
    WHERE C.FECHA_FIN >= v_fecha;
    
    SELECT MAX(PORCENTAJE_DESCUENTO) INTO v_desc_campania_PRODUCTO
    FROM L5_CAMPANIAS_PRODUCTOS
    WHERE PRODUCTO_ID = 3;
    
    IF v_desc_tipo_cliente > v_desc_campania AND v_desc_tipo_cliente > v_desc_campania_PRODUCTO THEN
        RETURN v_desc_tipo_cliente;
    ELSIF v_desc_campania > v_desc_tipo_cliente AND v_desc_campania> v_desc_campania_PRODUCTO THEN
        RETURN v_desc_campania;
    ELSIF v_desc_campania_PRODUCTO > v_desc_tipo_cliente AND v_desc_campania_PRODUCTO > v_desc_campania THEN
        RETURN v_desc_campania_PRODUCTO;
    END IF;
END;

SELECT FN_APLICAR_DESCUENTO('5','01/12/24', '3') FROM DUAL;

-- VALIDACIÓN:
SELECT*
FROM L5_CLIENTES C, L5_TIPOS_CLIENTE CL, L5_PRECIOS_TIPO_CLIENTE TC
WHERE C.TIPO_CLIENTE_ID = CL.TIPO_CLIENTE_ID
AND CL.TIPO_CLIENTE_ID = TC.TIPO_CLIENTE_ID
AND c.cliente_id = 5 AND tc.producto_id=3;

SELECT *
    FROM L5_CAMPANIAS C, L5_CAMPANIAS_PRODUCTOS CP
    WHERE C.CAMPANIA_ID = CP.CAMPANIA_ID
    AND C.FECHA_FIN >= '01/12/24';
    
SELECT PORCENTAJE_DESCUENTO
FROM L5_CAMPANIAS_PRODUCTOS
WHERE PRODUCTO_ID = 3;

-- PREGUNTA 3:

SELECT*FROM L5_ORDENES_COMPRA;
SELECT*FROM l5_ordenes_compra_detalle;

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE SP_GENERAR_ORDEN_COMPRA(
    p_producto_id   NUMBER,
    p_cantidad      NUMBER,
    p_editorial_id  NUMBER
) AS
    v_id    NUMBER;
    v_precio_base NUMBER;
    v_precio_unitario   NUMBER;
    v_costo_logistico   NUMBER;
    v_presupuesto       NUMBER;
BEGIN
    SELECT NVL(MAX(ORDEN_COMPRA_ID),0) +1
    INTO v_id
    FROM L5_ORDENES_COMPRA;

    SELECT PRECIO_BASE INTO v_precio_base
    FROM L5_PRODUCTOS
    WHERE PRODUCTO_ID = p_producto_id;

    v_precio_unitario := v_precio_base*0.5;
    v_presupuesto := v_precio_base*p_cantidad;
    v_costo_logistico := v_presupuesto*0.10;
    
    INSERT INTO L5_ORDENES_COMPRA VALUES (
        v_id,p_editorial_id, SYSDATE, SYSDATE +7,
        'EXTRAORDINARIA','EN_PROCESO',v_presupuesto,
        v_costo_logistico,'FALTA DE STOCK'
    );
    
    INSERT INTO  l5_ordenes_compra_detalle VALUES(
        v_id,p_producto_id,p_cantidad,v_precio_unitario
    );
    
    DBMS_OUTPUT.PUT_LINE('Orden de Compra '||v_id||' ingresada');
END;

SELECT PRECIO_BASE --INTO v_precio_base
FROM L5_PRODUCTOS
WHERE PRODUCTO_ID = 2;

SELECT*FROM L5_PRODUCTOS;

EXEC SP_GENERAR_ORDEN_COMPRA (2,10,2);

-- PREGUNTA 4:

CREATE OR REPLACE FUNCTION FN_VERIFICAR_STOCK(
    p_producto_id   NUMBER,
    p_cantidad      NUMBER
) RETURN NUMBER AS
    v_stock_actual  NUMBER;
BEGIN
    SELECT STOCK_ACTUAL INTO v_stock_actual
    FROM L5_PRODUCTOS
    WHERE PRODUCTO_ID = p_producto_id;
    
    RETURN v_stock_actual - p_cantidad;
END;

SELECT FN_VERIFICAR_STOCK(3,10) FROM DUAL;

-- PREGUNTA 5:
-- INVOCACIÓN DE FUCIONES O PROCEDIMIENTOS

CREATE OR REPLACE PROCEDURE SP_GENERARVENTA_PRODUCTO(
    p_cliente_id NUMBER,
    p_fecha_venta Date,
    p_producto_id   NUMBER,
    p_cantidad      NUMBER
) as
    v_diff  NUMBER;
    v_desc  NUMBER;
    v_nueva_venta_id NUMBER;
    v_precio NUMBER; 
    v_editorial_id NUMBER;
    v_stock_min NUMBER;
    v_stock_seg NUMBER;
BEGIN
    -- 1. Verificar Stock:
    v_diff := FN_VERIFICAR_STOCK(p_producto_id,p_cantidad);
    
    IF v_diff < 0 THEN
        DBMS_OUTPUT.PUT_LINE('NO HAY STOCK SUFICIENTE');
        RETURN;
    END IF;

    -- 2. Hacer la cabecera:
    SP_CREAR_CABECERA_DOCUMENTO(p_cliente_id,p_fecha_venta);

    -- 3. Aplicar descuento:
    v_desc := FN_APLICAR_DESCUENTO(p_cliente_id,p_fecha_venta,p_producto_id);

    SELECT MAX(VENTA_ID) INTO v_nueva_venta_id
    FROM L5_VENTAS;
    
    SELECT precio_base, editorial_id, stock_minimo,stock_seguridad
    INTO v_precio, v_editorial_id, v_stock_min, v_stock_seg
    FROM L5_PRODUCTOS
    WHERE producto_id = p_producto_id;
    
    INSERT INTO L5_VENTAS_DETALLE VALUES(
        v_nueva_venta_id,
        p_producto_id,
        p_cantidad,
        v_precio,
        v_desc,
        0,
        v_precio - (v_precio*v_desc/100),
        NULL
    );
    
    -- 4. Actualizar STOCK:
    UPDATE L5_PRODUCTOS
    SET stock_actual = stock_actual - p_cantidad
    WHERE PRODUCTO_ID = p_producto_id;
    
    -- 5. Validar compra:
    
    SELECT stock_actual INTO v_diff
    FROM L5_PRODUCTOS 
    WHERE PRODUCTO_ID = p_producto_id;
    
    IF v_diff <= v_stock_min THEN
        SP_GENERAR_ORDEN_COMPRA(p_producto_id,p_cantidad,v_editorial_id);
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Venta generada correctamente');
END;

EXEC SP_GENERARVENTA_PRODUCTO( 2,SYSDATE,1,2);

