# ITV Inspection Analytics - Business Rules

## Overview
Este documento define las reglas de negocio del sistema de inspecciones ITV utilizado en el proyecto.

El objetivo es asegurar coherencia en el análisis de datos y establecer criterios claros para la interpretación de resultados.

---

## 1. Inspecciones ITV

Cada inspección representa una revisión técnica realizada a un vehículo en una estación ITV en una fecha determinada.

Una inspección siempre está asociada a:
- Un vehículo
- Un cliente
- Una estación ITV
- Un inspector
- Una fecha

---

## 2. Resultados de inspección

Los resultados posibles son:

- **APTA** → el vehículo cumple los requisitos técnicos
- **DESFAVORABLE** → el vehículo presenta defectos leves o corregibles
- **NEGATIVA** → el vehículo presenta defectos graves que impiden circular

---

## 3. Defectos

Se registran dos tipos de defectos:

- defectos_leves → no impiden la circulación inmediata
- defectos_graves → implican fallo grave en la inspección

Reglas:
- defectos_graves >= 0
- defectos_leves >= 0
- No se permiten valores negativos

---

## 4. Reglas de negocio de importes

- El campo importe representa el coste de la inspección
- Debe ser siempre >= 0
- Puede variar según estación o tipo de inspección

---

## 5. Clientes

Cada cliente representa el propietario de uno o varios vehículos.

- Un cliente puede tener múltiples inspecciones
- Se permiten valores incompletos o nulos en provincia para simular datos reales

---

## 6. Vehículos

Cada vehículo es identificado por su matrícula.

Reglas:
- matrícula debe ser única
- año de fabricación > 1950
- un vehículo puede tener múltiples inspecciones en el tiempo

---

## 7. Estaciones ITV

Cada inspección se realiza en una estación ITV.

- Una estación puede realizar múltiples inspecciones
- Se agrupan por provincia

---

## 8. Inspectores

Cada inspección es realizada por un inspector.

- Un inspector puede realizar múltiples inspecciones
- Se usa para análisis de rendimiento y carga de trabajo

---

## 9. Fechas

Las inspecciones se analizan temporalmente mediante una dimensión de fechas.

Permite análisis por:
- día
- mes
- trimestre
- año

---

## 10. Objetivo del modelo

Este modelo permite:
- analizar la calidad automovilística
- detectar patrones de fallos
- evaluar estaciones e inspectores
- estudiar evolución temporal de inspecciones