/*
Proyecto: ITV Inspection Analytics
Autor: Adrián Potenciano
Descripción: Validación y limpieza de datos (Data Quality Layer)
*/

USE itv_db;


-- 1. DETECCIÓN DE VALORES NULOS


-- Clientes con provincia no válida o vacía
SELECT *
FROM dim_clientes
WHERE provincia IS NULL 
   OR provincia = ''
   OR TRIM(provincia) = '';

-- Vehículos con datos incompletos
SELECT *
FROM dim_vehiculos
WHERE marca IS NULL OR modelo IS NULL;

-- Inspecciones con importes inválidos
SELECT *
FROM fact_inspecciones
WHERE importe IS NULL OR importe < 0;


-- 2. DETECCIÓN DE DUPLICADOS


-- Clientes duplicados (mismo nombre y apellido)
SELECT nombre, apellido, COUNT(*) AS duplicados
FROM dim_clientes
GROUP BY nombre, apellido
HAVING COUNT(*) > 1;

-- Vehículos duplicados por matrícula
SELECT matricula, COUNT(*) AS duplicados
FROM dim_vehiculos
GROUP BY matricula
HAVING COUNT(*) > 1;


-- 3. CONSISTENCIA DE FECHAS (REGLA DE NEGOCIO)
-- mes debe coincidir con MONTH(fecha)


SELECT *
FROM dim_fechas
WHERE mes <> MONTH(fecha);

-- =========================================================
-- 4. CORRECCIÓN DE DATOS (UPDATE)
-- =========================================================

-- Reemplazar nulos en clientes
UPDATE dim_clientes
SET provincia = 'Desconocida'
WHERE provincia IS NULL;

-- Asegurar importes válidos en fact

SET SQL_SAFE_UPDATES = 0;

UPDATE fact_inspecciones
SET importe = 0
WHERE id_inspeccion IS NOT NULL
AND (importe < 0 OR importe IS NULL);


-- 5. ELIMINACIÓN DE DUPLICADOS (si fuera necesario)


-- Ejemplo: eliminar duplicados de clientes dejando el más antiguo
DELETE c1
FROM dim_clientes c1
INNER JOIN dim_clientes c2
WHERE c1.id_cliente > c2.id_cliente
AND c1.nombre = c2.nombre
AND c1.apellido = c2.apellido;


-- 6. CASE: CLASIFICACIÓN DE INSPECCIONES


SELECT 
    id_inspeccion,
    resultado,
    defectos_graves,
    CASE 
        WHEN resultado = 'APTA' THEN 'OK'
        WHEN resultado = 'DESFAVORABLE' AND defectos_graves <= 2 THEN 'REVISABLE'
        ELSE 'CRÍTICA'
    END AS nivel_riesgo
FROM fact_inspecciones;


-- 7. SUBQUERY: VEHÍCULOS CON MÁS INSPECCIONES QUE LA MEDIA

SELECT *
FROM dim_vehiculos
WHERE id_vehiculo IN (
    SELECT id_vehiculo
    FROM fact_inspecciones
    GROUP BY id_vehiculo
    HAVING COUNT(*) > (
        SELECT AVG(total_inspecciones)
        FROM (
            SELECT COUNT(*) AS total_inspecciones
            FROM fact_inspecciones
            GROUP BY id_vehiculo
        ) AS sub
    )
);



-- 8. VALIDACIÓN DE INTEGRIDAD (JOIN CHECK)


-- Verificar integridad de relaciones
SELECT f.id_inspeccion
FROM fact_inspecciones f
LEFT JOIN dim_vehiculos v ON f.id_vehiculo = v.id_vehiculo
WHERE v.id_vehiculo IS NULL;


-- 9. MÉTRICAS DE CALIDAD


-- % de inspecciones defectuosas
SELECT 
    COUNT(*) AS total,
    SUM(CASE WHEN resultado = 'APTA' THEN 1 ELSE 0 END) AS aptas,
    ROUND(
        SUM(CASE WHEN resultado = 'APTA' THEN 1 ELSE 0 END) / COUNT(*) * 100,
        2
    ) AS porcentaje_aprobadas
FROM fact_inspecciones;

