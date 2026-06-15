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
├── 02_inserts.sql
├── 03_quality_checks.sql
├── 04_views.sql
├── 05_analysis.sql
│
├── data/
│   └── sample_data_notes.md
│
└── docs/
    └── business_rules.md
