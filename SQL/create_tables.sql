-- Script DDL 

-- Creacion de la BD

USE Master;
GO
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'Challenge')
DROP DATABASE Challenge
GO
CREATE DATABASE Challenge
GO
-- Creación de las tablas

USE Challenge
GO
CREATE TABLE Customer (
    id INT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    sexo CHAR(1),
    direccion TEXT,
    fecha_nacimiento DATE,
    telefono VARCHAR(20)
);

CREATE TABLE Category (
    id INT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    path TEXT NOT NULL
);

CREATE TABLE Item (
    id INT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion VARCHAR(255),
    precio DECIMAL(10,2) NOT NULL,
    estado VARCHAR(50),
    fecha_baja DATE,
    category_id INT,
    seller_id INT,
    FOREIGN KEY (category_id) REFERENCES Category(id),
    FOREIGN KEY (seller_id) REFERENCES Customer(id)
);

CREATE TABLE Orders (
    id INT PRIMARY KEY,
    customer_id INT,
    fecha_compra DATE NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(id)
);

CREATE TABLE Order_Item (
    order_id INT,
    item_id INT,
    cantidad INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES Orders(id),
    FOREIGN KEY (item_id) REFERENCES Item(id)
);

-- Se genero el scrip para crearla en el sp si es que no llegara a existir previamente, se agrego aqui dado que el DER se represento 
CREATE TABLE Item_History (
    id INT PRIMARY KEY IDENTITY,
    item_id INT NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    precio DECIMAL(10,2),
    estado VARCHAR(50),
    FOREIGN KEY (item_id) REFERENCES Item(id)
);

