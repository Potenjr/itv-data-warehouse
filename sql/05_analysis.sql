/*
Proyecto: ITV Inspection Analytics
Autor: Adrián Potenciano
Archivo: 05_analysis.sql
Descripción: Análisis avanzado con SQL (KPIs, subqueries, CTEs, ventanas, joins, transacciones)
*/

USE itv_db;


-- INSERCIÓN DE DATOS ADICIONALES 


INSERT INTO dim_clientes (nombre, apellido, provincia, fecha_alta)
VALUES ('Laura', 'Nieto', 'Madrid', '2024-01-10');


-- UPDATE MASIVO CON TRANSACCIÓN


START TRANSACTION;

UPDATE fact_inspecciones
SET importe = importe * 1.05
WHERE resultado = 'APTA';

-- Si algo falla
 ROLLBACK;

COMMIT;




-- CONVERSIÓN DE TIPOS (CAST)


SELECT 
    id_inspeccion,
    CAST(importe AS CHAR) AS importe_texto
FROM fact_inspecciones;


-- FUNCIONES DE FECHA


SELECT 
    d.fecha,
    YEAR(d.fecha) AS anio,
    MONTH(d.fecha) AS mes,
    DAYNAME(d.fecha) AS dia_semana
FROM dim_fechas d;


-- AGREGACIONES (SUM / COUNT / AVG)


SELECT 
    COUNT(*) AS total_inspecciones,
    SUM(defectos_graves) AS total_graves,
    AVG(importe) AS media_importe
FROM fact_inspecciones;


-- SUBQUERY (VEHÍCULOS CON MÁS DE 1 INSPECCIÓN)


SELECT *
FROM dim_vehiculos
WHERE id_vehiculo IN (
    SELECT id_vehiculo
    FROM fact_inspecciones
    GROUP BY id_vehiculo
    HAVING COUNT(*) > 1
);


-- JOINS (3+ TABLAS)


SELECT 
    f.id_inspeccion,
    c.nombre AS cliente,
    v.marca,
    e.nombre_estacion,
    i.nombre AS inspector
FROM fact_inspecciones f
INNER JOIN dim_clientes c ON f.id_cliente = c.id_cliente
INNER JOIN dim_vehiculos v ON f.id_vehiculo = v.id_vehiculo
INNER JOIN dim_estaciones e ON f.id_estacion = e.id_estacion
INNER JOIN dim_inspectores i ON f.id_inspector = i.id_inspector;

-- LEFT JOIN (detección de datos incompletos)
SELECT 
    f.id_inspeccion,
    c.nombre
FROM fact_inspecciones f
LEFT JOIN dim_clientes c ON f.id_cliente = c.id_cliente;


-- CASE (CLASIFICACIÓN DE RIESGO)


SELECT 
    id_inspeccion,
    defectos_graves,
    CASE 
        WHEN defectos_graves = 0 THEN 'BAJO'
        WHEN defectos_graves BETWEEN 1 AND 2 THEN 'MEDIO'
        ELSE 'ALTO'
    END AS nivel_riesgo
FROM fact_inspecciones;


-- CTE SIMPLE


WITH inspecciones_por_vehiculo AS (
    SELECT id_vehiculo, COUNT(*) AS total
    FROM fact_inspecciones
    GROUP BY id_vehiculo
)
SELECT *
FROM inspecciones_por_vehiculo;


--  CTE ENCADENADO (AVANZADO)


WITH base AS (
    SELECT id_vehiculo, COUNT(*) AS total
    FROM fact_inspecciones
    GROUP BY id_vehiculo
),
filtrado AS (
    SELECT *
    FROM base
    WHERE total > 1
)
SELECT *
FROM filtrado;


-- WINDOW FUNCTION (OVER PARTITION)


SELECT 
    id_inspeccion,
    id_vehiculo,
    importe,
    AVG(importe) OVER (PARTITION BY id_vehiculo) AS media_por_vehiculo
FROM fact_inspecciones;

-- RANKING DE INSPECCIONES POR VEHÍCULO


SELECT 
    v.matricula,
    COUNT(f.id_inspeccion) AS total_inspecciones,
    SUM(f.defectos_graves) AS total_graves
FROM fact_inspecciones f
JOIN dim_vehiculos v ON f.id_vehiculo = v.id_vehiculo
GROUP BY v.id_vehiculo, v.matricula
HAVING COUNT(f.id_inspeccion) >= 1
ORDER BY total_inspecciones DESC;

-- INSIGHTS CLAVE

-- 14. ESTACIONES CON MEJOR TASA DE APROBACIÓN


SELECT 
    e.nombre_estacion,
    COUNT(*) AS total_inspecciones,
    SUM(CASE WHEN f.resultado = 'APTA' THEN 1 ELSE 0 END) AS aprobadas,
    ROUND(
        SUM(CASE WHEN f.resultado = 'APTA' THEN 1 ELSE 0 END) / COUNT(*) * 100,
        2
    ) AS tasa_aprobacion
FROM fact_inspecciones f
JOIN dim_estaciones e ON f.id_estacion = e.id_estacion
GROUP BY e.id_estacion, e.nombre_estacion
ORDER BY tasa_aprobacion DESC;



-- 15. PROVINCIAS CON MAYOR NIVEL DE DEFECTOS


SELECT 
    c.provincia,
    COUNT(*) AS total_inspecciones,
    SUM(f.defectos_graves) AS total_defectos_graves,
    ROUND(AVG(f.defectos_graves), 2) AS media_defectos_graves
FROM fact_inspecciones f
JOIN dim_clientes c ON f.id_cliente = c.id_cliente
GROUP BY c.provincia
ORDER BY media_defectos_graves DESC;



-- 16. VEHÍCULOS CON MAYOR PROBLEMATICA


SELECT 
    v.matricula,
    COUNT(*) AS total_inspecciones,
    SUM(f.defectos_graves) AS total_defectos_graves
FROM fact_inspecciones f
JOIN dim_vehiculos v ON f.id_vehiculo = v.id_vehiculo
GROUP BY v.id_vehiculo, v.matricula
HAVING SUM(f.defectos_graves) > 1
ORDER BY total_defectos_graves DESC;



-- 17. INSPECTORES MÁS ESTRICTOS


SELECT 
    i.nombre,
    COUNT(*) AS total_inspecciones,
    SUM(CASE WHEN f.resultado = 'NEGATIVA' THEN 1 ELSE 0 END) AS negativas_detectadas
FROM fact_inspecciones f
JOIN dim_inspectores i ON f.id_inspector = i.id_inspector
GROUP BY i.id_inspector, i.nombre
ORDER BY negativas_detectadas DESC;



-- 18. EVOLUCIÓN MENSUAL DE INSPECCIONES Y APROBACIONES


SELECT 
    d.anio,
    d.mes,
    COUNT(*) AS total_inspecciones,
    SUM(CASE WHEN f.resultado = 'APTA' THEN 1 ELSE 0 END) AS aprobadas,
    ROUND(
        SUM(CASE WHEN f.resultado = 'APTA' THEN 1 ELSE 0 END) / COUNT(*) * 100,
        2
    ) AS tasa_aprobacion
FROM fact_inspecciones f
JOIN dim_fechas d ON f.id_fecha = d.id_fecha
GROUP BY d.anio, d.mes
ORDER BY d.anio, d.mes;
