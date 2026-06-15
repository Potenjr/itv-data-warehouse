# ITV Inspection Analytics - Model Explanation

## Overview

Este proyecto sigue un modelo de datos tipo **Data Warehouse en esquema estrella (Star Schema)**, diseñado para el análisis de inspecciones ITV.

El objetivo es optimizar la consulta de datos para análisis, no para operación transaccional.

---

## 1. Estructura del modelo

El modelo se compone de:

### 🔷 Tabla de hechos
- fact_inspecciones

### 🔷 Tablas de dimensiones
- dim_clientes
- dim_vehiculos
- dim_estaciones
- dim_inspectores
- dim_fechas

---

## 2. Tabla de hechos (Fact Table)

### fact_inspecciones

Es la tabla central del modelo.

Contiene:
- métricas numéricas (importe, defectos)
- claves foráneas a dimensiones
- resultado de la inspección

Representa cada inspección realizada en el sistema ITV.

---

## 3. Tablas de dimensiones

### dim_clientes
Información sobre los propietarios de vehículos.

Campos clave:
- nombre
- apellido
- provincia
- fecha_alta

---

### dim_vehiculos
Información técnica de los vehículos.

Campos clave:
- matrícula (única)
- marca
- modelo
- combustible
- año de fabricación

---

### dim_estaciones
Información de las estaciones ITV.

Campos clave:
- nombre de estación
- provincia

---

### dim_inspectores
Información del personal inspector.

Campos clave:
- nombre
- categoría
- fecha de contratación

---

### dim_fechas
Dimensión temporal para análisis histórico.

Campos clave:
- fecha
- mes
- trimestre
- año
- día de la semana

---

## 4. Relaciones del modelo

La tabla de hechos se relaciona con las dimensiones mediante claves foráneas:

- fact_inspecciones.id_cliente → dim_clientes.id_cliente
- fact_inspecciones.id_vehiculo → dim_vehiculos.id_vehiculo
- fact_inspecciones.id_estacion → dim_estaciones.id_estacion
- fact_inspecciones.id_inspector → dim_inspectores.id_inspector
- fact_inspecciones.id_fecha → dim_fechas.id_fecha

---

## 5. Tipo de modelo

Este modelo es un:

- **Star Schema (Esquema en estrella)**

Porque:
- una tabla central de hechos
- múltiples dimensiones alrededor
- optimizado para análisis

---

## 6. Objetivo del modelo

Permitir análisis como:

- tasa de aprobación de ITV
- defectos por vehículo o provincia
- rendimiento de estaciones e inspectores
- evolución temporal de inspecciones

---

## 7. Uso en análisis

El modelo está diseñado para consultas SQL como:

- agregaciones (SUM, COUNT, AVG)
- JOINs entre dimensiones
- análisis temporal
- segmentación por atributos

---

## 8. Conclusión

Este modelo permite transformar datos operacionales en información analítica útil para la toma de decisiones en un entorno de inspección técnica de vehículos.