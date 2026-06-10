/*
Proyecto: ITV Inspection Analytics
Autor: Adrián Potenciano
Descripción: Creación de base de datos y modelo dimensional para análisis de inspecciones ITV
*/

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS itv_db;
USE itv_db;


-- Dimensión clientes

CREATE TABLE dim_clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    provincia VARCHAR(50) NOT NULL,
    fecha_alta DATE NOT NULL
) ENGINE=InnoDB;


-- Dimensión vehículos

CREATE TABLE dim_vehiculos (
    id_vehiculo INT PRIMARY KEY AUTO_INCREMENT,
    matricula VARCHAR(10) NOT NULL UNIQUE,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    combustible VARCHAR(20) NOT NULL,
    anio_fabricacion INT NOT NULL,
    CHECK (anio_fabricacion > 1950)
) ENGINE=InnoDB;


-- Dimensión estaciones

CREATE TABLE dim_estaciones (
    id_estacion INT PRIMARY KEY AUTO_INCREMENT,
    nombre_estacion VARCHAR(100) NOT NULL,
    provincia VARCHAR(50) NOT NULL
) ENGINE=InnoDB;


-- Dimensión inspectores

CREATE TABLE dim_inspectores (
    id_inspector INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    fecha_contratacion DATE NOT NULL
) ENGINE=InnoDB;


-- Dimensión fechas

CREATE TABLE dim_fechas (
    id_fecha INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    mes INT NOT NULL,
    trimestre INT NOT NULL,
    anio INT NOT NULL,
    dia_semana VARCHAR(20) NOT NULL
) ENGINE=InnoDB;


-- Tabla de hechos

CREATE TABLE fact_inspecciones (
    id_inspeccion INT PRIMARY KEY AUTO_INCREMENT,

    id_vehiculo INT NOT NULL,
    id_cliente INT NOT NULL,
    id_estacion INT NOT NULL,
    id_inspector INT NOT NULL,
    id_fecha INT NOT NULL,

    resultado VARCHAR(20) NOT NULL,
    importe DECIMAL(10,2) NOT NULL DEFAULT 0,
    defectos_leves INT NOT NULL DEFAULT 0,
    defectos_graves INT NOT NULL DEFAULT 0,

    FOREIGN KEY (id_vehiculo) REFERENCES dim_vehiculos(id_vehiculo),
    FOREIGN KEY (id_cliente) REFERENCES dim_clientes(id_cliente),
    FOREIGN KEY (id_estacion) REFERENCES dim_estaciones(id_estacion),
    FOREIGN KEY (id_inspector) REFERENCES dim_inspectores(id_inspector),
    FOREIGN KEY (id_fecha) REFERENCES dim_fechas(id_fecha),

    CHECK (resultado IN ('APTA', 'DESFAVORABLE', 'NEGATIVA')),
    CHECK (importe >= 0),
    CHECK (defectos_leves >= 0),
    CHECK (defectos_graves >= 0)
) ENGINE=InnoDB;


-- Índices

CREATE INDEX idx_fact_fecha ON fact_inspecciones(id_fecha);
CREATE INDEX idx_fact_resultado ON fact_inspecciones(resultado);