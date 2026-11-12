-- Datos ficticios para demostración académica.
-- Generados con IA.
USE taller_reparaciones;

-- Lista de clientes
INSERT INTO cliente (id_cliente, nombres, apellidos, telefono, correo) VALUES
(1, 'Ana', 'López', '5550-1001', 'ana@example.test'),
(2, 'Pedro', 'Díaz', '5550-1002', 'pedro@example.test'),
(3, 'Carla', 'Morales', '5550-1003', 'carla@example.test'),
(4, 'Diego', 'Castillo', '5550-1004', 'diego@example.test'),
(5, 'Sofía', 'Reyes', '5550-1005', 'sofia@example.test'),
(6, 'Miguel', 'Torres', '5550-1006', 'miguel@example.test')
AS nuevo
ON DUPLICATE KEY UPDATE nombres=nuevo.nombres, apellidos=nuevo.apellidos, telefono=nuevo.telefono, correo=nuevo.correo;

-- Lista de vehículos
INSERT INTO vehiculo (id_vehiculo, id_cliente, placa, marca, modelo, anio, color) VALUES
(1, 1, 'P123ABC', 'Toyota', 'Corolla', 2018, 'Gris'),
(2, 2, 'P456DEF', 'Honda', 'Civic', 2017, 'Azul'),
(3, 3, 'P789GHI', 'Mazda', 'Mazda 3', 2020, 'Rojo'),
(4, 4, 'P234JKL', 'Hyundai', 'Elantra', 2019, 'Blanco'),
(5, 1, 'P567MNO', 'Nissan', 'Sentra', 2016, 'Negro'),
(6, 5, 'P890PQR', 'Kia', 'Rio', 2021, 'Plata'),
(7, 6, 'P345STU', 'Chevrolet', 'Spark', 2015, 'Verde'),
(8, 2, 'P678VWX', 'Volkswagen', 'Jetta', 2018, 'Gris'),
(9, 3, 'P901YZA', 'Ford', 'Focus', 2022, 'Azul'),
(10, 4, 'P112BCD', 'Toyota', 'Yaris', 2020, 'Blanco')
AS nuevo
ON DUPLICATE KEY UPDATE id_cliente=nuevo.id_cliente, placa=nuevo.placa, marca=nuevo.marca, modelo=nuevo.modelo, anio=nuevo.anio, color=nuevo.color;

-- Lista de mecánicos
INSERT INTO mecanico (id_mecanico, nombres, apellidos, telefono, activo) VALUES
(1, 'Luis', 'Pérez', '5551-2001', 1),
(2, 'María', 'García', '5551-2002', 1),
(3, 'José', 'Ramírez', '5551-2003', 1),
(4, 'Elena', 'Méndez', '5551-2004', 1)
AS nuevo
ON DUPLICATE KEY UPDATE nombres=nuevo.nombres, apellidos=nuevo.apellidos, telefono=nuevo.telefono, activo=nuevo.activo;

-- Lista de servicios 
INSERT INTO servicio (id_servicio, nombre, descripcion, precio_referencia, activo) VALUES
(1, 'Cambio de aceite', 'Cambio de aceite y revisión básica de niveles', 250.00, 1),
(2, 'Revisión de frenos', 'Inspección y ajuste del sistema de frenos', 450.00, 1),
(3, 'Alineación', 'Alineación de dirección y tren delantero', 300.00, 1),
(4, 'Diagnóstico del motor', 'Lectura de códigos y diagnóstico general', 350.00, 1),
(5, 'Reparación eléctrica', 'Diagnóstico y reparación del sistema eléctrico', 850.00, 1)
AS nuevo
ON DUPLICATE KEY UPDATE nombre=nuevo.nombre, descripcion=nuevo.descripcion, precio_referencia=nuevo.precio_referencia, activo=nuevo.activo;

-- Lista de repuestos
INSERT INTO repuesto (id_repuesto, nombre, descripcion, precio_actual, existencia, activo) VALUES
(1, 'Filtro de aceite', 'Filtro compatible con varios modelos', 75.00, 40, 1),
(2, 'Aceite de motor', 'Aceite multigrado por litro', 55.00, 120, 1),
(3, 'Pastillas de freno', 'Juego de pastillas delanteras', 350.00, 16, 1),
(4, 'Bujía', 'Bujía estándar para motor a gasolina', 60.00, 50, 1),
(5, 'Bombilla de faro', 'Bombilla halógena 12V', 45.00, 30, 1),
(6, 'Batería', 'Batería automotriz 12V', 650.00, 8, 1),
(7, 'Fusible', 'Fusible automotriz surtido', 15.00, 60, 1),
(8, 'Filtro de aire', 'Filtro de aire del motor', 90.00, 25, 1),
(9, 'Correa auxiliar', 'Correa de accesorios del motor', 240.00, 10, 1),
(10, 'Refrigerante', 'Refrigerante por litro', 65.00, 35, 1)
AS nuevo
ON DUPLICATE KEY UPDATE nombre=nuevo.nombre, descripcion=nuevo.descripcion, precio_actual=nuevo.precio_actual, existencia=nuevo.existencia, activo=nuevo.activo;

-- Lista de órdenes de reparaciónes
INSERT INTO orden_reparacion
  (id_orden, id_vehiculo, id_responsable, fecha_recepcion, fecha_entrega, problema_reportado, estado) VALUES
(1, 1, 1, '2026-01-05 08:00:00', '2026-01-06 16:00:00', 'Mantenimiento y falla eléctrica intermitente', 'ENTREGADA'),
(2, 1, 1, '2026-01-19 09:00:00', '2026-01-20 15:00:00', 'Cambio de aceite y revisión de luces', 'ENTREGADA'),
(3, 1, 2, '2026-02-03 08:30:00', '2026-02-05 17:00:00', 'Revisar sistema eléctrico y testigo del motor', 'ENTREGADA'),
(4, 2, 2, '2026-02-16 08:00:00', '2026-02-17 16:00:00', 'Ruido al frenar y mantenimiento', 'ENTREGADA'),
(5, 3, 1, '2026-03-05 09:00:00', '2026-03-06 14:00:00', 'Servicio preventivo y vibración en dirección', 'ENTREGADA'),
(6, 4, 3, '2026-03-21 08:00:00', '2026-03-22 15:30:00', 'Revisión de frenos y niveles', 'ENTREGADA'),
(7, 5, 1, '2026-04-08 08:00:00', '2026-04-09 17:00:00', 'Mantenimiento y reparación de cableado', 'ENTREGADA'),
(8, 6, 4, '2026-04-19 08:30:00', '2026-04-20 13:00:00', 'Mantenimiento y pérdida de potencia', 'ENTREGADA'),
(9, 7, 2, '2026-05-02 09:00:00', '2026-05-03 12:00:00', 'Falla en faro y alineación', 'ENTREGADA'),
(10, 8, 3, '2026-05-22 08:00:00', '2026-05-23 15:00:00', 'Revisión de frenos y mantenimiento', 'ENTREGADA'),
(11, 9, 1, '2026-06-09 08:00:00', '2026-06-10 16:00:00', 'Servicio preventivo y diagnóstico', 'ENTREGADA'),
(12, 10, 4, '2026-07-01 08:00:00', NULL, 'Falla eléctrica y revisión de frenos', 'EN_PROCESO'),
(13, 1, 2, '2026-07-17 08:30:00', NULL, 'Alineación y mantenimiento preventivo', 'FINALIZADA'),
(14, 5, 4, '2026-08-04 09:00:00', NULL, 'Mantenimiento preventivo', 'ABIERTA')
AS nuevo
ON DUPLICATE KEY UPDATE id_vehiculo=nuevo.id_vehiculo, id_responsable=nuevo.id_responsable, fecha_recepcion=nuevo.fecha_recepcion, fecha_entrega=nuevo.fecha_entrega, problema_reportado=nuevo.problema_reportado, estado=nuevo.estado;

-- Lista de detalles de servicios
INSERT INTO detalle_servicio
  (id_detalle_servicio, id_orden, id_servicio, cantidad, precio_unitario_aplicado, observaciones) VALUES
(1, 1, 1, 1.00, 240.00, 'Precio aplicado en la fecha de la orden'),
(2, 1, 5, 1.00, 1000.00, 'Reparación del circuito de luces'),
(3, 1, 4, 1.00, 350.00, 'Diagnóstico inicial'),
(4, 2, 1, 1.00, 250.00, NULL),
(5, 2, 5, 1.00, 1000.00, 'Revisión de luces'),
(6, 3, 1, 1.00, 260.00, NULL),
(7, 3, 5, 1.00, 1000.00, 'Reparación de cableado'),
(8, 4, 2, 1.00, 450.00, NULL),
(9, 4, 1, 1.00, 250.00, NULL),
(10, 5, 1, 1.00, 250.00, NULL),
(11, 5, 3, 1.00, 300.00, NULL),
(12, 6, 1, 1.00, 255.00, NULL),
(13, 6, 2, 1.00, 450.00, 'Ajuste de frenos'),
(14, 7, 1, 1.00, 260.00, NULL),
(15, 7, 5, 1.00, 700.00, 'Reparación eléctrica adicional'),
(16, 8, 1, 1.00, 260.00, NULL),
(17, 8, 4, 1.00, 350.00, NULL),
(18, 9, 3, 1.00, 300.00, NULL),
(19, 9, 5, 1.00, 750.00, 'Reparación de faro'),
(20, 10, 2, 1.00, 450.00, NULL),
(21, 10, 1, 1.00, 260.00, NULL),
(22, 11, 1, 1.00, 260.00, NULL),
(23, 11, 4, 1.00, 350.00, NULL),
(24, 12, 5, 1.00, 850.00, 'Orden aún en proceso'),
(25, 12, 2, 1.00, 450.00, NULL),
(26, 13, 1, 1.00, 270.00, NULL),
(27, 13, 3, 1.00, 320.00, NULL),
(28, 14, 1, 1.00, 280.00, NULL)
AS nuevo
ON DUPLICATE KEY UPDATE id_orden=nuevo.id_orden, id_servicio=nuevo.id_servicio, cantidad=nuevo.cantidad, precio_unitario_aplicado=nuevo.precio_unitario_aplicado, observaciones=nuevo.observaciones;

-- Lista de detalles de repuestos
INSERT INTO detalle_repuesto
  (id_detalle_repuesto, id_orden, id_repuesto, cantidad, precio_unitario_aplicado) VALUES
(1, 1, 1, 1, 75.00), (2, 1, 2, 4, 55.00), (3, 1, 4, 4, 60.00),
(4, 2, 1, 1, 75.00), (5, 2, 2, 4, 55.00), (6, 2, 5, 2, 45.00), (7, 2, 7, 1, 15.00),
(8, 3, 1, 1, 75.00), (9, 3, 2, 4, 55.00), (10, 3, 6, 1, 650.00), (11, 3, 7, 2, 15.00),
(12, 4, 1, 1, 75.00), (13, 4, 2, 4, 55.00), (14, 4, 3, 1, 350.00),
(15, 5, 1, 1, 75.00), (16, 5, 2, 4, 55.00), (17, 5, 8, 1, 90.00),
(18, 6, 3, 1, 350.00), (19, 6, 10, 2, 65.00),
(20, 7, 1, 1, 75.00), (21, 7, 2, 4, 55.00), (22, 7, 9, 1, 240.00), (23, 7, 5, 1, 45.00),
(24, 8, 1, 1, 75.00), (25, 8, 2, 4, 55.00), (26, 8, 4, 4, 60.00), (27, 8, 8, 1, 90.00),
(28, 9, 5, 1, 45.00), (29, 9, 7, 1, 15.00),
(30, 10, 1, 1, 75.00), (31, 10, 2, 4, 55.00), (32, 10, 3, 1, 350.00),
(33, 11, 1, 1, 75.00), (34, 11, 2, 4, 55.00), (35, 11, 8, 1, 90.00), (36, 11, 4, 4, 60.00),
(37, 12, 6, 1, 650.00), (38, 12, 7, 3, 15.00), (39, 12, 5, 1, 45.00),
(40, 13, 1, 1, 75.00), (41, 13, 2, 4, 55.00), (42, 13, 10, 2, 65.00),
(43, 14, 1, 1, 75.00), (44, 14, 2, 4, 55.00)
AS nuevo
ON DUPLICATE KEY UPDATE id_orden=nuevo.id_orden, id_repuesto=nuevo.id_repuesto, cantidad=nuevo.cantidad, precio_unitario_aplicado=nuevo.precio_unitario_aplicado;

-- Lista de participación de mecánicos
INSERT INTO participacion_mecanico
  (id_orden, id_mecanico, trabajo_realizado, horas_trabajadas) VALUES
(1, 1, 'Mantenimiento general', 2.50), (1, 2, 'Revisión eléctrica', 1.00),
(2, 1, 'Cambio de aceite y luces', 2.00), (2, 3, 'Apoyo eléctrico', 1.00),
(3, 1, 'Diagnóstico y reparación', 2.75), (3, 2, 'Revisión del cableado', 1.00),
(4, 1, 'Mantenimiento', 1.50), (4, 2, 'Servicio de frenos', 2.00),
(5, 1, 'Servicio preventivo', 1.00), (5, 3, 'Alineación', 1.00),
(6, 1, 'Mantenimiento', 2.00), (6, 4, 'Inspección de frenos', 1.00),
(7, 1, 'Mantenimiento y cableado', 3.00), (7, 2, 'Prueba eléctrica', 0.50),
(8, 1, 'Mantenimiento', 2.00), (8, 4, 'Diagnóstico de motor', 0.75),
(9, 2, 'Alineación', 2.00), (9, 3, 'Reparación de faro', 1.00),
(10, 2, 'Revisión de frenos', 1.50), (10, 3, 'Mantenimiento', 1.00),
(11, 1, 'Servicio y diagnóstico', 2.00), (11, 4, 'Apoyo de diagnóstico', 0.75),
(12, 1, 'Reparación eléctrica', 3.00), (12, 4, 'Revisión de frenos', 2.00),
(13, 2, 'Alineación y mantenimiento', 2.50),
(14, 4, 'Mantenimiento preventivo', 1.50)
AS nuevo
ON DUPLICATE KEY UPDATE trabajo_realizado=nuevo.trabajo_realizado, horas_trabajadas=nuevo.horas_trabajadas;
