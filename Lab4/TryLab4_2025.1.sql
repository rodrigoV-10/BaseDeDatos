--Try2025-1

SET SERVEROUTPUT ON;
SELECT * FROM AP_AVIONES;
DESC AP_AVIONES;
SELECT * FROM AP_MANT_AVIONES;
SELECT * FROM AP_TIPOS_MANTENIMIENTO;

SELECT a.avion_id, a.modelo, t.tipo_mantenimiento_id , t.descripcion, m.fecha_inicio_est, m.fecha_fin_est
FROM AP_MANT_AVIONES m , AP_AVIONES a , AP_TIPOS_MANTENIMIENTO t
WHERE a.avion_id = 101 and a.avion_id = m.avion_id and m.tipo_mantenimiento_id = t.tipo_mantenimiento_id ; 

/
CREATE OR REPLACE PROCEDURE SP_REGISTRA_MANTENIMIENTO(p_id_cod_avion NUMBER)
AS
    CURSOR c_cursor IS
        SELECT t.tipo_mantenimiento_id
        FROM AP_TIPOS_MANTENIMIENTO t;
    contador NUMBER;
    v_tipo NUMBER;
    v_inicio DATE := SYSDATE;
    v_fin DATE;

BEGIN
    
    SELECT COUNT(*) INTO contador
    FROM  AP_MANT_AVIONES m , AP_AVIONES a , AP_TIPOS_MANTENIMIENTO t
    WHERE a.avion_id = p_id_cod_avion and a.avion_id = m.avion_id and m.tipo_mantenimiento_id = t.tipo_mantenimiento_id ;
    
    IF contador=4 THEN
        dbms_output.put_line('Tiene programado todos los mantenimientos');
        return;
    ELSE
        --proceso de actualización de datos con el cursor
        OPEN c_cursor;
        LOOP
            FETCH c_cursor INTO v_tipo;
            EXIT WHEN c_cursor%NOTFOUND;
            
            SELECT COUNT(*) INTO contador
            FROM AP_MANT_AVIONES
            WHERE avion_id = p_id_cod_avion and v_tipo = tipo_mantenimiento_id;
            
            
            IF contador = 0 THEN
                v_fin := v_inicio + 30;
                INSERT INTO AP_MANT_AVIONES VALUES (p_id_cod_avion,v_tipo,v_inicio,v_fin);
                v_inicio := v_inicio +60;
            END IF;
            
        END LOOP;
        
    END IF;

END;
/

EXEC SP_REGISTRA_MANTENIMIENTO(101);


--Pregunta 2

SELECT * FROM AP_AVIONES;
DESC AP_AVIONES;
SELECT * FROM AP_MANT_AVIONES;
/
CREATE OR REPLACE PROCEDURE SP_IMPRIMIR_MANTEN_AVIONXFECHA(p_mes NUMBER, p_anio NUMBER)
AS
    CURSOR c_cursor IS
        SELECT a.nro_placa, a.modelo , a.avion_id , m.fecha_inicio_est, m.fecha_fin_est
        FROM AP_AVIONES a , AP_MANT_AVIONES m
        WHERE a.avion_id = m.avion_id and
        EXTRACT (YEAR FROM m.fecha_inicio_est) = p_anio and 
        EXTRACT (MONTH FROM m.fecha_inicio_est) > p_mes; 
BEGIN
    FOR r IN c_cursor LOOP
        dbms_output.put_line('Placa nro: ' || r.nro_placa);
    END LOOP;

END;
/

EXEC sp_imprimir_manten_avionxfecha(9, 2024);



--Pregunta 3
DESC AP_PASAJEROS;
SELECT * FROM AP_PASAJEROS;
SELECT * FROM AP_BOLETOS;
SELECT * FROM AP_EQUIPAJES_BOLETOS;
SELECT * FROM AP_EQUIPAJES;
/
CREATE OR REPLACE PROCEDURE SP_REPORTE_EQUIPAJE_PASAJERO 
(p_id_pasajero NUMBER , p_fecha_inicio DATE , p_fecha_fin DATE)
AS
  CURSOR c_cursor IS
    SELECT b.vuelo_id, e.descripcion, eb.peso, eb.precio_equipaje_usd
    FROM AP_BOLETOS b ,AP_EQUIPAJES_BOLETOS eb , AP_EQUIPAJES e
    WHERE p_id_pasajero = b.pasajero_id and b.boleto_id=eb.boleto_id and
    eb.tipo_equipaje_id = e.tipo_equipaje_id and b.fecha_emision between p_fecha_inicio and p_fecha_fin;
    
    acumulador NUMBER :=0;
BEGIN
    FOR r IN c_cursor LOOP
        dbms_output.put_line('Vuelo: ' || r.vuelo_id  || ' , Equipaje: ' || r.descripcion || ' , Peso: '||r.peso ||' , Costo: ' ||r.precio_equipaje_usd);
        acumulador := r.precio_equipaje_usd + acumulador;
    END LOOP;
    
    dbms_output.put_line('Total gastado: ' || acumulador);
END;
/

EXEC sp_reporte_equipaje_pasajero(1, TO_DATE('2025-01-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'));  