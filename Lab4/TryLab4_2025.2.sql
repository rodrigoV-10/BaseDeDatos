--Try2025.2 >:)


--Pregunta 1
SET SERVEROUTPUT ON;
/
SELECT * FROM PACIENTES;
DESC PACIENTES;
SELECT * FROM BOLETAS;
SELECT * FROM BOLETAS_MEDICAMENTOS;
SELECT * FROM MEDICAMENTOS;
SELECT * FROM RECETAS_MEDICAMENTOS;
SELECT * FROM RECETAS_MEDICAS;
DESC RECETAS_MEDICAS;
/
DECLARE
    CURSOR c_paciente IS
        SELECT r.receta_id ,p.nombre, p.primer_apellido , p.segundo_apellido
        FROM PACIENTES p, ATENCIONES_MEDICAS a, RECETAS_MEDICAS r
        WHERE r.fecha_emision = TO_DATE('17/05/2025','DD/MM/YYYY') and p.paciente_id = a.paciente_id
        and a.atencion_id = r.atencion_id; 
        
    CURSOR c_medicamento (p_id NUMBER) IS
        SELECT m.denominacion, rm.cantidad_dosis, rm.via_administracion
        FROM  ATENCIONES_MEDICAS a, RECETAS_MEDICAS r,  RECETAS_MEDICAMENTOS rm ,MEDICAMENTOS m
        WHERE  p_id = r.receta_id and a.atencion_id = r.atencion_id and r.receta_id = rm.receta_id
        and rm.medicamento_id = m.medicamento_id;
    
BEGIN
    FOR r IN c_paciente LOOP
        dbms_output.put_line('Paciente : ' || r.nombre || ' ' || r.primer_apellido 
        || ' ' || r.segundo_apellido);
        FOR interno IN c_medicamento (r.receta_id) LOOP
            dbms_output.put_line(interno.denominacion || ' - Cantidad: ' || interno.cantidad_dosis || ' - Administracion: ' || interno.via_administracion);
        END LOOP;
        dbms_output.put_line('------------------------------------');
    END LOOP;

END;
/



--Pregunta 2
SELECT * FROM MEDICAMENTOS;

/
DECLARE
    CURSOR c_medi IS
        SELECT m.denominacion, m.presentacion, m.lote, m.fecha_vencimiento
        FROM MEDICAMENTOS m
        WHERE m.fecha_vencimiento < ADD_MONTHS(SYSDATE,6);

BEGIN
    dbms_output.put_line('Medicamentos proximos a vencer: ');
    FOR r IN c_medi LOOP
        dbms_output.put_line(r.denominacion || ' - ' || r.presentacion || ' - ' || r.lote || ' - ' || r.fecha_vencimiento);
    END LOOP;
END;
/

--Pregunta 3
SELECT * FROM MEDICAMENTOS;
DESC MEDICAMENTOS;
SELECT * FROM BOLETAS_MEDICAMENTOS;
/
CREATE OR REPLACE TRIGGER TR_VALIDAR_VENCIMIENTO_VENTA
BEFORE INSERT OR UPDATE ON BOLETAS_MEDICAMENTOS
FOR EACH ROW
DECLARE
    validar VARCHAR2(20);
    nombre VARCHAR2(100);
    fecha DATE;
    DIAS  number;
BEGIN
    
    SELECT m.estado, m.fecha_vencimiento, m.denominacion,TRUNC(m.fecha_vencimiento - SYSDATE)
    INTO validar , fecha, nombre, dias
    FROM MEDICAMENTOS m
    WHERE m.medicamento_id = :NEW.medicamento_id;
    
    
    IF (validar = 'VENCIDO') or (fecha<SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20016,'No se puede vender el medicamento ' || nombre || ' porque está vencido. Fecha
        de vencimiento: '||fecha);
    END IF;
    
    IF DIAS>=1 and DIAS<=7 THEN
        dbms_output.put_line('Advertencia, el medicamento '||nombre || ' vence en '|| dias || ' dias');
    END IF;
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20017,'Medicamento no encontrado en el sistema');
END;
/
------------------------ -- PREPARACIÓN DE DATOS: ------------------------ -- Crear una boleta de prueba nueva va a ser usada en todos los casos 
INSERT INTO BOLETAS (BOLETA_ID, NRO_SERIE, PACIENTE_ID, FECHA_EMISION, 
MONTO_TOTAL, METODO_PAGO) 
VALUES (500, 'BTEST-0001', 201, TRUNC(SYSDATE), 10, 'EFECTIVO'); 


------------------------------- -- CASO PRUEBA 1: VENTA VÁLIDA: ------------------------------- -- Venta válida: debería INSERTAR sin error 
INSERT INTO BOLETAS_MEDICAMENTOS (BOLETA_ID, MEDICAMENTO_ID, PRECIO_UNITARIO, 
CANTIDAD) 
VALUES (500, 702, 10, 1); 


-------------------------- -- CASO PRUEBA 2: VENCIDO: -------------------------- -- Forzar estado del medicamento a VENCIDO 
UPDATE MEDICAMENTOS 
   SET ESTADO = 'VENCIDO' 
 WHERE MEDICAMENTO_ID = 703; 
 
 -- Intentar vender: debe lanzar RAISE_APPLICATION_ERROR -20016 
INSERT INTO BOLETAS_MEDICAMENTOS (BOLETA_ID, MEDICAMENTO_ID, PRECIO_UNITARIO, 
CANTIDAD) 
VALUES (500, 703, 12, 1); 


-------------------------- -- CASO PRUEBA 3: VENCIDO: -------------------------- -- Poner un medicamento con fecha de vencimiento en el pasado 
UPDATE MEDICAMENTOS 
   SET FECHA_VENCIMIENTO = TRUNC(SYSDATE) - 1 
 WHERE MEDICAMENTO_ID = 704; 
 -- Intentar venderlo: debe disparar error -20016 
INSERT INTO BOLETAS_MEDICAMENTOS (BOLETA_ID, MEDICAMENTO_ID, PRECIO_UNITARIO, 
CANTIDAD) 
VALUES (500, 704, 15, 1); 



---------------------------------------------------------------- -- CASO PRUEBA 4: PERMITIDO, PERO CON ADVERTENCIA DE EXPIRACIÓN: ---------------------------------------------------------------- -- Configuramos un medicamento para que venza en 3 días 
UPDATE MEDICAMENTOS 
   SET FECHA_VENCIMIENTO = TRUNC(SYSDATE) + 3 
 WHERE MEDICAMENTO_ID = 705; 
 -- Venta permitida, pero con mensaje de advertencia en DBMS_OUTPUT 
SET SERVEROUTPUT ON; 
INSERT INTO BOLETAS_MEDICAMENTOS (BOLETA_ID, MEDICAMENTO_ID, PRECIO_UNITARIO, 
CANTIDAD) 
VALUES (500, 705, 16.5, 1); 

---------------------------------------- -- CASO PRUEBA 5: NO EXISTE MEDICAMENTO: ---------------------------------------- -- Medicamento 9999 NO existe en MEDICAMENTOS, debe saltar NO_DATA_FOUND 
INSERT INTO BOLETAS_MEDICAMENTOS (BOLETA_ID, MEDICAMENTO_ID, PRECIO_UNITARIO, 
CANTIDAD) 
VALUES (500, 9999, 10, 1); 

--Pregunta 4
SELECT * FROM ALERTAS_MEDICAMENTOS;
SELECT * FROM MEDICAMENTOS;
DESC ALERTAS_MEDICAMENTOS;
/
CREATE OR REPLACE TRIGGER TRG_ALERTA_VENCIMIENTO
BEFORE UPDATE ON MEDICAMENTOS
FOR EACH ROW
DECLARE
    dias number;
    nombre VARCHAR2 (100);
    vencimiento DATE;
BEGIN
    SELECT TRUNC(m.fecha_vencimiento - SYSDATE ), m.denominacion , m.fecha_vencimiento into DIAS, nombre, vencimiento
    FROM medicamentos m
    WHERE m.medicamento_id = :new.medicamento_id;
    
    IF dias<=0 THEN
        
        :NEW.ESTADO := 'VENCIDO';
        INSERT INTO ALERTAS_MEDICAMENTOS (alerta_id, medicamento_id,tipo_alerta,mensaje,fecha_alerta) VALUES 
        (SEQ_ALERTAS_MEDICAMENTOS.NEXTVAL,:new.medicamento_id,'VENCIDO','El medicamento '||nombre|| ' ha vencido. Fecha de vencimiento '||vencimiento,sysdate);
        
    END IF;
    
    IF dias>=1 and dias<=30 THEN
        
        :NEW.ESTADO := 'POR VENCER';
        INSERT INTO ALERTAS_MEDICAMENTOS (alerta_id, medicamento_id,tipo_alerta,mensaje,fecha_alerta) VALUES
        (SEQ_ALERTAS_MEDICAMENTOS.NEXTVAL,:new.medicamento_id,'PROXIMO VENCIMIENTO','El medicamento '||nombre|| ' vencerá en '|| dias || ' Fecha de vencimiento '||vencimiento,sysdate);
     
    END IF;
    
    IF dias>30 THEN
        :NEW.ESTADO := 'VIGENTE';
    END IF;
    
END;
/

CREATE OR REPLACE TRIGGER TRG_ALERTA_VENCIMIENTO
BEFORE UPDATE ON MEDICAMENTOS
FOR EACH ROW
DECLARE
    dias NUMBER;
BEGIN
    
    dias := TRUNC(:NEW.fecha_vencimiento - SYSDATE);

    IF dias <= 0 THEN
        
        :NEW.estado := 'VENCIDO';

        INSERT INTO ALERTAS_MEDICAMENTOS
        (alerta_id, medicamento_id, tipo_alerta, mensaje, fecha_alerta)
        VALUES
        (
        SEQ_ALERTAS_MEDICAMENTOS.NEXTVAL,
        :NEW.medicamento_id,
        'VENCIDO',
        'El medicamento ' || :NEW.denominacion ||
        ' ha vencido. Fecha de vencimiento ' || :NEW.fecha_vencimiento,
        SYSDATE
        );

    ELSIF dias BETWEEN 1 AND 30 THEN
        
        :NEW.estado := 'POR VENCER';

        INSERT INTO ALERTAS_MEDICAMENTOS
        (alerta_id, medicamento_id, tipo_alerta, mensaje, fecha_alerta)
        VALUES
        (
        SEQ_ALERTAS_MEDICAMENTOS.NEXTVAL,
        :NEW.medicamento_id,
        'PROXIMO VENCIMIENTO',
        'El medicamento ' || :NEW.denominacion ||
        ' vencerá en ' || dias ||
        ' días. Fecha de vencimiento ' || :NEW.fecha_vencimiento,
        SYSDATE
        );

    ELSE
        :NEW.estado := 'VIGENTE';
    END IF;

END;
/


-- -------------- -- CASO PRUEBA 1: -- -------------- -- Update: vencido (ayer → <= 0 días) -- debe actualizar estado a VENCIDO y debe haber insertado una alerta 
UPDATE MEDICAMENTOS 
SET FECHA_VENCIMIENTO = TRUNC(SYSDATE) - 1 
WHERE MEDICAMENTO_ID = 715; -- verificamos estado 
SELECT * FROM MEDICAMENTOS WHERE MEDICAMENTO_ID = 715; -- verificamos alertas 
SELECT * FROM ALERTAS_MEDICAMENTOS; 


-- -------------- -- CASO PRUEBA 2: -- -------------- -- Update: vence en 5 días (1–30 días) -- debe actualizar estado a POR_VENCER y debe haber insertado una alerta 
UPDATE MEDICAMENTOS 
SET FECHA_VENCIMIENTO = TRUNC(SYSDATE) + 5 
WHERE MEDICAMENTO_ID = 715; -- verificamos estado 
SELECT * FROM MEDICAMENTOS WHERE MEDICAMENTO_ID = 715; -- verificamos alertas 
SELECT * FROM ALERTAS_MEDICAMENTOS; 

-- -------------- -- CASO PRUEBA 3: -- -------------- -- Update: vence en 60 días (> 30 días) -- debe actualizar estado a VIGENTE y no crear alertas 
UPDATE MEDICAMENTOS 
SET FECHA_VENCIMIENTO = TRUNC(SYSDATE) + 60 
WHERE MEDICAMENTO_ID = 715; -- verificamos estado 
SELECT * FROM MEDICAMENTOS WHERE MEDICAMENTO_ID = 715; -- verificamos alertas 
SELECT * FROM ALERTAS_MEDICAMENTOS; 