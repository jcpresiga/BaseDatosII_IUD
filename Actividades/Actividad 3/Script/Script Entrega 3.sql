
----CREACION DE TABLAS REQUERDIDAS

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

----SCRIPT LLENAR DATOS DESDE JARDINERIA A JARDINERIASTAGING
----
INSERT INTO JardineriaStaging.dbo.dim_productos (CodigoProducto, nombre, descripcion, Desc_categoria)
SELECT p.CodigoProducto, p.nombre, p.descripcion, cp.Desc_Categoria
FROM jardineria.dbo.producto p
INNER JOIN jardineria.dbo.Categoria_producto cp ON cp.Id_Categoria = p.Categoria;


-----TRANSFORMACION TABLA DIMENSION PRODUCTOS======
select ID_producto, CodigoProducto, upper(nombre) Nombre_Producto,  
IIF(LEN(descripcion) = 0, 'N/A', descripcion) as Descripcion
, upper(Desc_categoria) Categoria
from dim_productos


-----SCRIPT LLENAR DATOS DE CLIENTES
-----
INSERT INTO JardineriaStaging.dbo.dim_clientes (nombre_cliente, direccion, telefono, ciudad, region, pais)
select nombre_cliente,  linea_direccion1, telefono, ciudad, region, pais
from jardineria.dbo.cliente


----TRANSFORMACIÓN TABLA DIMENSION CLIENTES=========
----
select ID_cliente, upper(nombre_cliente) as Nombre_Cliente, upper(direccion) as Direccion, telefono as Telefono, upper(ciudad) as Ciudad
, upper(isnull(region,'N/A')) as Region, upper(pais) as Pais
from dim_clientes


-----SCRIPT LLENAR DATOS DE TIEMPO
-----
INSERT INTO JardineriaStaging.dbo.dim_tiempo (anio)
select distinct YEAR(fecha_pedido) as anio from jardineria.dbo.pedido where fecha_entrega is NOT NULL



----SCRIPT LLENAR DATOS DE TABLA HECHOS PEDIDOS
----
INSERT INTO JardineriaStaging.dbo.pedidos (ID_producto, ID_cliente, ID_tiempo, fecha_entrega, fecha_pedido, cantidad, precio)
select ID_producto, ID_cliente, id_tiempo, fecha_entrega, fecha_pedido, cantidad, precio_unidad 
from jardineria.dbo.pedido p
join jardineria.dbo.detalle_pedido dp
on dp.ID_pedido = p.ID_pedido 
join JardineriaStaging.dbo.dim_tiempo t
on YEAR(fecha_entrega)  = t.anio






