--Try-EX2-2025.2

SET SERVEROUTPUT ON;
--Pregunta 3 
--item a)
SELECT * FROM CITAS_MEDICAS;
SELECT * FROM PERSONALES_MEDICOS;
SELECT * FROM ESPECIALIDADES;
/
CREATE OR REPLACE FUNCTION FN_ESPECIALIDAD_MAS_CITAS(p_mes NUMBER, p_anio NUMBER)
RETURN VARCHAR2
AS
    nombre_espec VARCHAR2(100);
    variable_cantidad NUMBER;
    variable_cantidad_mayor NUMBER ;
    variable_mayor_especialidad VARCHAR2(100);
    CURSOR c_cursor IS
        SELECT e.denominacion , COUNT(*) as cantidad
        FROM citas_medicas c,personales_medicos p, especialidades e
        WHERE p_mes = EXTRACT(MONTH FROM c.fecha_cita) and
        p_anio = EXTRACT (YEAR FROM  c.fecha_cita) and 
        c.personal_id = p.personal_id and p.especialidad_id = e.especialidad_id
        GROUP BY e.denominacion;
        
BEGIN
    variable_cantidad_mayor :=0; 
    OPEN c_cursor;
    LOOP
        FETCH c_cursor INTO nombre_espec , variable_cantidad;
        EXIT WHEN c_cursor%NOTFOUND;
        
        IF variable_cantidad>variable_cantidad_mayor THEN
            variable_cantidad_mayor := variable_cantidad;
            variable_mayor_especialidad := nombre_espec;
        END IF;
    END LOOP;
    CLOSE c_cursor;
    
    IF variable_cantidad_mayor = 0 THEN
            RETURN 'NO EXISTE';
    ELSE
            RETURN variable_mayor_especialidad;
    END IF;
END;
/

/
DECLARE
    v_resultado VARCHAR2(100);
BEGIN
    v_resultado := FN_ESPECIALIDAD_MAS_CITAS(5,2025);
    dbms_output.put_line('La especialidad con más citas es: '||v_resultado);
END;
/
----------------Metodo fabian
create or replace function fn_especialidad_mas_citas(v_mes number,v_anio number)
return VARCHAR2
as
    cursor c_especialidad is select * from ESPECIALIDADES;
    r_especialidad ESPECIALIDADES%rowtype;

    v_contador NUMBER;
    v_max NUMBER;
    v_nom_max VARCHAR2(100);
begin
    v_max:=0;
    open c_especialidad;
    loop
        Fetch c_especialidad into r_especialidad;
        
        exit when c_especialidad%NOTFOUND;
        
        select COUNT(*)into v_contador
        from PERSONALES_MEDICOS P,CITAS_MEDICAS C
        where P.ESPECIALIDAD_ID=r_especialidad.ESPECIALIDAD_ID
            and C.PERSONAL_ID=P.PERSONAL_ID
            and extract(year from C.FECHA_CITA)=v_anio 
            and extract(month from C.FECHA_CITA)=v_mes;
            
        if v_contador>v_max then
            v_max:=v_contador;
            v_nom_max:=r_especialidad.DENOMINACION;
        end if;
        
    end loop;
    
    close c_especialidad;
    
    if v_max=0 then
        return 'NO EXISTE';
    else
        return v_nom_max;
    end if;
    
    
exception
    when NO_DATA_FOUND then
        return 'NO EXISTE';
end;
/
DECLARE
    v_resultado VARCHAR2(100);
BEGIN
    v_resultado :=fn_especialidad_mas_citas(5,2025);
    dbms_output.put_line('La especialidad con mas citas es: ' || v_resultado);
END;
/

--item b)
SELECT * FROM ESPECIALIDADES;
SELECT * FROM PERSONALES_MEDICOS;
SELECT * FROM CITAS_MEDICAS;
SELECT * FROM PACIENTES;
DESC CITAS_MEDICAS;
/
CREATE OR REPLACE PROCEDURE SP_REPORTE_ESPECIALIDAD(p_especialidad VARCHAR2)
AS
    CURSOR c_externo IS
        --le envio el ID del personal que es lo que busca el for interno
        SELECT p.personal_id , p.nombre ||' '|| p.apellidos as NOMBRE_MEDICO
        FROM ESPECIALIDADES e, PERSONALES_MEDICOS p
        WHERE e.denominacion = p_especialidad and e.especialidad_id = p.especialidad_id ;
        
        --cuando el for interno reciba ese id del personal tiene que ser igual para poder imprimir
    CURSOR c_interno (p_id_recibida NUMBER) IS
        SELECT c.fecha_cita, p.nombre ||' '|| p.primer_apellido ||' '|| p.segundo_apellido as NOMBRE_PACIENTE
        FROM CITAS_MEDICAS c, PACIENTES p
        WHERE c.personal_id = p_id_recibida and p.paciente_id = c.paciente_id ;
BEGIN
    dbms_output.put_line('REPORTE DE ESPECIALIDAD : '||p_especialidad);
    --for externo
    FOR externo IN c_externo LOOP
        dbms_output.put_line('Medico: '|| externo.NOMBRE_MEDICO);
        --for interno
        FOR interno IN c_interno(externo.personal_id) LOOP
            dbms_output.put_line(' - ' || interno.NOMBRE_PACIENTE || ' | ' || interno.fecha_cita);
        END LOOP;
        
        
    END LOOP;

END;
/
CALL SP_REPORTE_ESPECIALIDAD('Medicina General');

--Pregunta 4
/
--D : DEPOSITO , R : RETIRO
-- CUENTA S : SOLES , CUENTA D : DOLARES
SELECT * FROM EX2_MONEDA;
SELECT * FROM EX2_TIPOCAMBIO;
SELECT * FROM EX2_CUENTA;
SELECT * FROM EX2_MOVIMIENTO;
DESC EX2_MOVIMIENTO;
/
CREATE OR REPLACE TRIGGER VERIFICA_Y_CALCULA
BEFORE INSERT ON EX2_MOVIMIENTO
FOR EACH ROW
DECLARE
    valor_saldo NUMBER;
    moneda_cuenta CHAR(1);
    SCAMBIOVENTA NUMBER;
    SCAMBIOCOMPRA NUMBER;
    FLAGSOLES BOOLEAN;
    SMONTO NUMBER;
BEGIN
        --valor de la cuenta con su saldo y tipo de moneda
        SELECT c.saldo, c.idmoneda into valor_saldo, moneda_cuenta
        FROM EX2_CUENTA c
        WHERE idcuenta = :new.idcuenta;
    --cuando intenre registrar un retiro , debo de tener dinero
    --caso contrario salta el mensaje de saldo insuficiente
    
        --sacamos el tipo de cambio
        SELECT CAMBIOVENTA, CAMBIOCOMPRA INTO SCAMBIOVENTA, SCAMBIOCOMPRA
        FROM EX2_TIPOCAMBIO
        WHERE fecha = TRUNC(SYSDATE);
        
        IF moneda_cuenta = 'S' THEN
            --es soles
            FLAGSOLES := TRUE;
            SMONTO := :new.montosoles;
        ELSE
            -- es dolares
            FLAGSOLES := FALSE;
            SMONTO := :new.montodolares;
        END IF;
        
        IF :new.idtipomovimiento = 'R' THEN
            --PROCESO DE RETIRO
            --AQUI EL VALOR DEL SALDO YA ESTA EN SOLES Y EL SMONTO TMBN EN SOLES
            --TMBN ESTÁ EN DOLARES DEPENDE DEL TIPO DE MONEDA :)
            IF valor_saldo<SMONTO THEN
                RAISE_APPLICATION_ERROR(-20101,'SIN SALDO SUFICIENTE');
            END IF;
            --AHORA CALCULAMOS EL MONTO EN LA OTRA MONEDA
            IF FLAGSOLES = TRUE THEN
                --SI ESTA EN SOLES CALCULAMOS EL MONTO EN DOLARES
                :new.montodolares :=ROUND(:new.montosoles/SCAMBIOCOMPRA,2);
            ELSE
                --SI ESTAN EN DOLARES CALCULAMOS EL MONTO EN SOLES
                :new.montosoles := ROUND(:new.montodolares*SCAMBIOVENTA,2);
            END IF;
            
        ELSE
            --PROCESO DE DEPOSITO
            --aqui solo se calcula el monto
            IF FLAGSOLES = TRUE THEN
                --SI ESTA EN SOLES CALCULAMOS EL MONTO EN DOLARES
                :new.montodolares :=ROUND(:new.montosoles/SCAMBIOCOMPRA,2);
            ELSE
                --SI ESTAN EN DOLARES CALCULAMOS EL MONTO EN SOLES
                :new.montosoles := ROUND(:new.montodolares*SCAMBIOVENTA,2);
            END IF;
        END IF;
END;
/


--item b)
SELECT * FROM EX2_MONEDA;
SELECT * FROM EX2_TIPOCAMBIO;
SELECT * FROM EX2_CUENTA;
SELECT * FROM EX2_MOVIMIENTO;
DESC EX2_MOVIMIENTO;
/
CREATE OR REPLACE TRIGGER ACTUALIZASALDO
AFTER INSERT ON EX2_MOVIMIENTO
FOR EACH ROW
DECLARE
    SMONEDA CHAR(1);
    
BEGIN
    SELECT idmoneda into smoneda
    FROM EX2_CUENTA
    WHERE idcuenta = :new.idcuenta;

    IF :NEW.idtipomovimiento = 'D' THEN
        --SI ES DEPOSITO INCREMENTA EL SALDO
        IF SMONEDA = 'S' THEN
            --SI ES EN SOLES
            UPDATE EX2_CUENTA
            SET SALDO = SALDO + :NEW.MONTOSOLES
            WHERE idcuenta = :new.idcuenta;
        ELSE
            --SI ES EN DOLARES
            UPDATE EX2_CUENTA
            SET SALDO = SALDO + :NEW.MONTODOLARES
            WHERE idcuenta = :new.idcuenta;
        END IF;
    ELSE
        --SI ES RETIRO DISMINUYE EL SALDO
        IF SMONEDA = 'S' THEN
            --SI EL RETIRO ES EN SOLES
            UPDATE EX2_CUENTA
            SET SALDO = SALDO - :NEW.MONTOSOLES
            WHERE idcuenta = :new.idcuenta;
        ELSE
            --SI EL RETIRO ES EN DOLARES
            UPDATE EX2_CUENTA
            SET SALDO = SALDO - :NEW.MONTODOLARES
            WHERE idcuenta = :new.idcuenta;
        END IF;
    END IF;
END;
/
SELECT *
FROM EX2_CUENTA c, EX2_MOVIMIENTO m
WHERE c.idcuenta=m.idcuenta;