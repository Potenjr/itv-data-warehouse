/*
Proyecto: ITV Inspection Analytics
Autor: Adrián Potenciano
Descripción: Vistas de negocio para análisis de inspecciones ITV
*/

USE itv_db;

-- =========================================================
-- 1. VISTA: RESUMEN DE INSPECCIONES POR ESTACIÓN
-- =========================================================

CREATE OR REPLACE VIEW vw_inspecciones_por_estacion AS
SELECT 
    e.id_estacion,
    e.nombre_estacion,
    COUNT(f.id_inspeccion) AS total_inspecciones,
    SUM(CASE WHEN f.resultado = 'APTA' THEN 1 ELSE 0 END) AS aptas,
    SUM(CASE WHEN f.resultado = 'DESFAVORABLE' THEN 1 ELSE 0 END) AS desfavorables,
    SUM(CASE WHEN f.resultado = 'NEGATIVA' THEN 1 ELSE 0 END) AS negativas
FROM fact_inspecciones f
JOIN dim_estaciones e ON f.id_estacion = e.id_estacion
GROUP BY e.id_estacion, e.nombre_estacion;

SELECT * FROM vw_inspecciones_por_estacion;

-- =========================================================
-- 2. VISTA: TASA DE APROBACIÓN POR PROVINCIA
-- =========================================================

CREATE OR REPLACE VIEW vw_tasa_aprobacion_provincia AS
SELECT 
    c.provincia,
    COUNT(f.id_inspeccion) AS total_inspecciones,
    SUM(CASE WHEN f.resultado = 'APTA' THEN 1 ELSE 0 END) AS aptas,
    ROUND(
        SUM(CASE WHEN f.resultado = 'APTA' THEN 1 ELSE 0 END) / COUNT(*) * 100,
        2
    ) AS porcentaje_aprobadas
FROM fact_inspecciones f
JOIN dim_clientes c ON f.id_cliente = c.id_cliente
GROUP BY c.provincia;

SELECT * FROM vw_tasa_aprobacion_provincia;

-- =========================================================
-- 3. VISTA: INSPECCIONES POR TIPO DE VEHÍCULO
-- =========================================================

CREATE OR REPLACE VIEW vw_inspecciones_por_combustible AS
SELECT 
    v.combustible,
    COUNT(f.id_inspeccion) AS total_inspecciones,
    AVG(f.importe) AS media_importe,
    SUM(f.defectos_graves) AS total_defectos_graves
FROM fact_inspecciones f
JOIN dim_vehiculos v ON f.id_vehiculo = v.id_vehiculo
GROUP BY v.combustible;

SELECT * FROM vw_inspecciones_por_combustible;

-- =========================================================
-- 4. VISTA: RENDIMIENTO DE INSPECTORES
-- =========================================================

CREATE OR REPLACE VIEW vw_rendimiento_inspectores AS
SELECT 
    i.id_inspector,
    i.nombre,
    i.categoria,
    COUNT(f.id_inspeccion) AS total_inspecciones,
    SUM(CASE WHEN f.resultado = 'NEGATIVA' THEN 1 ELSE 0 END) AS negativas_detectadas
FROM fact_inspecciones f
JOIN dim_inspectores i ON f.id_inspector = i.id_inspector
GROUP BY i.id_inspector, i.nombre, i.categoria;

SELECT * FROM vw_rendimiento_inspectores;

-- =========================================================
-- 5. VISTA: EVOLUCIÓN TEMPORAL DE INSPECCIONES
-- =========================================================

CREATE OR REPLACE VIEW vw_evolucion_mensual AS
SELECT 
    d.anio,
    d.mes,
    COUNT(f.id_inspeccion) AS total_inspecciones,
    SUM(CASE WHEN f.resultado = 'APTA' THEN 1 ELSE 0 END) AS aptas
FROM fact_inspecciones f
JOIN dim_fechas d ON f.id_fecha = d.id_fecha
GROUP BY d.anio, d.mes
ORDER BY d.anio, d.mes;

SELECT * FROM vw_evolucion_mensual