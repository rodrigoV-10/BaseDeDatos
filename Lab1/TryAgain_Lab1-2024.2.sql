--Nuevo intento lab1 2024.2

--Pregunta1
CREATE TABLE EMPLEADO (
    ID_EMPLEADO NUMBER PRIMARY KEY,
    NOMBRE VARCHAR2(40),
    APE_PATERNO VARCHAR2(40 BYTE),
    APE_MATERNO VARCHAR2(40 BYTE),
    ACTIVO CHAR (1 BYTE)
);

--Pregunta 2

COMMENT ON COLUMN EMPLEADO.ID_EMPLEADO IS 'Identificador de empleado';
COMMENT ON COLUMN EMPLEADO.NOMBRE IS 'Nombre del empleado';
COMMENT ON COLUMN EMPLEADO.APE_PATERNO IS 'Apellido paterno del empleado';
COMMENT ON COLUMN EMPLEADO.APE_MATERNO IS 'Apellido materno del empleado';
COMMENT ON COLUMN EMPLEADO.ACTIVO IS 'Indicador si el empleado esta activo o no: Si(S) o No (N)';

--Pregunta 3
CREATE TABLE ROL(
    ID_ROL NUMBER PRIMARY KEY,
    DESCRIPCION VARCHAR2(50 BYTE) NOT NULL,
    ES_JEFE CHAR(1 BYTE) NOT NULL
);

--Pregunta 4
COMMENT ON COLUMN ROL.ID_ROL IS 'Identificador del rol';
COMMENT ON COLUMN ROL.ID_ROL IS 'Descripcion del rol';
COMMENT ON COLUMN ROL.ID_ROL IS 'Identificador de si el rol es jefe: Si (S) o No (N)';

--Pregunta 5
ALTER TABLE EMPLEADO ADD (FECHA_FIN_CONTRATO DATE NOT NULL, ID_ROL NUMBER NOT NULL);

ALTER TABLE ROL ADD (ACTIVO CHAR (1 BYTE));
COMMENT ON COLUMN ROL.ACTIVO IS 'Identificador de si el rol está activo: Si(S) o No(N)';

ALTER TABLE CLIENTE ADD (ACTIVO CHAR (1 BYTE));
COMMENT ON COLUMN CLIENTE.ACTIVO IS 'Identificador de si el cliente está activo: Si(S) o No(N)';

ALTER TABLE SEDE ADD (CODIGO_POSTAL VARCHAR2(6 BYTE) );
ALTER TABLE SEDE ADD (ACTIVO CHAR (1 BYTE));
COMMENT ON COLUMN SEDE.ACTIVO IS 'Identificador de si la sede está activa: Si (S) o No (N)';

--Pregunta 6
ALTER TABLE EMPLEADO ADD CONSTRAINT FK_ROL_EMPLEADO FOREIGN KEY (ID_ROL)
REFERENCES ROL(ID_ROL);

--Pregunta 7
ALTER TABLE CLIENTE MODIFY RAZON_SOCIAL VARCHAR(80 BYTE);
ALTER TABLE CLIENTE MODIFY DIRECCION_FISCAL VARCHAR(120 BYTE);

--Pregunta8 8
ALTER TABLE FORMAPAGO RENAME COLUMN nombre to nombre_forma_pago;
ALTER TABLE SEDE RENAME COLUMN AREA TO AREA_SEDE;

--Pregunta 9
SELECT * FROM SEDE;
--DESC SEDE;
SELECT s.nombresede, s.distrito
FROM SEDE s
WHERE s.provincia = 'Lima' and s.distrito IN ('Lurin','Villa El Salvador');

--Pregunta 10
INSERT INTO ROL VALUES(1, 'Administrador','S','S');
INSERT INTO ROL VALUES(2, 'Almacenero','N','S');
INSERT INTO ROL VALUES(3, 'Vendedor','N','S');
INSERT INTO ROL VALUES(4, 'Jefe de Almacen','S','S');
INSERT INTO ROL VALUES(5, 'Jefe de produccion','S','N');

--Pregunta 11
SELECT * FROM CLIENTE;
SELECT c.id_cliente, c.razon_social, c.telefono, c.correo, c.direccion_fiscal
FROM CLIENTE c
WHERE c.ruc is null;

--Pregunta 12
SELECT * FROM CLIENTE;
SELECT * FROM ORDENPEDIDO;

SELECT DISTINCT c.id_cliente, c.razon_social, c.ruc
FROM CLIENTE c , ORDENPEDIDO o
WHERE c.id_cliente = o.cliente_id_cliente and  (c.direccion_fiscal LIKE 'Av%' or c.ruc is null)
ORDER BY c.id_cliente ASC;


--PREGUNTA 13
SELECT * FROM SEDE;
SELECT s.id_sede, s.nombresede, s.distrito, s.provincia
FROM SEDE s
WHERE s.area_sede>300 and s.provincia='Lima' and s.distrito IN ('Villa El Salvador', 'Lurin') ;
