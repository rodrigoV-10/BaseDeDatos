--Pregunta 1


/

CREATE OR REPLACE FUNCTION fn_total_buses_tipo(
                    v_tipo CHAR)
RETURN NUMBER
AS
    v_existe NUMBER;
    v_total NUMBER;
--DECLARACION DE VARIABLES
BEGIN
    --QUERYS
    SELECT COUNT(*)INTO v_existe
    FROM TIPO_BUS
    WHERE v_tipo = id_tipo_bus;
    
    IF v_existe = 0 THEN
        RETURN 0;
    END IF;
    
    SELECT NVL(SUM(CANTIDAD),0) INTO v_total
    FROM DETALLE_ORD_PEDIDO
    WHERE id_tipo_bus = v_tipo;
    
    RETURN v_total;
    
END fn_total_buses_tipo;

/
SELECT *FROM TIPO_BUS;
SELECT *FROM DETALLE_ORD_PEDIDO;

SELECT fn_total_buses_tipo(1) FROM DUAL;

/
--PREGUNTA 2
CREATE OR REPLACE FUNCTION fn_eficiencia_entrega_sede (
          v_sede CHAR)
          RETURN NUMBER
AS
    --DECLARACION DE VARIABLES
    v_existe_sede NUMBER;
    v_total NUMBER;
    v_a_tiempo NUMBER;
    v_porcentaje NUMBER;
BEGIN
    --QUERYS
    --validar que existe sede
    -- si la sede no tiene ordenes retornar 0
    --el porcentaje debe estar entre 0 y 100 decimales
    --solo considerar ordenes con fecha de entrega no nula
    SELECT COUNT(*) INTO v_existe_sede
    FROM SEDE
    WHERE id_sede = v_sede;
    
    IF v_existe_sede = 0 THEN
        RETURN 0;
    END IF;
    
    SELECT COUNT(*) INTO v_total
    FROM ORDEN_PEDIDO
    WHERE id_sede = v_sede
    and fecha_entrega is not null;
    
    IF v_total = 0 THEN
        RETURN 0
    END IF;
    
    
    

END fn_eficiencia_entrega_sede;
/

SELECT *FROM SEDE;


/

/*

validar no id existe
razon social not null
ruc not null
telefono not null
correo not null
impresion por consola :)

*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE sp_registrar_cliente
       (v_id CHAR , v_razon_social CHAR , v_ruc CHAR ,
       v_telefono CHAR , v_correo CHAR , v_direccion CHAR)
IS
        --Variables
        v_existe NUMBER;
        v_ok BOOLEAN := TRUE;
        
BEGIN
        --QUERYS
        SELECT COUNT(*) INTO v_existe
        FROM CLIENTE
        WHERE v_id = id_cliente;
        
        IF v_existe>0 THEN
            DBMS_OUTPUT.PUT_LINE('Error: El ID de cliente '||v_id || ' ya existe');
            RETURN;
        END IF;
          
END sp_registrar_cliente;
/


EXEC sp_registrar_cliente(9, 'Transportes Express', '20505050505', '998877665', 'contact@express.com', 'Av. Principal 123');
SELECT *FROM CLIENTE;

EXEC sp_registrar_cliente(1, 'Nueva Empresa', '20606060606', '999999999','info@nueva.com', 'Calle Nueva 789'); 










