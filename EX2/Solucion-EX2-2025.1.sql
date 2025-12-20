--PREGUNTA 3 A

SET SERVEROUTPUT ON;
--Le envio el tipo DOC y el num Pasajero

SELECT * FROM AP_PASAJEROS;
SELECT * FROM AP_CIUDADES;

/
CREATE OR REPLACE PROCEDURE DETALLE_VIAJES_PASAJERO
                    (v_tipo IN  AP_PASAJEROS.TIPO_DOCUMENTO%TYPE,
                    v_num_doc IN AP_PASAJEROS.NRO_DOCUMENTO%TYPE)
AS
    v_existe_pasajero NUMBER;
    
    CURSOR c_cursor IS
        SELECT v.vuelo_id ,p.nombres || ' ' ||  p.ap_paterno || ' ' || p.ap_materno AS NOMBRE_COMPLETO ,
        c1.nombre_ciudad AS CIUDAD_ORIGEN,
        ida.nombre AS AEROPUERTO_ORIGEN ,
        c2.nombre_ciudad AS CIUDAD_PARTIDA,
        vuelta.nombre AEROPUERTO_PARTIDA,
        v.fecha_hora_partida AS FECHA_PARTIDA,
        v.fecha_hora_llegada AS FECHA_LLEGADA,
        b.categoria AS CATEGORIA, b.precio_boleto_usd AS PRECIO
        FROM AP_BOLETOS b, AP_PASAJEROS p, AP_VUELOS v, AP_AEROPUERTOS ida,
        AP_AEROPUERTOS vuelta, AP_CIUDADES c1, AP_CIUDADES C2
        WHERE v_tipo = p.tipo_documento 
        and v_num_doc = p.nro_documento
        and p.pasajero_id = b.pasajero_id
        and b.vuelo_id = v.vuelo_id 
        and v.aeropuerto_partida_id = ida.aeropuerto_id 
        and v.aeropuerto_llegada_id = vuelta.aeropuerto_id
        and ida.ciudad_id = c1.ciudad_id
        and vuelta.ciudad_id = c2.ciudad_id
        ORDER BY v.fecha_hora_partida ASC;
BEGIN
    SELECT COUNT (*) INTO v_existe_pasajero
    FROM AP_PASAJEROS
    WHERE TIPO_DOCUMENTO = v_tipo and v_num_doc = NRO_DOCUMENTO;
    
    IF v_existe_pasajero = 0    THEN
        dbms_output.put_line('Error: No existe un pasajero con los datos proporcionados');
        RETURN;
    END IF;
    
    FOR r IN c_cursor LOOP
       dbms_output.put_line('Pasajero: ' || r.NOMBRE_COMPLETO); 
       dbms_output.put_line('Vuelo: ' || r.vuelo_id || 'Origen: ' || r.CIUDAD_ORIGEN || '(' || 
       r.AEROPUERTO_ORIGEN || ') Destino : ' || r.CIUDAD_PARTIDA || '(' || r.AEROPUERTO_PARTIDA || ')' );
       dbms_output.put_line('Fecha Partida: ' || r.FECHA_PARTIDA || ' Fecha Llegada: ' || r.FECHA_LLEGADA  );
       dbms_output.put_line('Categoria: ' || r.CATEGORIA || ' | ' || ' PRECIO ' || r.PRECIO);
    END LOOP;

END;
/

EXEC DETALLE_VIAJES_PASAJERO ('D','45678901');

EXEC DETALLE_VIAJES_PASAJERO ('X','45678901'); 

--PREGUNTA 3 B
SELECT * FROM AP_PASAJEROS;
SELECT * FROM AP_BOLETOS;
/
CREATE OR REPLACE FUNCTION f_obtenerpasajero_mas_viajes
                (v_sexo IN AP_PASAJEROS.SEXO%TYPE)
                RETURN VARCHAR2
AS
    CURSOR c_cursor IS
        SELECT p.nombres || ' ' || p.ap_paterno || ' ' || p.ap_materno AS NOMBRE_COMPLETO  
        FROM AP_PASAJEROS p , AP_BOLETOS b
        WHERE p.sexo = v_sexo and p.pasajero_id = b.pasajero_id
        GROUP BY p.pasajero_id ,p.nombres, p.ap_paterno, p.ap_materno
        ORDER BY COUNT (b.boleto_id) DESC;
        
        v_resultado VARCHAR2(200);
BEGIN 
    
    OPEN c_cursor;
        FETCH c_cursor INTO v_resultado;
    CLOSE c_cursor;
    RETURN v_resultado;

END;
/

SELECT f_obtenerpasajero_mas_viajes('M') from DUAL;
SELECT f_obtenerpasajero_mas_viajes('F') from DUAL;


--PREGUNTA 4 A
/
SELECT * FROM AP_EMPLEADOS;

CREATE OR REPLACE TRIGGER first_trigger
BEFORE INSERT ON AP_EMPLEADOS
FOR EACH ROW
DECLARE 
    v_cant NUMBER;
    v_suma NUMBER;
BEGIN
    SELECT COUNT (*) , SUM (e.salario) INTO v_cant, v_suma
    FROM AP_EMPLEADOS e
    WHERE e.cargo_id = :new.cargo_id and activo=1;
    
    IF v_cant>0 THEN
        :new.salario := v_suma/v_cant;
    ELSE
        :new.salario := 0;
    END IF;
    
END;
/
INSERT INTO AP_VUELOS (VUELO_ID, FECHA_HORA_PARTIDA, FECHA_HORA_LLEGADA, AVION_ID, AEROPUERTO_PARTIDA_ID, AEROPUERTO_LLEGADA_ID) VALUES ('LA2301', TO_DATE('2025-08-05 08:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2025-08-05 09:15', 'YYYY-MM-DD HH24:MI'), 101, 1, 2); -- Lima - Cusco

INSERT INTO AP_BOLETOS (BOLETO_ID, NRO_SERIE, CORRELATIVO, FECHA_EMISION, CATEGORIA, PRECIO_BOLETO_USD, PASAJERO_ID, VUELO_ID) VALUES (301, 'AA-100', 1, TO_DATE('2025-08-05', 'YYYY-MM-DD'), 'E', 150.50, 1, 'LA2301'); -- Jorge Chávez
INSERT INTO AP_BOLETOS (BOLETO_ID, NRO_SERIE, CORRELATIVO, FECHA_EMISION, CATEGORIA, PRECIO_BOLETO_USD, PASAJERO_ID, VUELO_ID) VALUES (302, 'AA-100', 2, TO_DATE('2025-08-05', 'YYYY-MM-DD'), 'E', 135.75, 2, 'LA2301'); -- Familiar de Jorge Chávez
INSERT INTO AP_BOLETOS (BOLETO_ID, NRO_SERIE, CORRELATIVO, FECHA_EMISION, CATEGORIA, PRECIO_BOLETO_USD, PASAJERO_ID, VUELO_ID) VALUES (303, 'AA-100', 3, TO_DATE('2025-08-05', 'YYYY-MM-DD'), 'E', 144.00, 10, 'LA2301'); -- Familiar de Jorge Chávez

INSERT INTO AP_EMPLEADOS_VUELOS (VUELO_ID, EMPLEADO_ID) VALUES ('LA2301', 'EMP001'); 
INSERT INTO AP_EMPLEADOS_VUELOS (VUELO_ID, EMPLEADO_ID) VALUES ('LA2301', 'EMP004'); 

INSERT INTO AP_EMPLEADOS 
(EMPLEADO_ID,TIPO_DOCUMENTO,NRO_DOCUMENTO,NOMBRES,AP_PATERNO,AP_MATERNO,FECHA_NACIMIENTO, SEXO, CELULAR, EMAIL,CARGO_ID, FECHA_INGRESO,ACTIVO) 
VALUES 
('EMP011','D','89898989','LUIS','GARCIA','MONTES','06/04/1975','M',99882929,'lgarcia@gmail.com',
 3,'01/08/2025',1);
 
 
 --PREGUNTA 4 B
 SELECT * FROM AP_AVIONES;
 SELECT * FROM AP_VUELOS;
 SELECT * FROM AP_BOLETOS;
 /
 CREATE OR REPLACE TRIGGER second_trig
 BEFORE UPDATE ON AP_AVIONES
 FOR EACH ROW
 WHEN (NEW.estado = 'I' )
 DECLARE
    --VARIABLES
    CURSOR c_vuelos IS 
        SELECT a.vuelo_id
        FROM AP_VUELOS a
        WHERE a.avion_id = :old.avion_id 
        and a.FECHA_HORA_PARTIDA > SYSDATE;
 BEGIN
    FOR r IN c_vuelos LOOP
        DELETE FROM AP_BOLETOS
        WHERE vuelo_id = r.vuelo_id;
        
        DELETE FROM ap_empleados_vuelos
        WHERE vuelo_id = r.vuelo_id;
        
        DELETE FROM ap_vuelos
        WHERE vuelo_id = r.vuelo_id; 
    END LOOP;
 END;
 /
 
 UPDATE AP_AVIONES 
SET ESTADO='I' 
WHERE AVION_ID=101;