--Pregunta 1
create or replace procedure Ventas_Rango_Fechas(Fecha_ini DATE, fecha_fin DATE)
is  
    CURSOR C_CABECERA IS
    SELECT V.VENTA_ID, V.FECHA_VENTA,C.nombre,c.apellido FROM L6_VENTAS V,L6_CLIENTES C
    WHERE (V.CLIENTE_ID=C.CLIENTE_ID and V.FECHA_VENTA<=fecha_fin and V.FECHA_VENTA>=fecha_ini)
    order by 2;
    cursor C_PRODUCTOS (VENTA_ID_RECIBIDA NUMBER )IS
    SELECT P.NOMBRE, V.CANTIDAD, V.PRECIO_UNITARIO, V.PRECIO_FINAL FROM L6_VENTAS_detalle V, L6_productos P
    WHERE  (V.VENTA_ID=VENTA_ID_RECIBIDA AND V.PRODUCTO_ID=P.PRODUCTO_ID);
    

begin
    for cabeza in C_CABECERA LOOP
    DBMS_OUTPUT.PUT_LINE('Documento de Venta: '||cabeza.VENTA_ID);
    DBMS_OUTPUT.PUT_LINE('Cliente: '||cabeza.nombre||' '||cabeza.apellido);
    DBMS_OUTPUT.PUT_LINE('Fecha: '||cabeza.FECHA_VENTA);
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Nombre                                    Cantidad    Precio Unit.    Precio final');
        for detalle in c_productos(cabeza.VENTA_ID) loop
            DBMS_OUTPUT.PUT_LINE(rpad(detalle.NOMBRE,45,' ')||' '||rpad(detalle.CANTIDAD,10,' ')||' '||rpad(detalle.PRECIO_UNITARIO,15,' ')||' '||detalle.PRECIO_FINAL);
        end loop;
    DBMS_OUTPUT.PUT_LINE(' ');
    END LOOP;
end;
/
select * from L6_VENTAS;
select * from L6_VENTAS_detalle;
select * from L6_productos;
select * from L6_CLIENTES;
/
exec Ventas_Rango_Fechas(to_date('07-02-2024'),to_date('09-02-2024'));
/
SELECT V.VENTA_ID, V.FECHA_VENTA,C.nombre ||' '|| c.apellido FROM L6_VENTAS V,L6_CLIENTES C
WHERE V.CLIENTE_ID=C.CLIENTE_ID and V.FECHA_VENTA;
/
set serveroutput on;
/
SELECT P.NOMBRE, V.CANTIDAD, V.PRECIO_UNITARIO, V.PRECIO_FINAL FROM L6_VENTAS_detalle V, L6_productos P
    WHERE  (V.VENTA_ID=12 AND V.PRODUCTO_ID=P.PRODUCTO_ID);
    
--Pregunta 2
/
create or replace procedure campanhias_clientes
is
    cursor c_campanhia is
    select l6_campanias.NOMBRE,l6_campanias.CAMPANIA_ID FROM l6_campanias;
    
    cursor c_ventas_en_campanhia (CAMPANIA_ID_RECIBIDA NUMBER) IS
    SELECT DISTINCT C.NOMBRE, C.APELLIDO FROM L6_VENTAS_detalle D,L6_VENTAS V,L6_CLIENTES C
    WHERE (D.CAMPANIA_ID=CAMPANIA_ID_RECIBIDA AND D.VENTA_ID=V.VENTA_ID AND V.CLIENTE_ID=C.CLIENTE_ID);
    
    cursor c_sincampania is
    SELECT DISTINCT C.NOMBRE, C.APELLIDO from L6_VENTAS_detalle D,L6_VENTAS V,L6_CLIENTES C
    WHERE (D.CAMPANIA_ID is null AND D.VENTA_ID=V.VENTA_ID AND V.CLIENTE_ID=C.CLIENTE_ID);
begin
    for campanhias in c_campanhia loop
        DBMS_OUTPUT.PUT_LINE('Nombre de campania: '||campanhias.NOMBRE);
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
        
        FOR VENTAS IN c_ventas_en_campanhia(campanhias.CAMPANIA_ID) LOOP
            DBMS_OUTPUT.PUT_LINE(VENTAS.NOMBRE||' '||VENTAS.APELLIDO);
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(' ');
    end loop;
    
    DBMS_OUTPUT.PUT_LINE('Nombre de campania: Sin campania');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
    FOR sincamp IN c_sincampania LOOP
        DBMS_OUTPUT.PUT_LINE(sincamp.NOMBRE||' '||sincamp.APELLIDO);
    END LOOP;
end;
/
exec campanhias_clientes;
/

select * from L6_VENTAS;
select * from L6_VENTAS_detalle;
select * from l6_campanias;
select * from L6_CLIENTES;
/
select l6_campanias.NOMBRE FROM l6_campanias;

--Pregunta 3
select * from L6_PRODUCTOS;
select * from L6_EDITORIALES;
select * from l6_LIBROS;
select * from L6_BIBLIOGRAFIA_CURSOS;
select * from L6_CURSOS;
/
CREATE OR REPLACE PROCEDURE PRODUCTOS_GENERAL
IS
    CURSOR DATOS_PROD IS
    SELECT P.CODIGO_PRODUCTO, P.NOMBRE,P.EDITORIAL_ID,P.PRODUCTO_ID FROM L6_PRODUCTOS P;
    
    EDITORIAL_IMPRIMIR L6_EDITORIALES.NOMBRE%TYPE;
    ISBN_IMPRIMIR l6_LIBROS.isbn%TYPE;
    ANHO_IMPRIMIR l6_LIBROS.anio_publicacion%TYPE;
    
    es_libro number:=0;
    
    CURSOR CURSOS_PER_PROD (PRODUCTO_ID_RECIBIDO NUMBER) IS
    SELECT C.CODIGO, C.NOMBRE FROM L6_PRODUCTOS P,l6_LIBROS L,L6_BIBLIOGRAFIA_CURSOS B,L6_CURSOS C
    WHERE P.PRODUCTO_ID=PRODUCTO_ID_RECIBIDO AND P.PRODUCTO_ID=L.PRODUCTO_ID AND L.LIBRO_ID=B.LIBRO_ID AND C.CURSO_ID=B.CURSO_ID;
BEGIN
    FOR DATOS_GEN IN DATOS_PROD LOOP
        DBMS_OUTPUT.PUT_LINE('Codigo del producto: '||DATOS_GEN.CODIGO_PRODUCTO);
        DBMS_OUTPUT.PUT_LINE('Nombre del producto: '||DATOS_GEN.NOMBRE);
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
        EDITORIAL_IMPRIMIR:=' ';
        ISBN_IMPRIMIR:=' ';
        ANHO_IMPRIMIR:=NULL;
        es_libro:=0;
        IF DATOS_GEN.EDITORIAL_ID IS NOT NULL THEN
            SELECT NOMBRE into EDITORIAL_IMPRIMIR FROM L6_EDITORIALES WHERE EDITORIAL_ID=DATOS_GEN.EDITORIAL_ID;
        END IF;
        select count(*) into es_libro from l6_LIBROS where (producto_id=DATOS_GEN.PRODUCTO_ID);
        IF ES_LIBRO>0 THEN
            SELECT ISBN, ANIO_PUBLICACION into ISBN_IMPRIMIR,ANHO_IMPRIMIR FROM 
            l6_LIBROS WHERE PRODUCTO_ID=DATOS_GEN.PRODUCTO_ID;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Editorial: '||EDITORIAL_IMPRIMIR);
        DBMS_OUTPUT.PUT_LINE('ISBN: '||ISBN_IMPRIMIR);
        DBMS_OUTPUT.PUT_LINE('ANHO: '||ANHO_IMPRIMIR);
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
        FOR CURSITOS IN CURSOS_PER_PROD(DATOS_GEN.PRODUCTO_ID) LOOP
            DBMS_OUTPUT.PUT_LINE(CURSITOS.CODIGO||' '||CURSITOS.NOMBRE);
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(' ');
    END LOOP;
END;
/
exec PRODUCTOS_GENERAL;
/
SELECT P.CODIGO_PRODUCTO ,P.NOMBRE FROM L6_PRODUCTOS P;
SELECT NOMBRE FROM L6_EDITORIALES WHERE EDITORIAL_ID=1;
SELECT C.CODIGO, C.NOMBRE FROM L6_PRODUCTOS P,l6_LIBROS L,L6_BIBLIOGRAFIA_CURSOS B,L6_CURSOS C
WHERE P.PRODUCTO_ID=9 AND P.PRODUCTO_ID=L.PRODUCTO_ID AND L.LIBRO_ID=B.LIBRO_ID AND C.CURSO_ID=B.CURSO_ID;
--Pregunta 4
select * from l6_perdidas_inventario;
select * from l6_ventas;
select * from l6_ventas_detalle;
select * from l6_productos;
/
create or replace procedure KARDEX
is
    cursor c_productos is
    select PRODUCTO_ID, CODIGO_PRODUCTO, NOMBRE, STOCK_ACTUAL from l6_productos; 
    
    cursor c_prod_vent(producto_id_RECIBIDO NUMBER) is
    select V.FECHA_VENTA,D.CANTIDAD FROM l6_ventas V,l6_ventas_detalle D 
    WHERE D.producto_id=producto_id_RECIBIDO AND V.VENTA_ID=D.VENTA_ID;
    
    CURSOR C_PROD_PERD (producto_id_RECIBIDO NUMBER) is
    SELECT FECHA_REGISTRO, CANTIDAD, MOTIVO FROM l6_perdidas_inventario WHERE PRODUCTO_ID=producto_id_RECIBIDO;
    
    stock_ventas number:=0;
    stock_perdidas number:=0;
    stock_total number:=0;
begin

    for cabecera in c_productos loop
    DBMS_OUTPUT.PUT_LINE('Codigo del producto: '||cabecera.CODIGO_PRODUCTO);
    DBMS_OUTPUT.PUT_LINE('Nombre del producto: '||cabecera.NOMBRE);
    select sum(cantidad) into stock_ventas FROM l6_ventas V,l6_ventas_detalle D 
    WHERE D.producto_id=cabecera.producto_id AND V.VENTA_ID=D.VENTA_ID;
    select sum(cantidad) into stock_perdidas FROM l6_perdidas_inventario
    WHERE PRODUCTO_ID=cabecera.producto_id ;
    stock_total:=cabecera.STOCK_ACTUAL;
    IF(stock_ventas IS NOT NULL)THEN 
        stock_total:=STOCK_TOTAL+stock_ventas;
    END IF;
    IF(stock_perdidas IS NOT NULL)THEN 
        stock_total:=STOCK_TOTAL+stock_perdidas;
    END IF;
    DBMS_OUTPUT.PUT_LINE('Stock inicial: '||stock_total);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Movimiento: ');
    DBMS_OUTPUT.PUT_LINE('Fecha     Cantidad    Motivo');
        for ventitas in c_prod_vent(cabecera.producto_id) loop
            DBMS_OUTPUT.PUT_LINE(rpad(ventitas.FECHA_VENTA,10,' ')||lpad(ventitas.CANTIDAD,10,' ')||'Venta');
        end loop;
        for perdidas in C_PROD_PERD(cabecera.producto_id) loop
            DBMS_OUTPUT.PUT_LINE(rpad(perdidas.FECHA_REGISTRO,10,' ')||lpad(perdidas.CANTIDAD,10,' ')||perdidas.MOTIVO);
        end loop;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Stock actual: '||cabecera.STOCK_ACTUAL);
    DBMS_OUTPUT.PUT_LINE(' ');
    end loop;
end;
/
exec KARDEX;
select V.FECHA_VENTA,D.CANTIDAD FROM l6_ventas V,l6_ventas_detalle D WHERE D.producto_id=3 AND V.VENTA_ID=D.VENTA_ID;
SELECT FECHA_REGISTRO, CANTIDAD, MOTIVO FROM l6_perdidas_inventario WHERE PRODUCTO_ID=3;