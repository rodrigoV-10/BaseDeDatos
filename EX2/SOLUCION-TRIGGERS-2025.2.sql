SET SERVEROUTPUT ON;



SELECT * FROM EX2_MOVIMIENTO;
SELECT * FROM EX2_TIPOMOVIMIENTO;
SELECT * FROM EX2_TIPOCAMBIO;
SELECT * FROM EX2_CUENTA;
SELECT * FROM EX2_MONEDA;

UPDATE EX2_TIPOCAMBIO SET FECHA = SYSDATE WHERE FECHA = '02/12/2025';


--Trigger que verifique cuando se pretenda registrar un reto el monto debe tener saldo suficiente
--si no hay monto suficiente entonces debe mostrar el mensaje
--primero depositas luego retiras -> fijate en la imagen
--determine también el monto en la otra moneda
-- si la cuenta es en soles , debera calcular el monto en dolares
-- si la cuenta es en dolares, deberá calcular el monto en soles
--si es deposito se determinará el monto en la otra moneda
/
CREATE OR REPLACE TRIGGER VERIFICA_Y_CALCULA
BEFORE INSERT ON EX2_MOVIMIENTO
FOR EACH ROW
DECLARE
    v_moneda_cuenta CHAR (1);
    v_saldo_actual NUMBER;
    v_cambioventa NUMBER;
    v_cambiocompra NUMBER;
BEGIN
    
    --tengo que sacar el saldo de la persona
    SELECT SALDO , IDMONEDA INTO v_saldo_actual , v_moneda_cuenta
    FROM EX2_CUENTA
    WHERE IDCUENTA = :NEW.IDCUENTA;
    
    --obtener tipo de cambio de acuerdo a la fecha
    SELECT cambioventa , cambiocompra INTO v_cambioventa, v_cambiocompra
    FROM  EX2_TIPOCAMBIO
    WHERE TO_CHAR(fecha,'DD/MM/YYYY') = TO_CHAR(:NEW.fecha,'DD/MM/YYYY');
    
    
    --VAMOS A DETERMINAR EL MONTO
    --DETERMINAR EL MONTO EN LA OTRA MONEDA
    IF :NEW.MONTOSLES >0 AND (:NEW.MONTODOLARES IS NULL OR :NEW.MONTODOLARES =0) THEN
        IF :NEW.IDTIPOMOVIMIENTO = 'D' THEN
            :NEW.MONTODOLARES := ROUND(:NEW.MONTOSOLES/v_cambioventa,2);
        ELSIF :NEW.IDTIPOMOVIMIENTO = 'R' THEN
            :NEW.MONTODOLARES := ROUND(:NEW.MONTOSOLES/v_cambioventa,2);
        END IF;
     ELSIF :NEW.MONTODOLARES>0 AND (:NEW.MONTODOLARES IS NULL OR :NEW.MONTODOLARES =0) THEN
        IF :NEW.IDTIPOMOVIMIENTO = 'D' THEN
            :NEW.MONTOSOLES := ROUND(:NEW.MONTOSOLES*v_cambiocompra,2);
        ELSIF :NEW.IDTIPOMOVIMIENTO = 'R' THEN
            :NEW.MONTOSOLES := ROUND(:NEW.MONTOSOLES*v_cambiocompra,2);
        END IF;
    END IF;
    ---------------------------------
    --LUEGO VERIFICO EL RETIRO
    IF :NEW.IDTIPOMOVIMIENTO = 'R' THEN
        IF v_moneda_cuenta = 'S' THEN
            IF v_saldo_actual < :NEW.MONTOSOLES THEN
                RAISE_APPLICATION_ERROR('-20101','SIN SALDO SUFICIENTE');
            END IF;
        ELSIF v_moneda_cuenta = 'D' THEN
            IF v_saldo_actual<:NEW.MONTODOLARES THEN
                RAISE_APPLICATION_ERROR('-20101','SIN SALDO SUFICIENTE');
            END IF;
        END IF;
    END IF;
    
END;
/



--TRIGER ACTUALIZA SALDO
CREATE OR REPLACE TRIGGER ACTUALIZASALDO
AFTER INSERT ON EX2_MOVIMIENTO
FOR EACH ROW
DECLARE
     v_moneda_cuenta CHAR (1);
BEGIN
    SELECT idmoneda INTO v_moneda_cuenta
    FROM EX2_CUENTA
    WHERE IDCUENTA = :NEW.IDCUENTA;
    
    
    IF v_moneda_cuenta = 'S' THEN
        IF :NEW.IDTIPOMOVIMIENTO = 'D' THEN
            UPDATE EX2_CUENTA SET SALDO = SALDO + :NEW.MONTOSOLES WHERE IDCUENTA = :NEW.IDCUENTA;
        ELSIF :NEW.IDTIPOMOVIMIENTO = 'R' THEN
            UPDATE EX2_CUENTA SET SALDO = SALDO - :NEW.MONTOSOLES WHERE IDCUENTA = :NEW.IDCUENTA;
        END IF;
    ELSIF v_moneda_cuenta = 'D' THEN
        IF :NEW.IDTIPOMOVIMIENTO = 'D' THEN --WHERE IDCUENTA = :NEW.IDCUENTA;
            UPDATE EX2_CUENTA SET SALDO = SALDO + :NEW.MONTODOLARES;
        ELSIF :NEW.IDTIPOMOVIMIENTO = 'R' THEN
            UPDATE EX2_CUENTA SET SALDO = SALDO - :NEW.MONTODOLARES;
        END IF;
    END IF;
END;


SELECT * FROM EX2_MOVIMIENTO;
SELECT * FROM EX2_TIPOMOVIMIENTO;
SELECT * FROM EX2_TIPOCAMBIO;
SELECT * FROM EX2_CUENTA;
SELECT * FROM EX2_MONEDA;