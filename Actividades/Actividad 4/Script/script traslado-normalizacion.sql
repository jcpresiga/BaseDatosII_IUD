----Creacion de Base de Datos DataMart Final

---CREATE DATABASE JardineriaDataMart_Final

----CREACION DE TABLAS REQUERIDAS

CREATE TABLE dim_productos (
  ID_producto int identity(1,1), 
  CodigoProducto VARCHAR(25) NOT NULL,
  nombre VARCHAR(70) NOT NULL,
  descripcion VARCHAR(MAX) NOT NULL,
  Desc_categoria VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (ID_producto)
);

CREATE TABLE dim_tiempo (
	ID_tiempo int identity(1,1),
	anio varchar(4) NOT NULL,
	PRIMARY KEY (ID_tiempo)
)

CREATE TABLE dim_clientes (
	ID_cliente int identity(1,1),
	nombre_cliente varchar(50) NOT NULL,
	direccion varchar(50) NOT NULL,
	telefono varchar(15) NOT NULL,
	ciudad varchar(50) NOT NULL,
	region varchar(50),
	pais varchar(50) NOT NULL,
	PRIMARY KEY (ID_cliente)
)

CREATE TABLE pedidos (
	ID_pedido int identity(1,1),
	ID_producto int NOT NULL,
	ID_cliente int NOT NULL,
	ID_tiempo int NOT NULL,
	fecha_entrega date,
	fecha_pedido date,
	cantidad int NOT NULL,
	precio numeric(15,2) NOT NULL
	PRIMARY KEY (ID_pedido),
	FOREIGN KEY (ID_producto) REFERENCES dim_productos (ID_producto),
	FOREIGN KEY (ID_cliente) REFERENCES dim_clientes (ID_cliente),
	FOREIGN KEY (ID_tiempo) REFERENCES dim_tiempo (ID_tiempo)
)


----===TRASLADAR INFORMACIÓN DE LA BD ORIGEN A STAGING

----SCRIPT LLENAR DATOS DESDE JARDINERIASTAGING HACIA JARDINERIADATAMART_FINAL
----CON VALIDACIONES Y NORMALIZADO

INSERT INTO JardineriaDataMart_Final.dbo.dim_productos (CodigoProducto, nombre, descripcion, Desc_categoria)
SELECT p.CodigoProducto, upper(p.nombre), IIF(LEN(p.descripcion) = 0, 'N/A', p.descripcion), upper(p.Desc_Categoria)
FROM JardineriaStaging.dbo.dim_productos p


-----SCRIPT LLENAR DATOS DE CLIENTES JARDINERIASTAGING HACIA JARDINERIADATAMART_FINAL
----CON VALIDACIONES Y NORMALIZADO
-----
INSERT INTO JardineriaDataMart_Final.dbo.dim_clientes (nombre_cliente, direccion, telefono, ciudad, region, pais)
select upper(nombre_cliente),  upper(direccion), telefono, upper(ciudad), upper(isnull(region,'N/A')), upper(pais)
from JardineriaStaging.dbo.dim_clientes


-----SCRIPT LLENAR DATOS DE TIEMPO JARDINERIASTAGING HACIA JARDINERIADATAMART_FINAL
-----
INSERT INTO JardineriaDataMart_Final.dbo.dim_tiempo (anio)
select distinct YEAR(fecha_pedido) as anio from jardineria.dbo.pedido where fecha_entrega is NOT NULL



----SCRIPT LLENAR DATOS DE TABLA HECHOS PEDIDOS JARDINERIASTAGING HACIA JARDINERIADATAMART_FINAL
----
INSERT INTO JardineriaDataMart_Final.dbo.pedidos (ID_producto, ID_cliente, ID_tiempo, fecha_entrega, fecha_pedido, cantidad, precio)
select ID_producto, ID_cliente, id_tiempo, fecha_entrega, fecha_pedido, cantidad, precio
from JardineriaStaging.dbo.pedidos p





