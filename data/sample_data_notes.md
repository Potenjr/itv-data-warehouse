# ITV Inspection Analytics - Sample Data Notes

## Dataset Overview
Este proyecto utiliza datos simulados para representar un sistema de inspecciones ITV.

## Data Sources
Los datos han sido generados manualmente para simular:
- Clientes
- Vehículos
- Estaciones ITV
- Inspectores
- Fechas
- Inspecciones (fact table)

## Data Quality Considerations
Se han incluido intencionadamente:
- valores nulos (ej. provincia desconocida)
- duplicados lógicos (clientes o matrículas repetidas)
- inconsistencias controladas (fechas o registros repetidos)

Esto permite practicar limpieza y análisis de datos reales.

## Fact Table
La tabla principal es fact_inspecciones, que registra:
- relación entre dimensiones
- resultado de inspección
- defectos detectados
- importe de la inspección

## Purpose
El objetivo del dataset es simular un entorno de Data Warehouse para análisis de rendimiento ITV.