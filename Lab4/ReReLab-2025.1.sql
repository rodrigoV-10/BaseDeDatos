SET SERVEROUTPUT ON;

--MANTENIMIENTO REGISTRADO EL DIA DE HOY
--NUEVO MANTENIMIENTO PROGRAMADO 60 DIAS
--FECHA ESTIMADA DE FIN ES EN 30 DIAS


/
CREATE OR REPLACE PROCEDURE sp_registra_mantenimiento
                        (v_cod IN NUMBER)
AS
    --VARIABLES
    v_contador NUMBER;
    CURSOR c_tipos IS
        SELECT tipo_mantenimiento_id
        FROM AP_TIPOS_MANTENIMIENTO;
        
    v_tipo NUMBER;
    v_inicio DATE :=TRUNC(SYSDATE);
    v_fin DATE;
    v_existe NUMBER;

BEGIN
    --EJECUCION
    SELECT COUNT(*) INTO v_contador
    FROM AP_MANT_AVIONES
    WHERE AVION_ID = v_cod;
    
    IF v_contador <4 THEN
        --dbms_output.put_line('Falta programar');
        FOR r IN c_tipos LOOP
            SELECT COUNT (*) INTO v_contador
            FROM AP_MANT_AVIONES m
            WHERE r.tipo_mantenimiento_id = m.tipo_mantenimiento_id
            and avion_id = v_cod;
            
            IF v_contador = 0 THEN
                v_fin := v_inicio+30;
                INSERT INTO AP_MANT_AVIONES VALUES (v_cod,r.tipo_mantenimiento_id,v_inicio,v_fin);
            END IF;
            
        END LOOP;
        RETURN;
    ELSE
        dbms_output.put_line('Tiene programado todos los mantenimientos');
    END IF;
    
END;
/

SELECT * FROM AP_AVIONES;
SELECT * FROM AP_MANT_AVIONES; -- WHERE avion_id=101;
SELECT * FROM AP_TIPOS_MANTENIMIENTO;

EXEC sp_registra_mantenimiento(101); 


/
CREATE OR REPLACE PROCEDURE sp_imprimir_manten_avionxfecha
       (v_mes IN NUMBER , v_anio IN NUMBER)
IS
          --declaration_section
          CURSOR c_registro IS
            SELECT a.nro_placa, a.modelo, a.avion_id , m.fecha_inicio_est, m.fecha_fin_est
            FROM AP_AVIONES a, AP_MANT_AVIONES m
            WHERE a.avion_id = m.avion_id and
            EXTRACT (YEAR FROM m.fecha_inicio_est) = v_anio and
            EXTRACT (MONTH FROM m.fecha_inicio_est)> v_mes
            ORDER BY a.avion_id;
          
BEGIN
          FOR r IN c_registro LOOP
            dbms_output.put_line('Placa nro: '||r.nro_placa);
            --SIGUE IMPRIMIENDO
          END LOOP;
END sp_imprimir_manten_avionxfecha;
/

EXEC sp_imprimir_manten_avionxfecha(9, 2024); 


--PREGUNTA 3


/
CREATE OR REPLACE PROCEDURE sp_reporte_equipaje_pasajero
       (v_id_pasajero IN NUMBER, v_inicio IN DATE , v_fin IN DATE) 
IS
          --declaration_section
          CURSOR c_registro IS
            SELECT b.vuelo_id, e.descripcion, e.peso, e.precio_equipaje_usd AS PRECIO
            FROM AP_BOLETOS b, AP_EQUIPAJES_BOLETOS e
            WHERE b.pasajero_id = v_id_pasajero and 
            b.fecha_emision BETWEEN v_inicio and v_fin
            and b.boleto_id = e.boleto_id
            ;
          --vuelo , equipaje- tipo , peso  , costo
          --total
          v_total NUMBER :=0;
BEGIN
          FOR r IN c_registro LOOP
            dbms_output.put_line('Vuelo: '||r.vuelo_id);
            v_total := r.PRECIO + v_total;
          END LOOP;
          dbms_output.put_line('Total gastado: '||v_total);
END sp_reporte_equipaje_pasajero;
/

SELECT * FROM AP_BOLETOS;
SELECT * FROM AP_EQUIPAJES_BOLETOS;

EXEC sp_reporte_equipaje_pasajero(1, TO_DATE('2025-01-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'));

