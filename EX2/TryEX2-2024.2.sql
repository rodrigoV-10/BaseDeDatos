--Pregunta 3

SELECT * FROM REGION_PERU;
SELECT * FROM PARTIDO_POLITICO;
SELECT * FROM VOTACION;
SELECT * FROM VOTOS_PARTIDO;

SET SERVEROUTPUT ON;
--item a)
/
CREATE OR REPLACE PROCEDURE PR_RESULTADOS_ELECCIONES
AS
    cantidad NUMBER;
    cantidad_MAX NUMBER :=0 ;
    nombre_partido VARCHAR2(100);
    nombre_max VARCHAR2(100);
    cantidad_nulo NUMBER;
    cantidad_blanco NUMBER;
    
    CURSOR c_cursor IS 
        SELECT p.nombre ,SUM(v.votos)
        FROM PARTIDO_POLITICO p, VOTACION v
        WHERE p.idpartido = v.idpartido and p.idpartido IN (3,4,5)
        GROUP BY p.nombre
        ORDER BY p.nombre ASC;
BEGIN
    
    SELECT SUM(v.votos) into cantidad_blanco
    FROM  VOTACION v
    WHERE v.idpartido = 1;
    
    SELECT SUM(v.votos) into cantidad_nulo
    FROM  VOTACION v
    WHERE v.idpartido = 2;
    
    OPEN c_cursor;
    LOOP
        FETCH c_cursor INTO nombre_partido, cantidad;
        EXIT WHEN c_cursor%NOTFOUND;
        dbms_output.put_line('Partido  '||nombre_partido ||' : ' || cantidad || ' votos');
        IF (cantidad>cantidad_MAX)  THEN
            cantidad_MAX := cantidad;
            nombre_max := nombre_partido;
        END IF;
        
    END LOOP;
    --aqui muestro el mensaje
    dbms_output.put_line('Votos nulos: ' || cantidad_nulo ||' votos');
    dbms_output.put_line('Votos en blanco: '||cantidad_blanco||' votos');
    dbms_output.put_line(' ');
    dbms_output.put_line('Partido ganador : '||nombre_max);
END;
/
EXEC PR_RESULTADOS_ELECCIONES;


--item b)
SELECT * FROM REGION_PERU;
SELECT * FROM PARTIDO_POLITICO;
DESC PARTIDO_POLITICO;
SELECT * FROM VOTACION;
SELECT * FROM VOTOS_PARTIDO;
/
CREATE OR REPLACE PROCEDURE PR_ALMACENAR_VOTOS_PARTIDO(p_nombre VARCHAR2)
AS
    ide NUMBER;
    cantidad NUMBER;
    nom VARCHAR2(100);
    iterador NUMBER := 1;
    nombre_exception EXCEPTION;
    CURSOR c_cursor IS
        SELECT r.nombre,SUM(v.votos)
        FROM PARTIDO_POLITICO p ,REGION_PERU r , VOTACION v
        WHERE p_nombre = p.nombre and 
        r.idregion = v.idregion and v.idpartido = p.idpartido
        GROUP BY r.nombre
        ORDER BY r.nombre ASC;
BEGIN
    
    BEGIN
        SELECT p.idpartido into ide
        FROM PARTIDO_POLITICO p
        WHERE p.nombre = p_nombre;
        
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            RAISE nombre_exception;
    END;
    
    SELECT p.idpartido into ide
    FROM PARTIDO_POLITICO p
    WHERE p.nombre = p_nombre;
        
    IF ide is null THEN
        RAISE nombre_exception;
        return;
    END IF;
    
    OPEN c_cursor;
    LOOP
        FETCH c_cursor INTO nom, cantidad;
        EXIT WHEN c_cursor%NOTFOUND;
        INSERT INTO VOTOS_PARTIDO (nombre_region,votos)VALUES(nom,cantidad);
    END LOOP;
    dbms_output.put_line('Se ha creado una tabla con los votos del partido '||p_nombre || ' en todas las regiones');
EXCEPTION    
    WHEN nombre_exception THEN
        dbms_output.put_line('El partido '|| p_nombre || ' no existe');
END;
/
SELECT * FROM VOTOS_PARTIDO;
exec pr_almacenar_votos_partido('XYZ'); 

--Pregunta 4
--item a)
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


ALTER SESSION SET NLS_DATE_FORMAT = 'dd/MM/YYYY HH24:MI:SS';
SELECT * FROM EX2_EMPLEADOS;
DESC EX2_EMPLEADOS;
/
CREATE OR REPLACE TRIGGER INSERTAR_EMPLEADO
BEFORE INSERT OR UPDATE ON EX2_EMPLEADOS
FOR EACH ROW
DECLARE

BEGIN
    IF inserting THEN
        --CUANDO SE INSERTA UN NUEVO DATO -> se crea la fecha y el usuario
        :new.CREATED_BY := USER;
        :new.CREATION_DATE := SYSDATE;
    END IF;
    --cuando ocurren actualizaciones solo se actualiza la columna de last_updated by , date
    :new.LAST_UPDATED_BY := USER;
    :new.LAST_UPDATE_DATE := SYSDATE;
END;
/
INSERT INTO EX2_EMPLEADOS (EMPLEADO_ID, NOMBRE, APELLIDO, SALARIO) 
VALUES(100,'JUAN','PEREZ',1500); 
INSERT INTO EX2_EMPLEADOS (EMPLEADO_ID, NOMBRE, APELLIDO, SALARIO) 
VALUES(101,'ANA','PEREZ',1600);
SELECT * FROM EX2_EMPLEADOS;
UPDATE EX2_EMPLEADOS SET salario=1800 WHERE empleado_id= 100;
SELECT * FROM EX2_EMPLEADOS;
UPDATE EX2_EMPLEADOS SET salario=1925; 
SELECT * FROM EX2_EMPLEADOS;
DROP TABLE EX2_EMPLEADOS;