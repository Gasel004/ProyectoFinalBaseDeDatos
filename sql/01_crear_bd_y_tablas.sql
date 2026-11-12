-- Taller de reparaciones automotrices
-- Requiere MySQL 8.0.16 o superior para que se apliquen las restricciones CHECK.

CREATE DATABASE IF NOT EXISTS taller_reparaciones
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE taller_reparaciones;

CREATE TABLE cliente (
    id_cliente INT NOT NULL AUTO_INCREMENT,
    nombres VARCHAR(80) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    telefono VARCHAR(25) NULL,
    correo VARCHAR(120) NULL,
    PRIMARY KEY (id_cliente)
) ENGINE=InnoDB;

CREATE TABLE vehiculo (
    id_vehiculo INT NOT NULL AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    placa VARCHAR(15) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    anio SMALLINT NULL,
    color VARCHAR(30) NULL,
    PRIMARY KEY (id_vehiculo),
    CONSTRAINT uq_vehiculo_placa UNIQUE (placa),
    CONSTRAINT chk_vehiculo_anio CHECK (anio IS NULL OR anio >= 1886),
    CONSTRAINT fk_vehiculo_cliente
      FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE mecanico (
    id_mecanico INT NOT NULL AUTO_INCREMENT,
    nombres VARCHAR(80) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    telefono VARCHAR(25) NULL,
    activo TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (id_mecanico),
    CONSTRAINT chk_mecanico_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB;

CREATE TABLE orden_reparacion (
    id_orden INT NOT NULL AUTO_INCREMENT,
    id_vehiculo INT NOT NULL,
    id_responsable INT NOT NULL,
    fecha_recepcion DATETIME NOT NULL,
    fecha_entrega DATETIME NULL,
    problema_reportado TEXT NOT NULL,
    estado ENUM('ABIERTA', 'EN_PROCESO', 'FINALIZADA', 'ENTREGADA') NOT NULL DEFAULT 'ABIERTA',
    PRIMARY KEY (id_orden),
    CONSTRAINT chk_orden_fechas CHECK (fecha_entrega IS NULL OR fecha_entrega >= fecha_recepcion),
    CONSTRAINT chk_orden_entregada CHECK (estado <> 'ENTREGADA' OR fecha_entrega IS NOT NULL),
    CONSTRAINT fk_orden_vehiculo
      FOREIGN KEY (id_vehiculo) REFERENCES vehiculo (id_vehiculo)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_orden_responsable
      FOREIGN KEY (id_responsable) REFERENCES mecanico (id_mecanico)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE servicio (
    id_servicio INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    precio_referencia DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    activo TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (id_servicio),
    CONSTRAINT uq_servicio_nombre UNIQUE (nombre),
    CONSTRAINT chk_servicio_precio CHECK (precio_referencia >= 0),
    CONSTRAINT chk_servicio_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB;

CREATE TABLE detalle_servicio (
    id_detalle_servicio INT NOT NULL AUTO_INCREMENT,
    id_orden INT NOT NULL,
    id_servicio INT NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL DEFAULT 1.00,
    precio_unitario_aplicado DECIMAL(10,2) NOT NULL,
    observaciones VARCHAR(255) NULL,
    PRIMARY KEY (id_detalle_servicio),
    CONSTRAINT chk_detalle_servicio_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_servicio_precio CHECK (precio_unitario_aplicado >= 0),
    CONSTRAINT fk_detalle_servicio_orden
      FOREIGN KEY (id_orden) REFERENCES orden_reparacion (id_orden)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalle_servicio_catalogo
      FOREIGN KEY (id_servicio) REFERENCES servicio (id_servicio)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE repuesto (
    id_repuesto INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    precio_actual DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    existencia INT NOT NULL DEFAULT 0,
    activo TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (id_repuesto),
    CONSTRAINT uq_repuesto_nombre UNIQUE (nombre),
    CONSTRAINT chk_repuesto_precio CHECK (precio_actual >= 0),
    CONSTRAINT chk_repuesto_existencia CHECK (existencia >= 0),
    CONSTRAINT chk_repuesto_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB;

CREATE TABLE detalle_repuesto (
    id_detalle_repuesto INT NOT NULL AUTO_INCREMENT,
    id_orden INT NOT NULL,
    id_repuesto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario_aplicado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_detalle_repuesto),
    CONSTRAINT chk_detalle_repuesto_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_repuesto_precio CHECK (precio_unitario_aplicado >= 0),
    CONSTRAINT fk_detalle_repuesto_orden
      FOREIGN KEY (id_orden) REFERENCES orden_reparacion (id_orden)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalle_repuesto_catalogo
      FOREIGN KEY (id_repuesto) REFERENCES repuesto (id_repuesto)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE participacion_mecanico (
    id_orden INT NOT NULL,
    id_mecanico INT NOT NULL,
    trabajo_realizado VARCHAR(255) NOT NULL,
    horas_trabajadas DECIMAL(6,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (id_orden, id_mecanico),
    CONSTRAINT chk_participacion_horas CHECK (horas_trabajadas >= 0),
    CONSTRAINT fk_participacion_orden
      FOREIGN KEY (id_orden) REFERENCES orden_reparacion (id_orden)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_participacion_mecanico
      FOREIGN KEY (id_mecanico) REFERENCES mecanico (id_mecanico)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Índices adicionales para filtrar por fecha/estado y agrupar detalles por catálogo.
CREATE INDEX idx_orden_fecha_recepcion
  ON orden_reparacion (fecha_recepcion);
CREATE INDEX idx_orden_estado_fecha
  ON orden_reparacion (estado, fecha_recepcion);
CREATE INDEX idx_detalle_servicio_servicio_orden
  ON detalle_servicio (id_servicio, id_orden);
CREATE INDEX idx_detalle_repuesto_repuesto_orden
  ON detalle_repuesto (id_repuesto, id_orden);
CREATE INDEX idx_participacion_mecanico_orden
  ON participacion_mecanico (id_mecanico, id_orden);

-- Reglas de eliminación:
-- RESTRICT conserva clientes, vehículos, mecánicos y catálogos con historial.
-- CASCADE elimina detalles y participaciones si una orden se borra expresamente;
-- la aplicación no ofrece borrado de órdenes, para preservar el historial.
-- SET NULL no se usa porque las relaciones obligatorias requieren sus claves.
