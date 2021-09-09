
CREATE DATABASE biblioteca;
\c biblioteca

CREATE TABLE libro(
    isbn VARCHAR(15) UNIQUE PRIMARY KEY,
    titulo VARCHAR(50),
    numero_paginas SMALLINT,
    dias_prestamo SMALLINT,
    stock BOOLEAN DEFAULT true
);

CREATE TABLE autor(
    codigo_autor SERIAL PRIMARY KEY,
    nombre VARCHAR(25),
    apellido VARCHAR(25),
    fecha_nacimiento INT,
    fecha_muerte INT NULL
); 

CREATE TABLE relacion_libro_autor(
    id_libro VARCHAR(15) REFERENCES libro(isbn),
    id_autor INT REFERENCES autor(codigo_autor),
    -- nuevo
    tipo_autor INT REFERENCES autor(codigo_autor),
        PRIMARY KEY (id_libro, id_autor, tipo_autor)
);
-- nuevo
CREATE TABLE tipo_autores(
    id_autor_tipo INT REFERENCES relacion_libro_autor(tipo_autor),
    nombre_autor_tipo VARCHAR (15),
        PRIMARY KEY id_autor_tipo,
);

CREATE TABLE prestamo(
    id_prestamo SERIAL PRIMARY KEY,
    codigo_libro VARCHAR(15),
    fecha_prestamo DATE,
    fecha_devolucion_posible DATE,
    fecha_devolucion DATE,
    FOREIGN KEY (codigo_libro) REFERENCES libro(isbn)
);

CREATE TABLE socio(
    rut VARCHAR(12) PRIMARY KEY,
    nombre VARCHAR(25),
    apellido VARCHAR(25),
    direccion VARCHAR(50) NOT NULL UNIQUE,
    telefono INT NOT NULL UNIQUE
); 

CREATE TABLE relacion_prestamo_socio(
    id_prestamo SERIAL REFERENCES prestamo(id_prestamo),
    id_socio VARCHAR(12) REFERENCES socio(rut),
    PRIMARY KEY (id_prestamo, id_socio)
);

-- 2

INSERT INTO libro(isbn, titulo, numero_paginas, dias_prestamo)
VALUES 
('111-1111111-111', 'CUENTOS DE TERROR', 344, 7),
('222-2222222-222', 'POESIAS CONTEMPORANEAS', 167, 7),
('333-3333333-333', 'HISTORIA DE ASIA', 511, 14),
('444-4444444-444', 'MANUAL DE MECÁNICA', 298, 14);

INSERT INTO autor(codigo_autor, nombre, apellido, fecha_nacimiento, fecha_muerte)
VALUES
(3, 'JOSE', 'SALGADO', 1968, 2020),
(4, 'ANA', 'SALGADO', 1972,NULL),  
(1, 'ANDRES', 'ULLOA', 1982,NULL),
(2, 'SERGIO', 'MARDONES', 1950, 2012),
(5, 'MARTIN', 'PORTA', 1976,NULL);

INSERT INTO relacion_libro_autor(id_libro, id_autor, tipo_autor)
VALUES 
('111-1111111-111', 3, "1"),
('111-1111111-111', 4, "2"),
('222-2222222-222', 1, "1"),
('333-3333333-333', 2, "1"),
('444-4444444-444', 5, "1");

INSERT INTO tipo_autores(id_autor_tipo, nombre_autor_tipo)
VALUES 
(1, "principal"),
(2, "co-autor"),


INSERT INTO socio(rut, nombre, apellido, direccion, telefono)
VALUES
('1111111-1', 'JUAN', 'SOTO', 'AVENIDA 1, SANTIAGO', 91111111),
('2222222-2', 'ANA', 'PEREZ', 'PASAJE 2, SANTIAGO', 92222222),
('3333333-3', 'SANDRA', 'AGUILAR', 'AVENIDA 2, SANTIAGO', 933333333),
('4444444-4', 'ESTEBAN', 'JEREZ', 'AVENIDA3, SANTIAGO', 944444444),
('5555555-5', 'SILVANA', 'MUNOZ', 'PASAJE 3, SANTIAGO', 955555555);

INSERT INTO prestamo(codigo_libro, fecha_prestamo, fecha_devolucion_posible, fecha_devolucion)
VALUES 
('111-1111111-111', '20-01-2020', '27-01-2020', '27-01-2020'), 
('222-2222222-222', '20-01-2020', '27-01-2020', '30-01-2020'), 
('333-3333333-333', '22-01-2020', '05-02-2020', '30-01-2020'),
('444-4444444-444', '23-01-2020', '06-02-2020', '30-01-2020'),
('111-1111111-111', '27-01-2020', '03-02-2020', '04-02-2020'),
('444-4444444-444', '31-01-2020', '14-02-2020', '12-02-2020'),
('222-2222222-222', '31-01-2020', '07-02-2020', '12-02-2020');

INSERT INTO relacion_prestamo_socio(id_socio)
VALUES
('5555555-5'),
('3333333-3'),
('4444444-4'),
('1111111-1'),
('2222222-2'),
('1111111-1'),
('3333333-3');


--3
-- a. Mostrar todos los libros que posean menos de 300 páginas.

SELECT  *
FROM libro
WHERE numero_paginas < 300;

-- b. Mostrar todos los autores que hayan nacido después del 01-01-1970.

SELECT  *
FROM autor
WHERE fecha_nacimiento >= 1970;

-- c. ¿Cuál es el libro más solicitado?

SELECT  titulo AS titulo_mas_vendido
       ,COUNT(codigo_libro)
FROM prestamo
INNER JOIN libro
ON prestamo.codigo_libro = libro.isbn
GROUP BY  titulo
ORDER BY count desc
LIMIT 1;

-- d. Si se cobrara una multa de $100 por cada día de atraso, mostrar cuánto debería pagar cada usuario que entregue el préstamo después de 7 días.

SELECT  codigo_libro
       ,dias_prestamo
       ,nombre
       ,apellido
       ,fecha_devolucion::DATE - fecha_prestamo::DATE - dias_prestamo       AS dias_de_atraso
       ,(fecha_devolucion::DATE - fecha_prestamo::DATE - dias_prestamo)*100 AS multa
FROM prestamo
INNER JOIN relacion_prestamo_socio
ON prestamo.id_prestamo = relacion_prestamo_socio.id_prestamo
INNER JOIN socio
ON relacion_prestamo_socio.id_socio = socio.rut
INNER JOIN libro
ON prestamo.codigo_libro = libro.isbn
WHERE fecha_devolucion::date - fecha_prestamo::date > 7
AND libro.dias_prestamo <= 7;


