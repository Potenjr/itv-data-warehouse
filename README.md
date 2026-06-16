# 🚗 ITV Inspection Analytics - Data Warehouse Project

## 📌 Overview

Este proyecto simula un sistema de análisis de inspecciones ITV utilizando un modelo de datos tipo **Data Warehouse (Star Schema)**.

El objetivo es analizar el rendimiento de estaciones ITV, vehículos, inspectores y tendencias temporales mediante SQL avanzado.

---

## 🎯 Project Objectives

- Diseñar un modelo dimensional (estrella)
- Simular datos realistas de inspecciones ITV
- Aplicar técnicas de limpieza y calidad de datos
- Realizar análisis exploratorio (EDA en SQL)
- Generar KPIs y métricas de negocio
- Utilizar SQL avanzado (CTEs, joins, window functions, etc.)

---

## 🧱 Database Structure

El modelo está compuesto por:

### 🔷 Fact Table
- fact_inspecciones

### 🔷 Dimension Tables
- dim_clientes
- dim_vehiculos
- dim_estaciones
- dim_inspectores
- dim_fechas

---

##  Project Structure

```bash

itv-inspection-analytics/
│
├── README.md
│
├── model/
│   ├── model.png
│   └── model_explanation.md
│
├── sql/
├── 01_schema.sql
├── 02_data.sql
├── 03_eda.sql
│
├── data/
│   └── sample_data_notes.md
│
└── docs/
    └── business_rules.md
```
---

## 📊 KPIs e Insights Clave

- ✔ Tasa de aprobación global y rendimiento por estación ITV  
- ✔ Ingresos generados por inspección y por estación  
- ✔ Comportamiento de vehículos con inspecciones recurrentes  
- ✔ Productividad de inspectores según volumen y facturación media  
- ✔ Distribución de la severidad de defectos en las inspecciones  
- ✔ Evolución temporal de inspecciones por meses  

---

## 🔍 Insights de Negocio

- Las estaciones con mayor volumen de inspecciones no siempre son las más eficientes en ingresos.
- Un grupo reducido de vehículos concentra múltiples inspecciones, lo que indica posibles problemas recurrentes de mantenimiento o reincidencias.
- La mayoría de inspecciones se clasifican como “BAJO RIESGO”, aunque existe un porcentaje relevante de casos con defectos graves.
- La productividad de los inspectores varía significativamente, lo que sugiere diferencias en carga de trabajo o asignación de inspecciones.

---

## 🛠 Tecnologías Utilizadas

- SQL (MySQL)
- Modelado de datos (Esquema en estrella)
- Conceptos ETL (limpieza y transformación de datos)
- SQL analítico (CTEs, funciones ventana, subconsultas)

---

## 📈 Aprendizajes del Proyecto

Este proyecto demuestra la capacidad de:

- Diseñar e implementar un Data Warehouse relacional
- Trabajar con datos reales simulados con errores y nulos
- Construir consultas analíticas orientadas a negocio
- Transformar datos en insights accionables

---

## 🚀 Conclusión

Este proyecto simula un entorno real de análisis de inspecciones ITV, permitiendo transformar datos operacionales en información estratégica.

A través del modelo en estrella y el análisis SQL, se identifican patrones clave de rendimiento, riesgo y eficiencia operativa, demostrando el potencial del análisis de datos para la toma de decisiones en sistemas industriales y administrativos.

## 👨‍💻 Autor

Adrián Potenciano  
Proyecto de SQL y Análisis de Datos

