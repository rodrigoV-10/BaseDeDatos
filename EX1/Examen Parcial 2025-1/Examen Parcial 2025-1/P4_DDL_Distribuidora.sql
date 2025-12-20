DROP TABLE EX1_Factura CASCADE CONSTRAINTS;
DROP TABLE EX1_Cliente CASCADE CONSTRAINTS;
DROP TABLE EX1_Vendedor CASCADE CONSTRAINTS;
DROP TABLE EX1_Zona CASCADE CONSTRAINTS;

CREATE TABLE EX1_Zona (
    id_zona INTEGER PRIMARY KEY,
    nombre VARCHAR2(100),
    region VARCHAR2(100)
);

CREATE TABLE EX1_Cliente (
    id_cliente INTEGER PRIMARY KEY,
    nombre VARCHAR2(100),
    ruc VARCHAR2(20),
    direccion VARCHAR2(200),
    id_zona INTEGER,
    FOREIGN KEY (id_zona) REFERENCES EX1_Zona(id_zona)
);

CREATE TABLE EX1_Vendedor (
    id_vendedor INTEGER PRIMARY KEY,
    nombre VARCHAR2(100),
    telefono VARCHAR2(20),
    correo VARCHAR2(100),
    id_zona INTEGER,
    FOREIGN KEY (id_zona) REFERENCES EX1_Zona(id_zona)
);

CREATE TABLE EX1_Factura (
    id_factura VARCHAR2(20) PRIMARY KEY,
    fecha DATE,
    id_cliente INTEGER,
    total NUMBER(10,2),
    igv NUMBER(10,2),
    FOREIGN KEY (id_cliente) REFERENCES EX1_Cliente(id_cliente)
);

ALTER TABLE EX1_Zona
ADD id_vendedor INTEGER;


ALTER TABLE EX1_Zona
ADD CONSTRAINT fk_zona_vendedor
FOREIGN KEY (id_vendedor)
REFERENCES EX1_Vendedor(id_vendedor);
