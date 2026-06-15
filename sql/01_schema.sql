/*
Proyecto: ITV Inspection Analytics
Autor: Adrián Potenciano
Archivo: 01_schema.sql
Descripción: Creación de base de datos y modelo dimensional para análisis de inspecciones ITV
Modelo: Star Schema optimizado para análisis BI
*/

-- CREACIÓN DE BASE DE DATOS

CREATE DATABASE IF NOT EXISTS itv_db;
USE itv_db;


-- DIMENSIÓN: CLIENTES

-- Información de los propietarios de vehículos
-- Incluye campos opcionales para simular datos reales (email, teléfono)

CREATE TABLE dim_clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    provincia VARCHAR(50) NOT NULL,
    email VARCHAR(150),
    telefono VARCHAR(20),
    fecha_alta DATE NOT NULL
) ENGINE=InnoDB;


-- DIMENSIÓN: VEHÍCULOS

-- Información técnica de los vehículos inspeccionados
-- Campo opcional "color" para simular datos incompletos

CREATE TABLE dim_vehiculos (
    id_vehiculo INT PRIMARY KEY AUTO_INCREMENT,
    matricula VARCHAR(10) NOT NULL UNIQUE,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    combustible VARCHAR(20) NOT NULL,
    anio_fabricacion INT NOT NULL,
    color VARCHAR(30),
    CHECK (anio_fabricacion > 1950)
) ENGINE=InnoDB;


-- DIMENSIÓN: ESTACIONES ITV

-- Centros donde se realizan inspecciones

CREATE TABLE dim_estaciones (
    id_estacion INT PRIMARY KEY AUTO_INCREMENT,
    nombre_estacion VARCHAR(100) NOT NULL,
    provincia VARCHAR(50) NOT NULL,
    telefono_contacto VARCHAR(20)
) ENGINE=InnoDB;


-- DIMENSIÓN: INSPECTORES

-- Personal encargado de realizar inspecciones

CREATE TABLE dim_inspectores (
    id_inspector INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    fecha_contratacion DATE NOT NULL,
    telefono VARCHAR(20)
) ENGINE=InnoDB;


-- DIMENSIÓN: FECHAS

-- Dimensión temporal para análisis por día, mes, trimestre y año

CREATE TABLE dim_fechas (
    id_fecha INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    mes INT NOT NULL,
    trimestre INT NOT NULL,
    anio INT NOT NULL,
    dia_semana VARCHAR(20) NOT NULL,
    es_festivo BOOLEAN NULL
) ENGINE=InnoDB;


-- TABLA DE HECHOS: INSPECCIONES

-- Tabla central del modelo estrella con métricas y claves foráneas

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


-- ÍNDICES DE OPTIMIZACIÓN

-- Mejoran rendimiento en consultas analíticas frecuentes sobre fechas, resultados y combinaciones comunes

CREATE INDEX idx_fact_fecha ON fact_inspecciones(id_fecha);
CREATE INDEX idx_fact_resultado ON fact_inspecciones(resultado);

CREATE INDEX idx_fact_estacion_fecha 
ON fact_inspecciones(id_estacion, id_fecha);


-- FUNCIÓN DE NEGOCIO 

-- Clasifica el riesgo de una inspección según defectos graves

DELIMITER //

CREATE FUNCTION fn_clasificar_riesgo(graves INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE riesgo VARCHAR(20);

    IF graves = 0 THEN
        SET riesgo = 'BAJO';
    ELSEIF graves <= 2 THEN
        SET riesgo = 'MEDIO';
    ELSE
        SET riesgo = 'ALTO';
    END IF;

    RETURN riesgo;
END //

DELIMITER ;