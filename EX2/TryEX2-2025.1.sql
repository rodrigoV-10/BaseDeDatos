--TryEX2-2025.1

--PREGUNTA 3
SET SERVEROUTPUT ON;
--item a)
SELECT * FROM AP_PASAJEROS;
DESC AP_PASAJEROS;
SELECT * FROM AP_VUELOS;
SELECT * FROM AP_BOLETOS;
SELECT * FROM AP_AEROPUERTOS;
SELECT * FROM AP_CIUDADES;
/
CREATE OR REPLACE PROCEDURE DETALLES_VIAJES_PASAJERO
(p_docu CHAR,p_numero VARCHAR2)
AS
    validar NUMBER;
    CURSOR c_cursor IS
        SELECT p.nombres || ' ' || p.ap_paterno || ' ' || p.ap_materno as NOMBRE_PASAJERO,
        v.vuelo_id, a1.nombre  AS IDA , a2.nombre AS VUELTA, v.fecha_hora_partida, v.fecha_hora_llegada,
        b.categoria, b.precio_boleto_usd, ciu1.nombre_ciudad AS CIUDAD1, ciu2.nombre_ciudad AS CIUDAD2
        FROM AP_PASAJEROS p, AP_VUELOS v, AP_BOLETOS b, AP_AEROPUERTOS a1,
        AP_AEROPUERTOS a2, AP_CIUDADES ciu1  , AP_CIUDADES ciu2
        WHERE p_docu = p.tipo_documento and p.nro_documento = p_numero and
        p.pasajero_id = b.pasajero_id  and b.vuelo_id = v.vuelo_id and
        v.aeropuerto_partida_id = a1.aeropuerto_id and v.aeropuerto_llegada_id = a2.aeropuerto_id and
        ciu1.ciudad_id = a1.ciudad_id and ciu2.ciudad_id = a2.ciudad_id ;
BEGIN
    
    SELECT COUNT(*) INTO validar
    FROM AP_PASAJEROS p
    WHERE p_docu = p.tipo_documento and p.nro_documento = p_numero;
    
    IF validar !=0 THEN
        FOR r IN c_cursor LOOP
        dbms_output.put_line('Pasajero: '||r.NOMBRE_PASAJERO);
        dbms_output.put_line('Vuelo: ' || r.vuelo_id || ' | Origen: ' || r.CIUDAD1 ||'(' || r.ida || ') | ' 
        ||' Destino: '|| r.CIUDAD2 ||'(' || r.vuelta);
        dbms_output.put_line('Fecha Partida: ' || r.fecha_hora_partida || ' | Fecha Llegada: ' || r.fecha_hora_llegada);
        dbms_output.put_line('Categoria: '||r.categoria || ' | Precio: USD '||r.precio_boleto_usd);
        END LOOP;
    ELSE
        dbms_output.put_line('No existe un pasajero con los datos proporciados');
    END IF;
    
END;
/

CALL DETALLES_VIAJES_PASAJERO('D','45678901');

--item b)
SELECT * FROM AP_PASAJEROS;
DESC AP_PASAJEROS;
/
CREATE OR REPLACE FUNCTION F_OBTENER_PASAJERO_MAS_VIAJES (v_sexo CHAR)
RETURN VARCHAR2
AS
    v_cantidad NUMBER;
    v_cantidad_maxima NUMBER := 0;
    v_nombre VARCHAR2(100);
    v_n VARCHAR2(100);
    
    CURSOR c_cursor IS
        --usar distinct para que no se repita
        -- o tmbn usar el pasajero id en el group by
        SELECT p.nombres || ' ' || p.ap_paterno || ' ' || p.ap_materno as NOMBRE_COMPLETO,
        COUNT(b.boleto_id) 
        FROM AP_PASAJEROS p , AP_BOLETOS b
        WHERE p.sexo = v_sexo and b.pasajero_id = p.pasajero_id
        GROUP BY p.pasajero_id,p.nombres, p.ap_paterno,p.ap_materno
        --ORDER BY COUNT(b.boleto_id) DESC
        ;
        
BEGIN
    
    OPEN c_cursor;
    LOOP
    
        FETCH c_cursor INTO v_n , v_cantidad;
        EXIT WHEN c_cursor%notfound;
        
        IF v_cantidad>v_cantidad_maxima THEN
            v_cantidad_maxima := v_cantidad;
            v_nombre := v_n;
        END IF;
        
    END LOOP;
    
    RETURN v_nombre;
     
END;
/
SELECT F_OBTENER_PASAJERO_MAS_VIAJES ('F') FROM DUAL;

--Pregunta 4
--item a)
SELECT * FROM AP_EMPLEADOS;
/
CREATE OR REPLACE TRIGGER TR_INSERTAR_NUEVO_EMPLEADO
BEFORE INSERT ON AP_EMPLEADOS
FOR EACH ROW
DECLARE
    prom NUMBER;
    v_suma NUMBER;
    v_cantidad NUMBER;
    
BEGIN
    SELECT avg(e.salario) INTO prom
    FROM AP_EMPLEADOS e
    WHERE e.cargo_id = :new.cargo_id and e.activo=1;
    
    IF prom is not null THEN
        :new.salario := prom;
    ELSE
        :new.salario := 0;
    END IF;

END;
/
rollback;

SELECT * FROM AP_EMPLEADOS;
INSERT INTO AP_EMPLEADOS 
(EMPLEADO_ID,TIPO_DOCUMENTO,NRO_DOCUMENTO,NOMBRES,AP_PATERNO,AP_MATERNO,FECHA_NACIMIENTO, SEXO, CELULAR, EMAIL,CARGO_ID, FECHA_INGRESO,ACTIVO) 
VALUES 
('EMP011','D','89898989','LUIS','GARCIA','MONTES','06/04/1975','M',99882929,'lgarcia@gmail.com',3,'01/08/2025',1);



--item b)
INSERT INTO AP_VUELOS (VUELO_ID, FECHA_HORA_PARTIDA, FECHA_HORA_LLEGADA, AVION_ID, AEROPUERTO_PARTIDA_ID, AEROPUERTO_LLEGADA_ID) VALUES ('LA2301', TO_DATE('2025-08-05 08:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2025-08-05 09:15', 'YYYY-MM-DD HH24:MI'), 101, 1, 2); -- Lima - Cusco

INSERT INTO AP_BOLETOS (BOLETO_ID, NRO_SERIE, CORRELATIVO, FECHA_EMISION, CATEGORIA, PRECIO_BOLETO_USD, PASAJERO_ID, VUELO_ID) VALUES (301, 'AA-100', 1, TO_DATE('2025-08-05', 'YYYY-MM-DD'), 'E', 150.50, 1, 'LA2301'); -- Jorge Chávez
INSERT INTO AP_BOLETOS (BOLETO_ID, NRO_SERIE, CORRELATIVO, FECHA_EMISION, CATEGORIA, PRECIO_BOLETO_USD, PASAJERO_ID, VUELO_ID) VALUES (302, 'AA-100', 2, TO_DATE('2025-08-05', 'YYYY-MM-DD'), 'E', 135.75, 2, 'LA2301'); -- Familiar de Jorge Chávez
INSERT INTO AP_BOLETOS (BOLETO_ID, NRO_SERIE, CORRELATIVO, FECHA_EMISION, CATEGORIA, PRECIO_BOLETO_USD, PASAJERO_ID, VUELO_ID) VALUES (303, 'AA-100', 3, TO_DATE('2025-08-05', 'YYYY-MM-DD'), 'E', 144.00, 10, 'LA2301'); -- Familiar de Jorge Chávez

INSERT INTO AP_EMPLEADOS_VUELOS (VUELO_ID, EMPLEADO_ID) VALUES ('LA2301', 'EMP001'); 
INSERT INTO AP_EMPLEADOS_VUELOS (VUELO_ID, EMPLEADO_ID) VALUES ('LA2301', 'EMP004'); 
SELECT * FROM AP_AVIONES;
SELECT * FROM AP_VUELOS;
SELECT * FROM AP_EMPLEADOS_VUELOS;
/
CREATE OR REPLACE TRIGGER TR_CAMBIAR_ESTADO
BEFORE UPDATE ON AP_AVIONES
FOR EACH ROW
DECLARE
    
    CURSOR c_cursor IS
        SELECT v.vuelo_id
        FROM AP_VUELOS v
        WHERE v.avion_id=:new.avion_id and v.fecha_hora_partida>sysdate ;
    
BEGIN
    IF :new.estado = 'I' THEN
        FOR r in c_cursor LOOP
            delete from ap_boletos
            where vuelo_id = r.vuelo_id;
            
            delete from ap_empleados_vuelos
            where vuelo_id = r.vuelo_id;
            
            delete from ap_vuelos
            where vuelo_id = r.vuelo_id;
        END LOOP;
    END IF;
END;
/
ROLLBACK;
UPDATE AP_AVIONES 
SET ESTADO='I' 
WHERE AVION_ID=101; 