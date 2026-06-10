/*
Proyecto: ITV Inspection Analytics
Autor: Adrián Potenciano
Descripción: Inserción de datos simulados para análisis
*/

USE itv_db;


-- DIM_CLIENTES

INSERT INTO dim_clientes (nombre, apellido, provincia, fecha_alta) VALUES
('Juan', 'García', 'Madrid', '2022-01-10'),
('María', 'López', 'Madrid', '2021-05-20'),
('Carlos', 'Pérez', 'Toledo', '2020-03-15'),
('Ana', 'Sánchez', 'Madrid', '2023-02-01'), 
('Luis', 'Martín', 'Madrid', '2019-07-11'),
('Lucía', 'Gómez', 'Sevilla', '2021-09-30'),
('Pedro', 'Ruiz', 'Valencia', '2020-11-25'),
('Elena', 'Díaz', 'Madrid', '2022-06-14'),
('Sara', 'Moreno', 'Toledo', '2023-01-08'),
('Miguel', 'Hernández', 'Sevilla', '2018-04-19'),
('María', 'López', 'Madrid', '2021-05-20'), -- duplicado lógico
('Alberto', 'Ruiz', 'Madrid', '2023-05-10'),
('Carmen', 'Vega', 'Valencia', '2022-09-12'),
('Raúl', 'Ortega', 'Toledo', '2021-03-22'),
('Sergio', 'Navarro', 'Sevilla', '2020-12-05'),
('Adrian', 'Potenciano', '', '2020-12-06'); -- Datos incompletos simulando nulos


INSERT INTO dim_vehiculos (matricula, marca, modelo, combustible, anio_fabricacion) VALUES
('1234ABC', 'Seat', 'Ibiza', 'Gasolina', 2015),
('5678DEF', 'Renault', 'Clio', 'Diesel', 2012),
('9101GHI', 'Volkswagen', 'Golf', 'Gasolina', 2018),
('1122JKL', 'Ford', 'Focus', 'Diesel', 2010),
('3344MNO', 'Toyota', 'Corolla', 'Híbrido', 2020),
('5566PQR', 'Peugeot', '208', 'Gasolina', 2016),
('7788STU', 'Opel', 'Corsa', 'Gasolina', 2014),
('9900VWX', 'BMW', 'Serie 1', 'Diesel', 2019),
('1111YYY', 'Audi', 'A3', 'Gasolina', 2017),
('2222ZZZ', 'Seat', 'León', 'Diesel', 2013),
('4455LMN', 'Kia', 'Sportage', 'Diesel', 2019),
('6677OPQ', 'Hyundai', 'i30', 'Gasolina', 2016),
('8899RST', 'Mazda', '3', 'Gasolina', 2018),
('0000AAA', 'Mercedes', 'Clase A', 'Diesel', 2021);


-- DIM_ESTACIONES

INSERT INTO dim_estaciones (nombre_estacion, provincia) VALUES
('ITV Madrid Sur', 'Madrid'),
('ITV Getafe', 'Madrid'),
('ITV Toledo Centro', 'Toledo'),
('ITV Sevilla Norte', 'Sevilla'),
('ITV Valencia Oeste', 'Valencia'),
('ITV Madrid Norte', 'Madrid'),
('ITV Sevilla Sur', 'Sevilla');


-- DIM_INSPECTORES

INSERT INTO dim_inspectores (nombre, categoria, fecha_contratacion) VALUES
('Alberto', 'Senior', '2015-06-01'),
('Laura', 'Junior', '2020-09-15'),
('David', 'Senior', '2012-03-20'),
('Sofía', 'Junior', '2021-11-10'),
('Javier', 'Senior', '2010-01-05'),
('Rubén', 'Junior', '2022-02-18'),
('Marta', 'Senior', '2016-07-09');


-- DIM_FECHAS

INSERT INTO dim_fechas (fecha, mes, trimestre, anio, dia_semana) VALUES
('2025-01-10', 1, 1, 2025, 'Friday'),
('2025-02-15', 2, 1, 2025, 'Saturday'),
('2025-03-20', 3, 1, 2025, 'Thursday'),
('2025-04-25', 4, 2, 2025, 'Friday'),
('2025-05-10', 5, 2, 2025, 'Saturday'),
('2025-06-18', 6, 2, 2025, 'Wednesday'),
('2025-02-15', 2, 1, 2025, 'Saturday'), 
('2025-07-10', 10, 7, 2025, 'Friday');   


-- FACT_INSPECCIONES

INSERT INTO fact_inspecciones 
(id_vehiculo, id_cliente, id_estacion, id_inspector, id_fecha, resultado, importe, defectos_leves, defectos_graves)
VALUES
(1, 1, 1, 1, 1, 'APTA', 50, 0, 0),
(2, 2, 2, 2, 2, 'DESFAVORABLE', 55, 2, 1),
(3, 3, 3, 3, 3, 'APTA', 60, 1, 0),
(4, 4, 4, 4, 4, 'NEGATIVA', 65, 0, 3),
(5, 5, 5, 5, 5, 'APTA', 70, 0, 0),
(6, 6, 6, 6, 6, 'DESFAVORABLE', 50, 3, 1),
(7, 7, 7, 7, 7, 'APTA', 55, 1, 0),
(8, 8, 1, 1, 8, 'APTA', 60, 0, 0),
(9, 9, 2, 2, 1, 'DESFAVORABLE', 65, 2, 2),
(10, 10, 3, 3, 2, 'APTA', 70, 0, 0),

(11, 11, 4, 4, 3, 'APTA', 50, 0, 0),
(12, 12, 5, 5, 4, 'DESFAVORABLE', 55, 2, 1),
(13, 13, 6, 6, 5, 'APTA', 60, 0, 0),
(14, 14, 7, 7, 6, 'NEGATIVA', 65, 0, 4),

(1, 1, 2, 2, 7, 'APTA', 50, 0, 0),
(2, 2, 3, 3, 8, 'DESFAVORABLE', 55, 1, 1),
(3, 3, 4, 4, 1, 'APTA', 60, 0, 0),
(4, 4, 5, 5, 2, 'NEGATIVA', 65, 0, 3),
(5, 5, 6, 6, 3, 'APTA', 70, 0, 0),
(6, 6, 7, 7, 4, 'DESFAVORABLE', 50, 2, 2),

(7, 7, 1, 1, 5, 'APTA', 55, 0, 0),
(8, 8, 2, 2, 6, 'APTA', 60, 1, 0),
(9, 9, 3, 3, 7, 'DESFAVORABLE', 65, 2, 1),
(10, 10, 4, 4, 8, 'APTA', 70, 0, 0);
