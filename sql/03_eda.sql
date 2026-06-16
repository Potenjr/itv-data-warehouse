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

La tasa de aprobación del sistema ITV es del 71,43%, con 15 inspecciones aptas de un total de 21 realizadas.

Este resultado indica que aproximadamente 7 de cada 10 vehículos superan la inspección en el primer intento, mientras que el 28,57% restante presenta defectos que requieren una nueva revisión o una reparación previa.

Desde el punto de vista del negocio, este porcentaje refleja un nivel de cumplimiento elevado, aunque sigue existiendo un volumen relevante de inspecciones no aptas que generan segundas revisiones y, por tanto, actividad e ingresos adicionales para las estaciones ITV.
*/

-- 3. ANÁLISIS DE INGRESOS


SELECT 
    SUM(importe) AS ingresos_totales,
    AVG(importe) AS ingreso_medio
FROM fact_inspecciones;

/*
INSIGHT:

Las 21 inspecciones realizadas han generado unos ingresos totales de 1.275 €, con un ingreso medio de 60,71 € por inspección.

El importe medio se mantiene bastante estable, lo que indica una política de precios homogénea entre las diferentes revisiones realizadas. Además, el volumen de ingresos está impulsado tanto por las inspecciones iniciales como por las segundas revisiones derivadas de resultados desfavorables o negativos, aumentando la rentabilidad del servicio sin necesidad de captar nuevos clientes.
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

La estación ITV Barcelona Sur destaca como el centro con mejor rendimiento del conjunto, acumulando 5 inspecciones y alcanzando una tasa de aprobación del 100%, lo que refleja una alta eficacia operativa y un parque de vehículos en buen estado. 

Por otro lado, ITV Málaga Este presenta el mayor ingreso medio por inspección (70 €), mientras que estaciones como ITV Barcelona Norte, ITV Bilbao Norte e ITV Murcia Oeste muestran una mayor presencia de inspecciones con incidencias, ya que únicamente una de cada tres revisiones finaliza con resultado favorable.
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

Jorge Fernández y Raquel Jiménez son los clientes más recurrentes del sistema, con 4 inspecciones cada uno, lo que refleja un seguimiento periódico de sus vehículos y una alta fidelidad al servicio ITV. 

Además, la presencia de varios clientes con más de una inspección confirma que el conjunto de datos simula adecuadamente situaciones reales, incluyendo revisiones periódicas, segundas inspecciones tras resultados desfavorables y mantenimiento continuado del vehículo a lo largo del tiempo.
*/


-- 6. SUBQUERY: VEHÍCULOS MÁS INSPECCIONADOS 



SELECT 
    v.id_vehiculo,
    v.matricula,
    v.marca,
    v.modelo,
    t.total_inspecciones
FROM dim_vehiculos v
JOIN (
    SELECT 
        id_vehiculo,
        COUNT(*) AS total_inspecciones
    FROM fact_inspecciones
    GROUP BY id_vehiculo
    ORDER BY total_inspecciones DESC
    LIMIT 3
) t
ON v.id_vehiculo = t.id_vehiculo;

/*
INSIGHT:

Los vehículos más inspeccionados son el Renault Megane (4 inspecciones), el Seat Toledo (3) y el Renault Clio (3), lo que indica dos patrones claros en el sistema:

1. Vehículos con incidencias recurrentes: el Megane concentra el mayor número de inspecciones, lo que sugiere posibles fallos repetidos o revisiones consecutivas tras resultados desfavorables.
2. Reinspecciones tras fallo: la presencia de varios vehículos con 3 inspecciones refuerza el comportamiento típico del sistema ITV, donde un mismo vehículo puede pasar varias revisiones hasta obtener un resultado favorable.
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

La distribución del nivel de riesgo está fuertemente concentrada en la categoría BAJO, lo que indica que la mayoría de inspecciones no presentan defectos graves o estos son inexistentes.

Sin embargo, existe un grupo reducido de inspecciones en nivel MEDIO y ALTO que representa los casos críticos del sistema. Estos casos deben considerarse prioritarios dentro del modelo ITV, ya que concentran los vehículos con mayor probabilidad de requerir intervención mecánica o revisión inmediata.

En conjunto, el sistema muestra una base mayoritariamente estable, con una minoría de inspecciones que concentran el riesgo operativo.
*/


-- 8. DISTRIBUCIÓN DE INSPECCIONES POR NIVEL DE RIESGO

SELECT
    fn_clasificar_riesgo(defectos_graves) AS nivel_riesgo,
    COUNT(*) AS total_inspecciones
FROM fact_inspecciones
GROUP BY fn_clasificar_riesgo(defectos_graves)
ORDER BY total_inspecciones DESC;

/*
INSIGHT:

La mayor parte de las inspecciones se concentran en el nivel de riesgo BAJO (15 casos), lo que confirma que el parque de vehículos analizado presenta un estado general adecuado y con pocos defectos graves.

No obstante, existen 4 inspecciones en riesgo MEDIO y 2 en riesgo ALTO, lo que representa aproximadamente un 28% del total de inspecciones con algún grado de riesgo relevante. Esto sugiere que, aunque la situación global es positiva, hay un volumen no despreciable de vehículos que requieren seguimiento o intervención para evitar que evolucionen hacia fallos más graves.
*/


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

La carga de trabajo entre inspectores está relativamente equilibrada, con Antonio y Teresa como los más productivos (5 inspecciones cada uno), seguidos por Patricia (3).

Se observa además que no existe una relación directa entre categoría y volumen de inspecciones, ya que tanto perfiles Junior como Senior aparecen mezclados en los niveles más altos de actividad.

En cuanto al importe medio, los inspectores Senior tienden a gestionar inspecciones con importes ligeramente superiores en algunos casos, lo que puede estar asociado a inspecciones más complejas o vehículos con mayor nivel de revisión.
*/


-- 10. WINDOW FUNCTION: MEDIA DE INGRESOS POR VEHÍCULO


SELECT 
    id_inspeccion,
    id_vehiculo,
    importe,
    AVG(importe) OVER (PARTITION BY id_vehiculo) AS media_por_vehiculo
FROM fact_inspecciones;

/*
INSIGHT:

El análisis de media de ingresos por vehículo muestra una gran estabilidad en los precios de inspección, ya que cada vehículo mantiene prácticamente el mismo importe en todas sus revisiones.

Esto indica que el sistema ITV no está aplicando variaciones de precio significativas por vehículo dentro del periodo analizado, lo que sugiere una política de tarificación fija por tipo de inspección más que por historial del vehículo.

Además, se observa que los vehículos con múltiples inspecciones (como el id 12 o el id 2) no presentan variaciones en el coste, lo que refuerza la idea de que las reinspecciones no generan cambios económicos en el modelo actual.
*/


-- 11. ANÁLISIS TEMPORAL AÑO 2024


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

El volumen de inspecciones se concentra principalmente en los meses centrales del año (mayo, agosto y octubre), lo que sugiere una estacionalidad clara en la actividad ITV.

En términos de rendimiento, se observa una mejora progresiva en la tasa de aprobaciones a partir de abril, alcanzando meses como mayo, julio y agosto con un 100% de aprobaciones.

Sin embargo, meses como febrero, marzo y junio muestran una ausencia total de inspecciones favorables, lo que puede indicar periodos con mayor proporción de vehículos en mal estado o revisiones más exigentes.
*/


-- 12. INGRESOS POR ESTACIÓN

SELECT 
    e.nombre_estacion,
    SUM(f.importe) AS ingresos_totales
FROM fact_inspecciones f
JOIN dim_estaciones e ON f.id_estacion = e.id_estacion
GROUP BY e.nombre_estacion
ORDER BY ingresos_totales DESC;

/*
INSIGHT:

Los ingresos están claramente concentrados en unas pocas estaciones, destacando ITV Málaga Este y ITV Barcelona Sur como los principales motores de facturación.

Estas estaciones no solo generan más volumen de inspecciones, sino que también mantienen importes medios elevados, lo que sugiere una combinación de alta demanda y tarifas sostenidas.

En el extremo inferior, ITV Alicante Sur y Zaragoza Centro presentan una baja contribución a ingresos, lo que puede indicar menor volumen operativo o menor rotación de vehículos en esas zonas.
*/
 

-- 13. ESTADÍSTICAS DE DEFECTOS
 

SELECT 
    AVG(defectos_graves) AS media_defectos_graves,
    MAX(defectos_graves) AS max_defectos,
    MIN(defectos_graves) AS min_defectos
FROM fact_inspecciones;

/*
INSIGHT:

La media de defectos graves es baja (0.76 por inspección), con un máximo de 5 defectos en casos puntuales y un mínimo de 0, lo que indica que la mayoría de vehículos no presentan problemas graves en la inspección.

Esto sugiere que el parque de vehículos analizado tiene un estado general aceptable, aunque existen casos aislados con fallos severos que elevan el riesgo y deberían ser objeto de seguimiento específico para evitar reincidencias o fallos críticos en futuras inspecciones.

*/