

--PREGUNTA 1

/*FORMA DE DECLARACION DE FUNCIONES*/


/*SE ENVIA 2 NÚMEROS DE DOCUMENTOS Y ME RETORNA SI , SI ES QUE HAY 
UNA RELACIÓN  O NO, SI NO HAY VINCULO*/
CREATE OR REPLACE FUNCTION FN_ES_FAMILIAR (primer_pasajero VARCHAR2,
                                            segundo_pasajero VARCHAR2)
RETURN VARCHAR2 AS
V_ID1 NUMBER;
v_ID2 NUMBER;
CANT NUMBER :=0;
BEGIN 
    
    SELECT PASAJERO_ID INTO V_ID1
    FROM AP_PASAJEROS
    WHERE nro_documento = primer_pasajero;
    
    SELECT PASAJERO_ID INTO V_ID2
    FROM AP_PASAJEROS
    WHERE nro_documento=segundo_pasajero;
    
    SELECT COUNT (*) INTO CANT
    FROM AP_PARENTESCOS
    --Se igualan ID's porque en la tabla de parentescos se
    -- relacionan con ID'S
    WHERE(pasajero_id = V_ID1 and pariente_id = V_ID2) or 
    (pasajero_id = V_ID2 and pariente_id = V_ID1);
    
    IF CANT >0 THEN
        RETURN 'SI';
    ELSE
        RETURN 'NO';
    END IF;

END FN_ES_FAMILIAR;

/

SELECT * FROM AP_PASAJEROS;
SELECT * FROM AP_PARENTESCOS;


SELECT PASAJERO_ID --INTO V_ID1
FROM AP_PASAJEROS
WHERE nro_documento = '45678901';

SELECT fn_es_familiar ('45678901', '10293847') FROM DUAL; 
SELECT FN_ES_FAMILIAR('USA123456', '23456789') FROM DUAL;

--PREGUNTA 2

SET SERVEROUTPUT ON;
/
/*ENVIO UN CÓDIGO DE VUELO, VERIFICA SI HAY UN PILOTO Y AL MENOS UN TRIPULANTE 
DE CABINA*/
CREATE OR REPLACE PROCEDURE SP_VALIDAR_TRIPULACION_VUELO(
            v_vuelo CHAR)
IS
/*VARIABLES AUXILIARES*/
 v_validar NUMBER := 0;
 v_tripulacion NUMBER:=0;
BEGIN 
    --QUERYS
    SELECT COUNT (*) INTO v_validar
    FROM ap_vuelos vuelo,ap_empleados_vuelos emple_vuelo, ap_empleados emple,
    ap_cargos cargo
    WHERE   vuelo.vuelo_id = v_vuelo  and  vuelo.vuelo_id = emple_vuelo.vuelo_id 
    and emple_vuelo.empleado_id = emple.empleado_id
    and emple.cargo_id = cargo.cargo_id and cargo.detalle_cargo='Piloto';
    
    SELECT COUNT (*) INTO v_tripulacion
    FROM ap_vuelos vuelo,ap_empleados_vuelos emple_vuelo, ap_empleados emple,
    ap_cargos cargo
    WHERE   vuelo.vuelo_id = v_vuelo  and  vuelo.vuelo_id = emple_vuelo.vuelo_id 
    and emple_vuelo.empleado_id = emple.empleado_id
    and emple.cargo_id = cargo.cargo_id and cargo.detalle_cargo IN 
    ('Copiloto', 'Jefe de Cabina', 'Aeromozo', 'Aeromoza');
    
    IF v_validar>=1 and v_tripulacion>=1 THEN
        DBMS_OUTPUT.PUT_LINE('El vuelo' || v_vuelo || '  cuenta con tripulacion mínima');
    ELSIF v_validar=0 THEN
        DBMS_OUTPUT.PUT_LINE('El vuelo ' || v_vuelo || ' NO cumple con los requisitos minimos');
        DBMS_OUTPUT.PUT_LINE('- Falta piloto'); 
    ELSIF v_tripulacion=0 THEN
        DBMS_OUTPUT.PUT_LINE('- Falta piloto'); 
    END IF;
    
END;
/

EXEC SP_VALIDAR_TRIPULACION_VUELO('LA2201'); 
EXEC SP_VALIDAR_TRIPULACION_VUELO('UA4501'); 

--SHOW ERRORS PROCEDURE SP_VALIDAR_TRIPULACION_VUELO;

SELECT COUNT (*)
FROM ap_vuelos vuelo,ap_empleados_vuelos emple_vuelo, ap_empleados emple,
ap_cargos cargo
WHERE   vuelo.vuelo_id = 'LA2201'  and  vuelo.vuelo_id = emple_vuelo.vuelo_id 
            and emple_vuelo.empleado_id = emple.empleado_id
            and emple.cargo_id = cargo.cargo_id and cargo.detalle_cargo='Piloto'


--PREGUNTA 3
/
CREATE OR REPLACE PROCEDURE  SP_DATOS_VUELO (
                   v_vuelo_id CHAR)
IS
    /*se van a mostrar varias cosas*/
    v_marca VARCHAR2 (100);
    v_placa NUMBER;
    v_modelo VARCHAR2 (100);
    v_partida VARCHAR2(100);
    v_llegada VARCHAR2(100);
    v_fecha_partida DATE;
    v_fecha_llegada DATE;
    /*LUGAR ORIGEN
    FECHA PARTIDA DATE
    LUGAR DESTINO
    FECHA LLEGADA DATE*/
BEGIN
    SELECT marca.descripcion, avion.nro_placa, avion.modelo, partida.nombre ,
    llegada.nombre, vuelo.fecha_hora_partida , vuelo.fecha_hora_llegada
    INTO v_marca, v_placa, v_modelo, v_partida , v_llegada , v_fecha_partida, v_fecha_llegada
    FROM ap_vuelos vuelo,ap_aviones avion, ap_marcas marca,
    ap_aeropuertos partida, ap_aeropuertos llegada
    WHERE vuelo.vuelo_id = v_vuelo_id and
    avion.avion_id = vuelo.avion_id and
    avion.marca_id = marca.marca_id and 
    vuelo.aeropuerto_partida_id = partida.aeropuerto_id
    and vuelo.aeropuerto_llegada_id = llegada.aeropuerto_id
    ;
    
    DBMS_OUTPUT.PUT_LINE('Codigo vuelo '|| v_vuelo_id);
    DBMS_OUTPUT.PUT_LINE('Datos del avion');
    DBMS_OUTPUT.PUT_LINE('----------------');
    DBMS_OUTPUT.PUT_LINE('Marca: '||v_marca);
    DBMS_OUTPUT.PUT_LINE('Placa: '||v_placa);
    DBMS_OUTPUT.PUT_LINE('Modelo: '||v_modelo);
    DBMS_OUTPUT.PUT_LINE('------------------------');
    DBMS_OUTPUT.PUT_LINE ('Lugar origen: '|| v_partida);
    DBMS_OUTPUT.PUT_LINE ('Fecha partida: '|| v_fecha_partida);
    DBMS_OUTPUT.PUT_LINE('Lugar destino: '|| v_llegada);
    DBMS_OUTPUT.PUT_LINE('Fecha llegada: '|| v_fecha_llegada);
    
END;
/


EXEC SP_DATOS_VUELO('AV3002'); 
EXEC SP_DATOS_VUELO('CM1001'); 

SELECT * FROM AP_VUELOS;

/*QUERY INTERNO*/
SELECT *
FROM AP_VUELOS v
WHERE v.vuelo_id = 'AV3002';

/
--PREGUNTA 4


/
--PREGUNTA 4
CREATE OR REPLACE FUNCTION FN_OBTENER_MANTENIMIENTO
       (v_placa NUMBER) 
RETURN VARCHAR2 IS 
    contador NUMBER :=0;
BEGIN
          /QUERYS/
        SELECT COUNT(*) INTO contador
        FROM AP_AVIONES avion, ap_mant_aviones mantenimiento
        WHERE avion.avion_id = mantenimiento.avion_id and avion.nro_placa= v_placa;
        
        IF contador>0 THEN
            RETURN ('Se realizo un mantenimiento Correctivo al avion
            de placa '|| v_placa);
        ELSE
            RETURN ('No se encontró mantenimiento para la placa '|| v_placa);
        END IF;
          
END FN_OBTENER_MANTENIMIENTO;
/

Select FN_OBTENER_MANTENIMIENTO(44556) from dual; 

select FN_OBTENER_MANTENIMIENTO(44356) from dual; 

SELECT *FROM AP_AVIONES;

SELECT COUNT(*)
FROM AP_AVIONES avion, ap_mant_aviones mantenimiento
WHERE avion.avion_id = mantenimiento.avion_id and avion.nro_placa= 44556;

/*CREATE OR REPLACE  PROCEDURE FN_OBTENER_MANTENIMIENTO
       (v_placa NUMBER) 
IS 
    contador NUMBER :=0;
BEGIN
          --QUERYS
        SELECT COUNT(*) INTO contador
        FROM AP_AVIONES avion, ap_mant_aviones mantenimiento
        WHERE avion.avion_id = mantenimiento.avion_id and avion.nro_placa= v_placa;
        
        IF contador>0 THEN
            DBMS_OUTPUT.PUT_LINE('Se realizo un mantenimiento Correctivo al avion
            de placa '|| v_placa);
        ELSE
            DBMS_OUTPUT.PUT_LINE('No se encontró mantenimiento para la placa '|| v_placa);
        END IF;
          
END FN_OBTENER_MANTENIMIENTO;
/
select FN_OBTENER_MANTENIMIENTO(44356) from dual; */

SELECT *FROM AP_AVIONES;

SELECT COUNT(*)
FROM AP_AVIONES avion, ap_mant_aviones mantenimiento
WHERE avion.avion_id = mantenimiento.avion_id and avion.nro_placa= 44556;





