
set serveroutput on;
/

--Pregunta 1
CREATE OR REPLACE FUNCTION FN_OBTENER_PRECIO_SERVICIO
           (IDE NUMBER) 
          RETURN NUMBER
          IS
              RESULTADO NUMBER:=0; 
          BEGIN
               SELECT s.PRECIO INTO RESULTADO
            FROM SERVICIOS_MEDICOS s
            WHERE s.SERVICIO_ID=IDE ;
                RETURN RESULTADO;
             EXCEPTION
             WHEN NO_DATA_FOUND THEN 
             RETURN 0;
          END FN_OBTENER_PRECIO_SERVICIO;
      /
      SELECT FN_OBTENER_PRECIO_SERVICIO(111) AS PRECIO FROM DUAL;
      SELECT SERVICIO_ID , FN_OBTENER_PRECIO_SERVICIO(SERVICIO_ID) AS PRECIO
      FROM SERVICIOS_MEDICOS;
/
--Pregunta 2
CREATE  OR REPLACE FUNCTION FN_TOTAL_ATENCIONES_ESPE
           (IDE NUMBER) 
          RETURN NUMBER
          IS
              cantidad number ;
          BEGIN
                SELECT count(*)into cantidad
                FROM ESPECIALIDADES e ,PERSONALES_MEDICOS p,ATENCIONES_MEDICAS a
             WHERE e.ESPECIALIDAD_ID=IDE  AND p.ESPECIALIDAD_ID = e.ESPECIALIDAD_ID 
             AND p.PERSONAL_ID=a.PERSONAL_ID;
             return cantidad;
             EXCEPTION
         WHEN NO_DATA_FOUND THEN 
             RETURN 0;
          END FN_TOTAL_ATENCIONES_ESPE;
          /  
       SELECT ESPECIALIDAD_ID , DENOMINACION, 
       FN_TOTAL_ATENCIONES_ESPE(ESPECIALIDAD_ID) AS TOTAL_ATENCIONES
       FROM ESPECIALIDADES;
      /
--Pregunta 3
CREATE OR REPLACE FUNCTION FN_CALCULAR_MONTO_BOLETA
           (IDE NUMBER) 
          RETURN NUMBER
          IS
              pre_servi number:=0;
              pre_medica numbeR:=0 ;
              cont1 number :=0;
              cont2 number :=0;
          BEGIN
             SELECT count (*)INTO cont1
                 FROM BOLETAS b,BOLETAS_SERVICIOS bs
                WHERE b.BOLETA_ID=IDE AND bs.BOLETA_ID=b.BOLETA_ID;
                if cont1 !=0 then 
                    SELECT NVL(bs.SUBTOTAL,0 )INTO pre_servi
                 FROM BOLETAS b,BOLETAS_SERVICIOS bs
                WHERE b.BOLETA_ID=IDE AND bs.BOLETA_ID=b.BOLETA_ID;
                end if;
                
                SELECT count(*) INTO cont2
                FROM BOLETAS b,BOLETAS_MEDICAMENTOS bm
                WHERE b.BOLETA_ID=IDE AND bm.BOLETA_ID=b.BOLETA_ID;
                 if cont2 !=0 then 
                   SELECT NVL(bm.SUBTOTAL,0) INTO pre_medica
                FROM BOLETAS b,BOLETAS_MEDICAMENTOS bm
                WHERE b.BOLETA_ID=IDE AND bm.BOLETA_ID=b.BOLETA_ID;
                end if;
                          return pre_servi+pre_medica;
          END FN_CALCULAR_MONTO_BOLETA;
      
    /
    SELECT FN_CALCULAR_MONTO_BOLETA(111) AS MONTO FROM DUAL;
    SELECT BOLETA_ID, FN_CALCULAR_MONTO_BOLETA(BOLETA_ID) AS MONTO_CALCULADO
    FROM BOLETAS
    WHERE BOLETA_ID<=418;
    
    
  
    --Pregunta 4 
    
    CREATE  OR REPLACE PROCEDURE SP_INSERTAR_CITA_MEDICA
           (ide_cit citas_medicas.cita_id%type , ide_paci citas_medicas.paciente_id%type,
        id_personal citas_medicas.personal_id%type,
           fecha_entrada  citas_medicas.fecha_cita%type, hora_entrada citas_medicas.hora_cita%type,
          estado_entrada  citas_medicas.estado%type) 
          IS
              cont number:=0;
          BEGIN
              select count(*) into cont
              from citas_medicas c
                where c.cita_id=ide_cit;
                if cont!=0 then
                    dbms_output.put_line('Error:Ya existe una cita para este paciente en la misma fecha y hora');
                else 
                 INSERT INTO CITAS_MEDICAS (CITA_ID, PACIENTE_ID, PERSONAL_ID, FECHA_CITA, HORA_CITA, ESTADO) VALUES (ide_cit, ide_paci, id_personal,fecha_entrada , hora_entrada, estado_entrada);
                    dbms_output.put_line('Cita médica registrada exitosamente.');
                end if;
          END SP_INSERTAR_CITA_MEDICA;
        
        /
        
        exec SP_INSERTAR_CITA_MEDICA(1001,201,101,TO_DATE('01-12-2025', 'DD-MM-YYYY'),TO_DATE('01-12-2025 09:00', 'DD-MM-YYYY HH24:MI'),'Programada');
        exec SP_INSERTAR_CITA_MEDICA(951,201,101,TO_DATE('12-05-2025', 'DD-MM-YYYY'),TO_DATE('01-11-2025 08:00', 'DD-MM-YYYY HH24:MI'),'Programada');
        
        
    /
    --Pregunta 5
    
    CREATE  OR REPLACE PROCEDURE SP_UPD_DIAGNOSTICO_ATENCION
           (IDE ATENCIONES_MEDICAS.ATENCION_ID%TYPE,
           DIAG ATENCIONES_MEDICAS.DIAGNOSTICO%TYPE ) 
          IS
               cont number:=0;
          BEGIN
              select count(*) into cont
              from ATENCIONES_MEDICAS a
                where a.ATENCION_ID=IDE;
                
                if cont!=0 then
                
                    update ATENCIONES_MEDICAS
                    set DIAGNOSTICO=DIAG
                    where ATENCIONES_MEDICAS.ATENCION_ID=IDE;
                    
                    dbms_output.put_line('Diagnóstico actualizado exitosamente.');
                else 
                    dbms_output.put_line('Error:La atención médica no existe');
                end if;
          END SP_UPD_DIAGNOSTICO_ATENCION;
          
        /
        exec SP_UPD_DIAGNOSTICO_ATENCION(501,'Gripe viral sin complicaciones adversas');
        exec SP_UPD_DIAGNOSTICO_ATENCION(9999,'Covid');
        /
        
   --Pregunta 6
   
   CREATE OR REPLACE  PROCEDURE SP_CALC_ESTA_EDAD_PACIENTES
          (IDE ESPECIALIDADES.ESPECIALIDAD_ID %TYPE) 
         IS
             cont number:=0;
             PROM NUMBER:=0;
             TOTAL NUMBER:=0;
             RINI NUMBER :=0;
             RFIN NUMBER :=0;
         BEGIN
             SELECT COUNT(*) INTO cont
            FROM ESPECIALIDADES e,PERSONALES_MEDICOS p,CITAS_MEDICAS c,PACIENTES paci
            WHERE e.ESPECIALIDAD_ID=IDE AND p.ESPECIALIDAD_ID = e.ESPECIALIDAD_ID
            AND C.PERSONAL_ID=p.PERSONAL_ID AND c.PACIENTE_ID = paci.PACIENTE_ID ;
                
                if cont!=0 then
                     SELECT MIN(extract (year from sysdate ) -extract (year from paci.FECHA_NACIMIENTO  )),
                     MAX(extract (year from sysdate ) -extract (year from paci.FECHA_NACIMIENTO  )),
                     COUNT(*),AVG(extract (year from sysdate ) -extract (year from paci.FECHA_NACIMIENTO  ))
                     INTO RINI,RFIN,TOTAL,PROM
                    FROM ESPECIALIDADES e,PERSONALES_MEDICOS p,CITAS_MEDICAS c,PACIENTES paci
                WHERE e.ESPECIALIDAD_ID=1 AND p.ESPECIALIDAD_ID = e.ESPECIALIDAD_ID
                AND C.PERSONAL_ID=p.PERSONAL_ID AND c.PACIENTE_ID = paci.PACIENTE_ID AND  c.ESTADO != 'Cancelada' ;
                    
                end if;
             dbms_output.put_line('======================================');
             dbms_output.put_line('ESTADÍSTICA DE EDAD - ESPECIALIDAD ID:'||IDE);
            dbms_output.put_line('======================================');
             dbms_output.put_line('Promedio de edad: '||ROUND(PROM,0)|| ' años');
             dbms_output.put_line('Total de pacientes: '||TOTAL);
            dbms_output.put_line('Rango de edades: '||RINI||' - '||RFIN ||' años');
              dbms_output.put_line('======================================');
              if cont=0 then 
                dbms_output.put_line('No hay pacientes atendidos en esta especialidad');
              end if;
         END SP_CALC_ESTA_EDAD_PACIENTES;     
   /
   exec SP_CALC_ESTA_EDAD_PACIENTES(1);
   exec SP_CALC_ESTA_EDAD_PACIENTES(10);
   /
  