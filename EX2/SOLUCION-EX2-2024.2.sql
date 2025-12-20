--PREGUNTA 3
SET SERVEROUTPUT ON;
/
CREATE OR REPLACE PROCEDURE pr_resultados_elecciones 
AS
    v_nulo NUMBER;
    v_blanco NUMBER;
    v_actual NUMBER;
    v_max NUMBER :=0;
    nombre_partido VARCHAR2(200);
    CURSOR C IS
        SELECT p.nombre , SUM (v.votos) AS v_cant
        FROM PARTIDO_POLITICO p, votacion v
        WHERE p.idpartido = v.idpartido 
        and p.idpartido>2
        GROUP BY p.nombre
        ORDER BY p.nombre;
BEGIN
    --Cantidad de votos en blanco
    SELECT SUM(v.votos) into v_blanco
    FROM votacion v
    WHERE v.idpartido = 1 ;
    
    
    --Cantidad de votos nulos
    SELECT SUM(v.votos) into v_nulo
    FROM votacion v
    WHERE v.idpartido = 2 ;
    
    FOR r IN c LOOP
        v_actual := r.v_cant;
        IF (v_max < v_actual) THEN
            v_max := v_actual;
            nombre_partido := r.nombre;
        END IF;
        dbms_output.put_line('Partido: ' ||' ' || r.nombre || ' ' || r.v_cant || ' '
        || ' votos');
    END LOOP;
    
    dbms_output.put_line('El partido ganador: ' || nombre_partido);
END;
/


EXEC pr_resultados_elecciones;

SELECT * FROM REGION_PERU;
SELECT * FROM PARTIDO_POLITICO;
SELECT * FROM VOTACION;
SELECT * FROM VOTOS_PARTIDO;


--PREGUNTA 3 B
/
CREATE OR REPLACE PROCEDURE pr_almacenar_votos_partido
            (v_nombre  IN PARTIDO_POLITICO.NOMBRE%TYPE)
AS
    v_id_partido PARTIDO_POLITICO.idpartido%type;
    nombre_exception EXCEPTION;
    
    CURSOR c_votos IS
        SELECT r.nombre as nombre , NVL(v.votos,0) as total
        FROM REGION_PERU r, votacion v
        WHERE r.idregion = v.idregion
        and v.idpartido = v_id_partido
        ORDER BY r.nombre;

BEGIN
    --BLOQUES 
    BEGIN
        SELECT p.idpartido INTO v_id_partido
        FROM partido_politico p
        WHERE UPPER(p.nombre) = UPPER(v_nombre);
        
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE nombre_exception;
    END;
    
    SELECT idpartido INTO v_id_partido
    FROM partido_politico p
    WHERE UPPER(p.nombre) = UPPER(v_nombre);
    
    IF v_id_partido IS NULL THEN
        RAISE nombre_exception;
        RETURN;
    END IF;
    
    DELETE FROM VOTOS_PARTIDO;
    
    
    FOR r in c_votos LOOP
        INSERT INTO VOTOS_PARTIDO VALUES (r.nombre, r.total);
    END LOOP;

    dbms_output.put_line('Se ha creado una tabala de todas las votaciones
    del partido ' || v_nombre || ' en todas las regiones' );
    
    EXCEPTION
        WHEN nombre_exception THEN
            dbms_output.put_line('El partido ' || v_nombre  || ' no existe' );
END;
/

Exec pr_almacenar_votos_partido( 'XYZ' );


--PREGUNTA 4
CREATE TABLE EX2_EMPLEADOS ( 
EMPLEADO_ID NUMBER PRIMARY KEY, 
NOMBRE VARCHAR2(100), 
APELLIDO VARCHAR2(100), 
SALARIO NUMBER, 
CREATED_BY VARCHAR2(50), 
CREATION_DATE DATE, 
LAST_UPDATED_BY VARCHAR2(50), 
LAST_UPDATE_DATE DATE 
); 

/
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/MM/YYYY HH24:MI:SS'; 

CREATE OR REPLACE TRIGGER trig 
BEFORE INSERT OR UPDATE ON EX2_EMPLEADOS
FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := USER;
        :new.creation_date := SYSDATE;
        :new.last_updated_by := USER;
        :new.last_update_date := SYSDATE;
    ELSIF updating THEN
        :new.last_updated_by := USER;
        :new.last_update_date := SYSDATE;
    END IF;
END;
/


INSERT INTO EX2_EMPLEADOS (EMPLEADO_ID, NOMBRE, APELLIDO, SALARIO) 
VALUES(100,'JUAN','PEREZ',1500);

SELECT * FROM EX2_EMPLEADOS;

INSERT INTO EX2_EMPLEADOS (EMPLEADO_ID, NOMBRE, APELLIDO, SALARIO) 
VALUES(101,'ANA','PEREZ',1600); 