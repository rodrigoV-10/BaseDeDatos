-- Eliminar primero las tablas con FKs (tablas hijo)

-- Tablas de Ventas y Pedidos
DROP TABLE L5_ventas_detalle;
DROP TABLE L5_campanias_productos;
DROP TABLE L5_pedidos_especiales_detalle;
DROP TABLE L5_ordenes_compra_detalle;

-- Tablas de Feedback y Seguimiento
DROP TABLE L5_encuestas;
DROP TABLE L5_sugerencias;
DROP TABLE sugerencia;
DROP TABLE L5_incidencias;

-- Tablas de Productos y Bibliografía
DROP TABLE L5_bibliografia_cursos;
DROP TABLE L5_productos_areas;
DROP TABLE L5_precios_tipo_cliente;
DROP TABLE L5_productos_condicion;
DROP TABLE L5_perdidas_inventario;
DROP TABLE L5_libros;
DROP TABLE L5_revistas;

-- Tablas Principales
DROP TABLE L5_ventas;
DROP TABLE L5_pedidos_especiales;
DROP TABLE L5_ordenes_compra;
DROP TABLE L5_campanias;
DROP TABLE L5_productos;
DROP TABLE L5_clientes;
DROP TABLE L5_editoriales_historico;

-- Tablas Maestras
DROP TABLE L5_cursos;
DROP TABLE L5_tipos_cliente;
DROP TABLE L5_areas_tematicas;
DROP TABLE L5_categorias;
DROP TABLE L5_editoriales;