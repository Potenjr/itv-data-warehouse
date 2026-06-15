/*
Proyecto: ITV Inspection Analytics
Autor: Adrián Potenciano
Archivo: 02_data.sql
Descripción: Carga de datos simulados + ETL básico (staging lógico + calidad de datos)
*/

USE itv_db;

-- Este script simula la fase de carga
-- Se incluyen datos correctos, incompletos y erróneos de forma intencional
-- para permitir análisis de calidad de datos en el EDA.


-- CARGA DIM_CLIENTES


START TRANSACTION;

INSERT INTO dim_clientes (nombre, apellido, provincia, email, telefono, fecha_alta) VALUES
('Jorge', 'Fernández', 'Madrid', 'jorge.fernandez@mail.com', '600888888', '2023-03-15'),
('Raquel', 'Jiménez', 'Barcelona', NULL, '600999999', '2022-07-22'),
('Álvaro', 'Ramírez', 'Madrid', 'alvaro.ramirez@mail.com', NULL, '2021-12-01'),
('Laura', 'Hernández', 'Sevilla', NULL, NULL, '2024-01-10'),
('David', 'Torres', 'Madrid', 'david.torres@mail.com', '600123456', '2020-05-30'),
('Marta', 'Vidal', 'Toledo', 'marta.vidal@mail.com', '600654321', '2023-09-12'),
('Sergio', 'Mendoza', 'Valencia', NULL, '600111222', '2022-11-20'),
('Cristina', 'Ortega', 'Madrid', 'cristina.ortega@mail.com', '600333444', '2019-08-18'),
('Isabel', 'Navarro', 'Sevilla', NULL, NULL, '2024-02-05'),
('Pablo', 'Reyes', 'Barcelona', 'pablo.reyes@mail.com', '600555666', '2021-04-14'),

-- duplicados controlados (simulación de calidad de datos)
('Juan', 'García', 'Madrid', 'juan@gmail.com', '600111111', '2022-01-10'),
('María', 'López', 'Madrid', NULL, '600222222', '2021-05-20'),
('Carlos', 'Pérez', 'Toledo', 'carlos@gmail.com', NULL, '2020-03-15'),
('Ana', 'Sánchez', 'Desconocida', NULL, NULL, '2023-02-01'),
('Luis', 'Martín', 'Madrid', 'luis@gmail.com', '600333333', '2019-07-11');

COMMIT;



-- CARGA DIM_VEHICULOS


START TRANSACTION;

INSERT INTO dim_vehiculos (matricula, marca, modelo, combustible, anio_fabricacion, color) VALUES
('8899AAA', 'Seat', 'Toledo', 'Diesel', 2011, 'Gris'),
('9900BBB', 'Renault', 'Megane', 'Gasolina', 2015, 'Azul'),
('1112CCC', 'Ford', 'Fiesta', 'Gasolina', 2019, NULL),
('2233DDD', 'Volkswagen', 'Passat', 'Diesel', 2014, 'Negro'),
('3344EEE', 'Toyota', 'Yaris', 'Híbrido', 2021, 'Blanco'),
('4455FFF', 'Peugeot', '3008', 'Diesel', 2017, 'Rojo'),
('5566GGG', 'Opel', 'Astra', 'Gasolina', 2016, NULL),
('6677HHH', 'BMW', 'X3', 'Diesel', 2020, 'Gris'),
('7788III', 'Audi', 'Q5', 'Gasolina', 2018, 'Negro'),
('8899JJJ', 'Kia', 'Ceed', 'Diesel', 2019, 'Azul'),

-- duplicados intencionales (solo para testing de calidad)
('1234ABC', 'Seat', 'Ibiza', 'Gasolina', 2015, 'Rojo'),
('5678DEF', 'Renault', 'Clio', 'Diesel', 2012, NULL),
('1122JKL', 'Ford', 'Focus', 'Diesel', 2010, 'Blanco');

COMMIT;



-- CARGA DIM_ESTACIONES


INSERT INTO dim_estaciones (nombre_estacion, provincia, telefono_contacto) VALUES
('ITV Barcelona Norte', 'Barcelona', '930000001'),
('ITV Barcelona Sur', 'Barcelona', NULL),
('ITV Zaragoza Centro', 'Zaragoza', '976000002'),
('ITV Bilbao Norte', 'Vizcaya', NULL),
('ITV Málaga Este', 'Málaga', '952000003'),
('ITV Murcia Oeste', 'Murcia', '968000004'),
('ITV Alicante Sur', 'Alicante', NULL);



-- CARGA DIM_INSPECTORES


INSERT INTO dim_inspectores (nombre, categoria, fecha_contratacion, telefono) VALUES
('Carmen', 'Senior', '2013-08-14', '600555111'),
('Antonio', 'Junior', '2022-04-01', NULL),
('Patricia', 'Senior', '2011-11-20', '600666222'),
('Francisco', 'Junior', '2023-01-10', NULL),
('Teresa', 'Senior', '2014-05-05', '600777333'),
('Gabriel', 'Junior', '2022-08-25', NULL),
('Elena', 'Senior', '2017-02-14', '600888444');



-- CARGA DIM_FECHAS


INSERT INTO dim_fechas (fecha, mes, trimestre, anio, dia_semana, es_festivo) VALUES
('2024-01-01', 1, 1, 2024, 'Monday', 1),
('2024-02-14', 2, 1, 2024, 'Wednesday', 0),
('2024-03-15', 3, 1, 2024, 'Friday', 0),
('2024-04-01', 4, 2, 2024, 'Monday', 0),
('2024-05-20', 5, 2, 2024, 'Monday', 0),
('2024-06-24', 6, 2, 2024, 'Monday', 0),
('2024-07-12', 7, 3, 2024, 'Friday', 0),
('2024-08-15', 8, 3, 2024, 'Thursday', 1),
('2024-09-02', 9, 3, 2024, 'Monday', 0),
('2024-10-12', 10, 4, 2024, 'Saturday', 1);



-- CARGA FACT_INSPECCIONES (CONTROLADA Y COHERENTE)


START TRANSACTION;

INSERT INTO fact_inspecciones
(id_vehiculo, id_cliente, id_estacion, id_inspector, id_fecha, resultado, importe, defectos_leves, defectos_graves)
VALUES
(1,1,1,1,1,'APTA',50,0,0),
(2,2,2,2,2,'DESFAVORABLE',55,2,1),
(3,3,3,3,3,'APTA',60,1,0),
(4,4,4,4,4,'NEGATIVA',65,0,3),
(5,5,5,5,5,'APTA',70,0,0),
(6,6,1,2,6,'DESFAVORABLE',50,3,1),
(7,7,2,3,7,'APTA',55,1,0),
(8,8,3,4,8,'APTA',60,0,0),
(9,9,4,5,9,'DESFAVORABLE',65,2,2),
(10,10,5,1,10,'APTA',70,0,0);

COMMIT;


-- LIMPIEZA DE CALIDAD DE DATOS


-- Corrección de valores inválidos
UPDATE fact_inspecciones f
JOIN (
    SELECT id_inspeccion
    FROM fact_inspecciones
    WHERE importe IS NULL OR importe < 0
) x ON f.id_inspeccion = x.id_inspeccion
SET f.importe = 0;

-- Eliminación de extremos
DELETE f
FROM fact_inspecciones f
JOIN fact_inspecciones x
ON f.id_inspeccion = x.id_inspeccion
WHERE x.defectos_graves > 5;

-- Normalizacion de datos sucios
UPDATE dim_clientes c
JOIN (
    SELECT id_cliente
    FROM dim_clientes
    WHERE provincia IN ('Desconocida', '')
) x ON c.id_cliente = x.id_cliente
SET c.provincia = 'No especificada';