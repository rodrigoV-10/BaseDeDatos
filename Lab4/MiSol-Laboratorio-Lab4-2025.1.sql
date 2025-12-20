SET SERVEROUTPUT ON;

--PREGUNTA 1

SELECT tipo_mantenimiento_id
FROM  AP_TIPOS_MANTENIMIENTO;
/
CREATE OR REPLACE PROCEDURE sp_registra_mantenimiento (p_avion_id IN NUMBER)
AS
    CURSOR c_tipos IS
        SELECT tipo_mantenimiento_id
        FROM  AP_TIPOS_MANTENIMIENTO;
    v_tipo          NUMBER;
    v_existe        NUMBER;
    v_inicio        DATE := TRUNC(SYSDATE);
    v_fin           DATE;
BEGIN

    SELECT COUNT(*) INTO v_existe
    FROM ap_mant_aviones
    WHERE avion_id = p_avion_id;
    
    IF v_existe = 4 THEN
        DBMS_OUTPUT.PUT_LINE('Tiene programado todos los mantenimientos');
        RETURN;
    END IF;
    
    -- Aplicación del CURSOR:
    OPEN c_tipos;
    LOOP
        FETCH c_tipos INTO v_tipo;
        EXIT WHEN c_tipos%NOTFOUND;
        
        SELECT COUNT(*) INTO v_existe
        FROM ap_mant_aviones
        WHERE avion_id = p_avion_id
        AND tipo_mantenimiento_id = v_tipo;
        
        IF v_existe = 0  THEN
            v_fin := v_inicio + 30;
            
            INSERT INTO ap_mant_aviones VALUES
            (p_avion_id,v_tipo,v_inicio,v_fin);
            
            v_inicio := v_inicio + 60;
        END IF;
    END LOOP;
    COMMIT;
END;

SELECT * FROM ap_mant_aviones WHERE avion_id='101';
EXEC sp_registra_mantenimiento(101); 

SELECT * FROM ap_aviones;
SELECT * FROM ap_mant_aviones;

--SELECT COUNT(*) 
--FROM ap_mant_aviones
--WHERE 101 = avion_id;

--PREGUNTA 2
/
CREATE OR REPLACE PROCEDURE sp_imprimir_manten_avionxfecha
                            (p_mes IN NUMBER,
                             p_anio IN NUMBER)
AS
    --Declaracion de variables y del cursor
    CURSOR c_registro IS
        SELECT a.nro_placa, a.modelo, a.avion_id , m.fecha_inicio_est, m.fecha_fin_est
        FROM ap_aviones a, ap_mant_aviones m
        WHERE a.avion_id = m.avion_id and 
        EXTRACT (YEAR FROM m.fecha_inicio_est) = p_anio and
        EXTRACT (MONTH FROM m.fecha_inicio_est) > p_mes
        ORDER BY a.avion_id;
    
BEGIN
    FOR registro IN c_registro LOOP
        dbms_output.put_line ('-----------***-----------');
        dbms_output.put_line ('Placa: Nro: ' || registro.nro_placa);
        dbms_output.put_line ('Modelo: '|| registro.modelo);
        dbms_output.put_line ('Codigo de avion: ' || registro.avion_id);
        dbms_output.put_line ('Fecha de inicio: '|| registro.fecha_inicio_est);
        dbms_output.put_line ('Fecha de inicio: '|| registro.fecha_fin_est);
    END LOOP;

END sp_imprimir_manten_avionxfecha;
/

SELECT * FROM ap_aviones;
SELECT * FROM ap_mant_aviones;
EXEC sp_imprimir_manten_avionxfecha(9, 2024); 



/
--Pregunta 3
CREATE OR REPLACE PROCEDURE sp_reporte_equipaje_pasajero
                            (v_id_pasajero IN NUMBER,
                            v_fecha_inicio IN DATE,
                            v_fecha_fin IN DATE)
AS
    --Declaracion de variables y creacion del cursor
    CURSOR c_registro IS
    SELECT b.vuelo_id, equi.descripcion , equi_bole.peso, equi_bole.precio_equipaje_usd
    FROM AP_EQUIPAJES_BOLETOS equi_bole, AP_EQUIPAJES equi,AP_BOLETOS b,AP_PASAJEROS p
    WHERE p.pasajero_id = b.pasajero_id and p.pasajero_id = v_id_pasajero
    and equi_bole.tipo_equipaje_id = equi.tipo_equipaje_id and
    b.boleto_id = equi_bole.boleto_id and b.fecha_emision BETWEEN v_fecha_inicio and v_fecha_fin;
    
    v_total NUMBER;

BEGIN
    v_total := 0;
    --Uso del cursor
    FOR r in c_registro LOOP
        --dbms_output.put_line
        dbms_output.put_line ('Vuelo: '||r.vuelo_id || ', Equipaje : ' 
        || r.descripcion || ' , Peso: ' || r.peso || ', Costo: ' || r.precio_equipaje_usd);
        v_total := v_total + r.precio_equipaje_usd;
    END LOOP;
    dbms_output.put_line ('Total gastado: '||v_total);

END sp_reporte_equipaje_pasajero;
/
EXEC sp_reporte_equipaje_pasajero(1, TO_DATE('2025-01-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'));  

--PRECIO DEL EQUIPAJE Y PESO
SELECT * FROM AP_EQUIPAJES_BOLETOS;
--DESCRIPCION: De Bodega, De Cabina
SELECT * FROM AP_EQUIPAJES;
--BOLETOS
SELECT * FROM AP_BOLETOS;
--PASAJERO
SELECT * FROM AP_PASAJEROS;