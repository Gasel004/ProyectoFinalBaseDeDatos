-- Siete consultas solicitadas en el enunciado.
USE taller_reparaciones;

-- 5.1 Resumen de órdenes. Cada tipo de detalle se suma primero por orden para
-- evitar la multiplicación de filas al combinar servicios y repuestos.
WITH total_servicios AS (
    SELECT id_orden, SUM(cantidad * precio_unitario_aplicado) AS subtotal_servicios
    FROM detalle_servicio
    GROUP BY id_orden
), total_repuestos AS (
    SELECT id_orden, SUM(cantidad * precio_unitario_aplicado) AS subtotal_repuestos
    FROM detalle_repuesto
    GROUP BY id_orden
)
SELECT
    o.id_orden,
    o.fecha_recepcion,
    CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
    v.placa,
    CONCAT(m.nombres, ' ', m.apellidos) AS mecanico_responsable,
    COALESCE(ts.subtotal_servicios, 0) + COALESCE(tr.subtotal_repuestos, 0) AS costo_total
FROM orden_reparacion AS o
INNER JOIN vehiculo AS v ON v.id_vehiculo = o.id_vehiculo
INNER JOIN cliente AS c ON c.id_cliente = v.id_cliente
INNER JOIN mecanico AS m ON m.id_mecanico = o.id_responsable
LEFT JOIN total_servicios AS ts ON ts.id_orden = o.id_orden
LEFT JOIN total_repuestos AS tr ON tr.id_orden = o.id_orden
ORDER BY costo_total DESC, o.fecha_recepcion DESC;

-- 5.2 Historial de reparaciones por vehículo. Se incluyen vehículos sin órdenes
-- con costo y cantidad iguales a cero.
WITH total_servicios AS (
    SELECT id_orden, SUM(cantidad * precio_unitario_aplicado) AS subtotal_servicios
    FROM detalle_servicio
    GROUP BY id_orden
), total_repuestos AS (
    SELECT id_orden, SUM(cantidad * precio_unitario_aplicado) AS subtotal_repuestos
    FROM detalle_repuesto
    GROUP BY id_orden
), total_orden AS (
    SELECT o.id_orden, o.id_vehiculo,
           COALESCE(ts.subtotal_servicios, 0) + COALESCE(tr.subtotal_repuestos, 0) AS costo_orden
    FROM orden_reparacion AS o
    LEFT JOIN total_servicios AS ts ON ts.id_orden = o.id_orden
    LEFT JOIN total_repuestos AS tr ON tr.id_orden = o.id_orden
)
SELECT
    v.placa,
    v.marca,
    CONCAT(c.nombres, ' ', c.apellidos) AS propietario,
    COUNT(t.id_orden) AS cantidad_ordenes,
    COALESCE(SUM(t.costo_orden), 0) AS costo_acumulado
FROM vehiculo AS v
INNER JOIN cliente AS c ON c.id_cliente = v.id_cliente
LEFT JOIN total_orden AS t ON t.id_vehiculo = v.id_vehiculo
GROUP BY v.id_vehiculo, v.placa, v.marca, c.id_cliente, c.nombres, c.apellidos
ORDER BY costo_acumulado DESC, v.placa;

-- 5.3 Mecánicos con más de cinco órdenes de participación y sus horas.
SELECT
    m.id_mecanico,
    CONCAT(m.nombres, ' ', m.apellidos) AS mecanico,
    COUNT(DISTINCT pm.id_orden) AS ordenes_participadas,
    SUM(pm.horas_trabajadas) AS horas_trabajadas
FROM mecanico AS m
INNER JOIN participacion_mecanico AS pm ON pm.id_mecanico = m.id_mecanico
GROUP BY m.id_mecanico, m.nombres, m.apellidos
HAVING COUNT(DISTINCT pm.id_orden) > 5
ORDER BY ordenes_participadas DESC, horas_trabajadas DESC;

-- 5.4 Servicios realizados en más de cinco órdenes. El ingreso se calcula con
-- el precio histórico guardado en cada detalle.
SELECT
    s.id_servicio,
    s.nombre AS servicio,
    COUNT(DISTINCT ds.id_orden) AS cantidad_ordenes,
    SUM(ds.cantidad * ds.precio_unitario_aplicado) AS importe_facturado
FROM servicio AS s
INNER JOIN detalle_servicio AS ds ON ds.id_servicio = s.id_servicio
GROUP BY s.id_servicio, s.nombre
HAVING COUNT(DISTINCT ds.id_orden) > 5
ORDER BY cantidad_ordenes DESC, importe_facturado DESC;

-- 5.5 Repuestos cuya cantidad total utilizada supera diez unidades.
SELECT
    r.id_repuesto,
    r.nombre AS repuesto,
    SUM(dr.cantidad) AS cantidad_total,
    SUM(dr.cantidad * dr.precio_unitario_aplicado) AS importe_total
FROM repuesto AS r
INNER JOIN detalle_repuesto AS dr ON dr.id_repuesto = r.id_repuesto
GROUP BY r.id_repuesto, r.nombre
HAVING SUM(dr.cantidad) > 10
ORDER BY cantidad_total DESC, importe_total DESC;

-- 5.6 Ingresos por cliente y servicio, mostrando combinaciones con importe
-- estrictamente superior a Q2,000.
SELECT
    c.id_cliente,
    CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
    s.nombre AS tipo_servicio,
    COUNT(DISTINCT ds.id_orden) AS cantidad_ordenes,
    SUM(ds.cantidad * ds.precio_unitario_aplicado) AS importe_servicios
FROM cliente AS c
INNER JOIN vehiculo AS v ON v.id_cliente = c.id_cliente
INNER JOIN orden_reparacion AS o ON o.id_vehiculo = v.id_vehiculo
INNER JOIN detalle_servicio AS ds ON ds.id_orden = o.id_orden
INNER JOIN servicio AS s ON s.id_servicio = ds.id_servicio
GROUP BY c.id_cliente, c.nombres, c.apellidos, s.id_servicio, s.nombre
HAVING SUM(ds.cantidad * ds.precio_unitario_aplicado) > 2000
ORDER BY importe_servicios DESC, cliente, tipo_servicio;

-- 5.7 Clientes cuyo gasto total supera el promedio de gasto por cliente.
-- El promedio incluye clientes registrados sin órdenes, cuyo gasto es cero.
WITH total_servicios AS (
    SELECT id_orden, SUM(cantidad * precio_unitario_aplicado) AS subtotal_servicios
    FROM detalle_servicio
    GROUP BY id_orden
), total_repuestos AS (
    SELECT id_orden, SUM(cantidad * precio_unitario_aplicado) AS subtotal_repuestos
    FROM detalle_repuesto
    GROUP BY id_orden
), gasto_cliente AS (
    SELECT
        c.id_cliente,
        c.nombres,
        c.apellidos,
        COALESCE(SUM(COALESCE(ts.subtotal_servicios, 0) + COALESCE(tr.subtotal_repuestos, 0)), 0) AS gasto_total
    FROM cliente AS c
    LEFT JOIN vehiculo AS v ON v.id_cliente = c.id_cliente
    LEFT JOIN orden_reparacion AS o ON o.id_vehiculo = v.id_vehiculo
    LEFT JOIN total_servicios AS ts ON ts.id_orden = o.id_orden
    LEFT JOIN total_repuestos AS tr ON tr.id_orden = o.id_orden
    GROUP BY c.id_cliente, c.nombres, c.apellidos
)
SELECT
    id_cliente,
    CONCAT(nombres, ' ', apellidos) AS cliente,
    gasto_total
FROM gasto_cliente
WHERE gasto_total > (SELECT AVG(gasto_total) FROM gasto_cliente)
ORDER BY gasto_total DESC, cliente;
