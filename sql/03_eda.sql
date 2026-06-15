/*
Proyecto: ITV Inspection Analytics
Autor: Adrián Potenciano
Archivo: 03_eda.sql

Descripción:
EDA completo del sistema ITV con análisis descriptivo, KPIs,
consultas analíticas y extracción de insights de negocio.
*/

USE itv_db;


-- 1. EXPLORACIÓN GENERAL DEL DATASET


-- Total de inspecciones registradas en el sistema
SELECT COUNT(*) AS total_inspecciones
FROM fact_inspecciones;



-- Distribución de resultados de inspección
SELECT resultado, COUNT(*) AS total
FROM fact_inspecciones
GROUP BY resultado
ORDER BY total DESC;



-- DETECCIÓN DE NULOS 


SELECT 'dim_clientes' AS tabla,
       SUM(nombre IS NULL OR apellido IS NULL OR provincia IS NULL 
           OR email IS NULL OR telefono IS NULL OR fecha_alta IS NULL) AS nulos
FROM dim_clientes

UNION ALL

SELECT 'dim_vehiculos',
       SUM(matricula IS NULL OR marca IS NULL OR modelo IS NULL 
           OR combustible IS NULL OR anio_fabricacion IS NULL OR color IS NULL)
FROM dim_vehiculos

UNION ALL

SELECT 'dim_estaciones',
       SUM(nombre_estacion IS NULL OR provincia IS NULL OR telefono_contacto IS NULL)
FROM dim_estaciones

UNION ALL

SELECT 'dim_inspectores',
       SUM(nombre IS NULL OR categoria IS NULL 
           OR fecha_contratacion IS NULL OR telefono IS NULL)
FROM dim_inspectores

UNION ALL

SELECT 'dim_fechas',
       SUM(fecha IS NULL OR mes IS NULL OR trimestre IS NULL 
           OR anio IS NULL OR dia_semana IS NULL OR es_festivo IS NULL)
FROM dim_fechas

UNION ALL

SELECT 'fact_inspecciones',
       SUM(id_vehiculo IS NULL OR id_cliente IS NULL OR id_estacion IS NULL 
           OR id_inspector IS NULL OR id_fecha IS NULL 
           OR resultado IS NULL OR importe IS NULL 
           OR defectos_leves IS NULL OR defectos_graves IS NULL)
FROM fact_inspecciones;



-- DETECCIÓN DE POSIBLES DUPLICADOS


-- Duplicados lógicos (misma inspección repetida por claves de negocio)
SELECT 
    id_vehiculo,
    id_cliente,
    id_fecha,
    COUNT(*) AS repeticiones
FROM fact_inspecciones
GROUP BY id_vehiculo, id_cliente, id_fecha
HAVING COUNT(*) > 1
ORDER BY repeticiones DESC;



-- 2. KPI PRINCIPAL: TASA DE APROBACIÓN


SELECT 
    COUNT(*) AS total_inspecciones,
    SUM(CASE WHEN resultado = 'APTA' THEN 1 ELSE 0 END) AS aprobadas,
    ROUND(
        SUM(CASE WHEN resultado = 'APTA' THEN 1 ELSE 0 END) / COUNT(*) * 100,
        2
    ) AS tasa_aprobacion
FROM fact_inspecciones;

/*
INSIGHT:

*/

-- 3. ANÁLISIS DE INGRESOS


SELECT 
    SUM(importe) AS ingresos_totales,
    AVG(importe) AS ingreso_medio
FROM fact_inspecciones;

/*
INSIGHT:

*/


-- 4. ANÁLISIS POR ESTACIÓN


SELECT 
    e.nombre_estacion,
    COUNT(f.id_inspeccion) AS total_inspecciones,
    SUM(CASE WHEN f.resultado = 'APTA' THEN 1 ELSE 0 END) AS aprobadas,
    AVG(f.importe) AS ingreso_medio
FROM fact_inspecciones f
JOIN dim_estaciones e ON f.id_estacion = e.id_estacion
GROUP BY e.nombre_estacion
ORDER BY total_inspecciones DESC;

/*
INSIGHT:


*/


-- 5. TOP CLIENTES CON MAS INSPECCIONES


SELECT 
    c.nombre,
    c.apellido,
    COUNT(f.id_inspeccion) AS total_inspecciones
FROM fact_inspecciones f
JOIN dim_clientes c ON f.id_cliente = c.id_cliente
GROUP BY c.id_cliente
ORDER BY total_inspecciones DESC
LIMIT 10;

/*
INSIGHT:

*/


-- 6. SUBQUERY: VEHÍCULOS MÁS INSPECCIONADOS



SELECT *
FROM dim_vehiculos
WHERE id_vehiculo IN (
    SELECT id_vehiculo
    FROM fact_inspecciones
    GROUP BY id_vehiculo
    HAVING COUNT(*) > 1
);

/*

*/


-- 7. CASE: CLASIFICACIÓN DE RIESGO


SELECT 
    id_inspeccion,
    defectos_graves,
    CASE
        WHEN defectos_graves = 0 THEN 'BAJO'
        WHEN defectos_graves BETWEEN 1 AND 2 THEN 'MEDIO'
        ELSE 'ALTO'
    END AS nivel_riesgo
FROM fact_inspecciones;

/*
INSIGHT:

*/


-- 8. MARCAS CON MAYOR NÚMERO DE DEFECTOS GRAVES

SELECT
    v.marca,
    COUNT(*) AS total_inspecciones,
    SUM(f.defectos_graves) AS total_defectos_graves,
    ROUND(AVG(f.defectos_graves),2) AS media_defectos_graves
FROM fact_inspecciones f
JOIN dim_vehiculos v
    ON f.id_vehiculo = v.id_vehiculo
GROUP BY v.marca
ORDER BY media_defectos_graves DESC;

/*
INSIGHT:

Permite identificar qué marcas acumulan una mayor cantidad de defectos graves
durante las inspecciones.

Esta información puede ayudar a detectar patrones de mantenimiento deficientes
o posibles tendencias asociadas a determinados fabricantes.
*/


Sí, el 8 y el 9 ahora mismo analizan prácticamente lo mismo que el 7 y el 6. Para subir nota, yo los cambiaría por preguntas de negocio más interesantes.

8. ¿Qué marcas presentan más incidencias graves?
-- 8. MARCAS CON MAYOR NÚMERO DE DEFECTOS GRAVES

SELECT
    v.marca,
    COUNT(*) AS total_inspecciones,
    SUM(f.defectos_graves) AS total_defectos_graves,
    ROUND(AVG(f.defectos_graves),2) AS media_defectos_graves
FROM fact_inspecciones f
JOIN dim_vehiculos v
    ON f.id_vehiculo = v.id_vehiculo
GROUP BY v.marca
ORDER BY media_defectos_graves DESC;

/*
INSIGHT:

Permite identificar qué marcas acumulan una mayor cantidad de defectos graves
durante las inspecciones.

Esta información puede ayudar a detectar patrones de mantenimiento deficientes
o posibles tendencias asociadas a determinados fabricantes.
*/
9. ¿Qué inspectores realizan más inspecciones?
-- 9. PRODUCTIVIDAD DE INSPECTORES

SELECT
    i.nombre,
    i.categoria,
    COUNT(f.id_inspeccion) AS total_inspecciones,
    ROUND(AVG(f.importe),2) AS importe_medio
FROM fact_inspecciones f
JOIN dim_inspectores i
    ON f.id_inspector = i.id_inspector
GROUP BY i.id_inspector, i.nombre, i.categoria
ORDER BY total_inspecciones DESC;

/*
INSIGHT:

Permite medir la carga de trabajo de cada inspector y detectar posibles
desequilibrios en la asignación de inspecciones.

También facilita identificar empleados con mayor experiencia operativa
y evaluar la distribución de recursos dentro de las estaciones ITV.
*/

-- 
-- 10. WINDOW FUNCTION: MEDIA DE INGRESOS POR VEHÍCULO
-- 

SELECT 
    id_inspeccion,
    id_vehiculo,
    importe,
    AVG(importe) OVER (PARTITION BY id_vehiculo) AS media_por_vehiculo
FROM fact_inspecciones;

/*
INSIGHT:

*/

-- 
-- 11. ANÁLISIS TEMPORAL AÑO 2024
-- 

SELECT 
    d.anio,
    d.mes,
    COUNT(*) AS total_inspecciones,
    SUM(CASE WHEN f.resultado = 'APTA' THEN 1 ELSE 0 END) AS aprobadas
FROM fact_inspecciones f
JOIN dim_fechas d ON f.id_fecha = d.id_fecha
GROUP BY d.anio, d.mes
ORDER BY d.anio, d.mes;

/*
INSIGHT:

*/

-- 
-- 12. INGRESOS POR ESTACIÓN
-- 
-- añadir media de ingresos por inspecciones
SELECT 
    e.nombre_estacion,
    SUM(f.importe) AS ingresos_totales
FROM fact_inspecciones f
JOIN dim_estaciones e ON f.id_estacion = e.id_estacion
GROUP BY e.nombre_estacion
ORDER BY ingresos_totales DESC;

/*
INSIGHT:

*/

-- 
-- 13. ESTADÍSTICAS DE DEFECTOS
-- 

SELECT 
    AVG(defectos_graves) AS media_defectos_graves,
    MAX(defectos_graves) AS max_defectos,
    MIN(defectos_graves) AS min_defectos
FROM fact_inspecciones;

/*
INSIGHT:
Mide la severidad general del parque automovilístico.
Valores altos indican necesidad de mantenimiento preventivo.
*/