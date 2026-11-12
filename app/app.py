"""Aplicación web local para administrar órdenes del taller."""

from __future__ import annotations

from datetime import datetime
from decimal import Decimal, InvalidOperation
import os

import mysql.connector
from flask import Flask, flash, redirect, render_template, request, url_for

from db import connect_db
from report_queries import REPORT_QUERIES, REPORT_TITLES


app = Flask(__name__)
app.secret_key = os.getenv("FLASK_SECRET_KEY", "clave-local-de-demostracion")
app.config.update(SESSION_COOKIE_HTTPONLY=True, SESSION_COOKIE_SAMESITE="Lax")

ORDER_STATES = ("Abierta", "En_Proceso", "Finalizada", "Entregada", "Cancelada")


def fetch_all(sql: str, params=()):
    connection = connect_db()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute(sql, params)
        return cursor.fetchall()
    finally:
        try:
            cursor.close()
        except UnboundLocalError:
            pass
        connection.close()


def load_order_options():
    vehicles = fetch_all(
        "SELECT v.id_vehiculo, v.placa, v.marca, v.modelo, c.nombres, c.apellidos "
        "FROM vehiculo v JOIN cliente c ON c.id_cliente=v.id_cliente ORDER BY v.placa"
    )
    mechanics = fetch_all(
        "SELECT id_mecanico, nombres, apellidos FROM mecanico WHERE activo=1 ORDER BY apellidos, nombres"
    )
    services = fetch_all(
        "SELECT id_servicio, nombre, precio_referencia FROM servicio WHERE activo=1 ORDER BY nombre"
    )
    parts = fetch_all(
        "SELECT id_repuesto, nombre, precio_actual, existencia FROM repuesto "
        "WHERE activo=1 ORDER BY nombre"
    )
    return vehicles, mechanics, services, parts


def parse_positive_decimal(value: str, label: str, allow_zero: bool = False) -> Decimal:
    try:
        result = Decimal(value)
    except (InvalidOperation, TypeError):
        raise ValueError(f"{label}: escribe una cantidad numerica válida")
    if not result.is_finite() or result < 0 or (result == 0 and not allow_zero):
        rule = "no puede ser negativa" if allow_zero else "debe ser mayor que cero"
        raise ValueError(f"{label} {rule}.")
    return result


@app.get("/")
def inicio():
    try:
        metrics = fetch_all(
            "SELECT (SELECT COUNT(*) FROM cliente) AS clientes, "
            "(SELECT COUNT(*) FROM vehiculo) AS vehiculos, "
            "(SELECT COUNT(*) FROM orden_reparacion) AS ordenes, "
            "(SELECT COUNT(*) FROM orden_reparacion WHERE estado IN ('Abierta','En_Proceso')) AS pendientes"
        )[0]
        recent = fetch_all(
            "SELECT o.id_orden, o.fecha_recepcion, o.estado, v.placa, "
            "CONCAT(c.nombres, ' ', c.apellidos) AS cliente "
            "FROM orden_reparacion o JOIN vehiculo v ON v.id_vehiculo=o.id_vehiculo "
            "JOIN cliente c ON c.id_cliente=v.id_cliente "
            "ORDER BY o.fecha_recepcion DESC LIMIT 8"
        )
        return render_template("inicio.html", metrics=metrics, recent=recent)
    except (mysql.connector.Error, RuntimeError) as error:
        return render_template("error_db.html", message=str(error)), 503


@app.route("/clientes", methods=["GET", "POST"])
def clientes():
    if request.method == "POST":
        connection = None
        cursor = None
        try:
            connection = connect_db()
            cursor = connection.cursor()
            action = request.form.get("action")
            if action == "nuevo_cliente":
                nombres = request.form.get("nombres", "").strip()
                apellidos = request.form.get("apellidos", "").strip()
                if not nombres or not apellidos:
                    raise ValueError("Nombres y apellidos son obligatorios.")
                cursor.execute(
                    "INSERT INTO cliente (nombres, apellidos, telefono, correo) VALUES (%s,%s,%s,%s)",
                    (nombres, apellidos, request.form.get("telefono") or None, request.form.get("correo") or None),
                )
                client_id = cursor.lastrowid
                plate = request.form.get("placa", "").strip().upper()
                if plate:
                    brand = request.form.get("marca", "").strip()
                    model = request.form.get("modelo", "").strip()
                    if not brand or not model:
                        raise ValueError("Para registrar un vehículo inicial, indica marca y modelo.")
                    year_value = request.form.get("anio", "").strip()
                    cursor.execute(
                        "INSERT INTO vehiculo (id_cliente, placa, marca, modelo, anio, color) "
                        "VALUES (%s,%s,%s,%s,%s,%s)",
                        (client_id, plate, brand, model, int(year_value) if year_value else None,
                         request.form.get("color") or None),
                    )
                connection.commit()
                flash("Cliente registrado.", "success")
            elif action == "nuevo_vehiculo":
                client_id = int(request.form.get("id_cliente", "0"))
                plate = request.form.get("placa", "").strip().upper()
                brand = request.form.get("marca", "").strip()
                model = request.form.get("modelo", "").strip()
                if not all((client_id, plate, brand, model)):
                    raise ValueError("Propietario, placa, marca y modelo son obligatorios")
                year_value = request.form.get("anio", "").strip()
                cursor.execute(
                    "INSERT INTO vehiculo (id_cliente, placa, marca, modelo, anio, color) "
                    "VALUES (%s,%s,%s,%s,%s,%s)",
                    (client_id, plate, brand, model, int(year_value) if year_value else None,
                     request.form.get("color") or None),
                )
                connection.commit()
                flash("Vehículo registrado.", "success")
            else:
                raise ValueError("No se reconoció la acción del formulario")
        except (ValueError, mysql.connector.Error, RuntimeError) as error:
            if connection:
                connection.rollback()
            flash(str(error), "error")
        finally:
            if cursor:
                cursor.close()
            if connection:
                connection.close()
        return redirect(url_for("clientes"))

    try:
        client_rows = fetch_all(
            "SELECT c.id_cliente, c.nombres, c.apellidos, c.telefono, c.correo, "
            "COUNT(v.id_vehiculo) AS cantidad_vehiculos "
            "FROM cliente c LEFT JOIN vehiculo v ON v.id_cliente=c.id_cliente "
            "GROUP BY c.id_cliente, c.nombres, c.apellidos, c.telefono, c.correo "
            "ORDER BY c.apellidos, c.nombres"
        )
        client_options = fetch_all("SELECT id_cliente, nombres, apellidos FROM cliente ORDER BY apellidos, nombres")
        return render_template("clientes.html", clients=client_rows, client_options=client_options)
    except (mysql.connector.Error, RuntimeError) as error:
        return render_template("error_db.html", message=str(error)), 503


@app.route("/ordenes/nueva", methods=["GET", "POST"])
def nueva_orden():
    if request.method == "GET":
        try:
            vehicles, mechanics, services, parts = load_order_options()
            return render_template(
                "orden_nueva.html", vehicles=vehicles, mechanics=mechanics,
                services=services, parts=parts, states=ORDER_STATES,
            )
        except (mysql.connector.Error, RuntimeError) as error:
            return render_template("error_db.html", message=str(error)), 503

    connection = None
    cursor = None
    try:
        vehicle_id = int(request.form.get("id_vehiculo", "0"))
        responsible_id = int(request.form.get("id_responsable", "0"))
        received_text = request.form.get("fecha_recepcion", "")
        received = datetime.fromisoformat(received_text)
        delivered_text = request.form.get("fecha_entrega", "")
        delivered = datetime.fromisoformat(delivered_text) if delivered_text else None
        problem = request.form.get("problema_reportado", "").strip()
        status = request.form.get("estado", "")
        if not vehicle_id or not responsible_id or not problem:
            raise ValueError("Selecciona el vehículo y el responsable, y escribe el problema reportado")
        if status not in ORDER_STATES:
            raise ValueError("El estado seleccionado no es válido")
        if delivered and delivered < received:
            raise ValueError("La fecha de entrega no puede ser anterior a la recepción")
        if status == "ENTREGADA" and not delivered:
            raise ValueError("Una orden entregada debe tener fecha de entrega")

        service_ids = request.form.getlist("service_id[]")
        service_quantities = request.form.getlist("service_quantity[]")
        service_notes = request.form.getlist("service_note[]")
        services_to_add = []
        for index, service_id in enumerate(service_ids):
            if not service_id:
                continue
            quantity = parse_positive_decimal(service_quantities[index], "Cantidad de servicio")
            services_to_add.append((int(service_id), quantity, service_notes[index].strip() or None))
        if not services_to_add:
            raise ValueError("Agrega por lo menos un servicio a esta orden")

        part_ids = request.form.getlist("part_id[]")
        part_quantities = request.form.getlist("part_quantity[]")
        parts_to_add = []
        for index, part_id in enumerate(part_ids):
            if not part_id:
                continue
            quantity = int(part_quantities[index])
            if quantity <= 0:
                raise ValueError("La cantidad de cada repuesto debe ser mayor que cero(>0)")
            parts_to_add.append((int(part_id), quantity))

        mechanic_ids = request.form.getlist("participant_id[]")
        mechanic_jobs = request.form.getlist("participant_job[]")
        mechanic_hours = request.form.getlist("participant_hours[]")
        participants = []
        seen_mechanics = set()
        for index, mechanic_id in enumerate(mechanic_ids):
            if not mechanic_id:
                continue
            mechanic_id = int(mechanic_id)
            if mechanic_id in seen_mechanics:
                raise ValueError("Cada mecánico puede aparecer una sola vez en la participación de una orden")
            seen_mechanics.add(mechanic_id)
            job = mechanic_jobs[index].strip()
            hours = parse_positive_decimal(mechanic_hours[index] or "0", "Horas", allow_zero=True)
            if not job:
                raise ValueError("Describe el trabajo realizado por cada mecánico participante")
            participants.append((mechanic_id, job, hours))

        connection = connect_db()
        cursor = connection.cursor(dictionary=True)
        cursor.execute(
            "INSERT INTO orden_reparacion "
            "(id_vehiculo,id_responsable,fecha_recepcion,fecha_entrega,problema_reportado,estado) "
            "VALUES (%s,%s,%s,%s,%s,%s)",
            (vehicle_id, responsible_id, received, delivered, problem, status),
        )
        order_id = cursor.lastrowid

        for service_id, quantity, note in services_to_add:
            cursor.execute(
                "SELECT precio_referencia FROM servicio WHERE id_servicio=%s AND activo=1 FOR UPDATE",
                (service_id,),
            )
            service = cursor.fetchone()
            if not service:
                raise ValueError("Uno de los servicios ya no está activo o no existe")
            cursor.execute(
                "INSERT INTO detalle_servicio "
                "(id_orden,id_servicio,cantidad,precio_unitario_aplicado,observaciones) "
                "VALUES (%s,%s,%s,%s,%s)",
                (order_id, service_id, quantity, service["precio_referencia"], note),
            )

        for part_id, quantity in parts_to_add:
            cursor.execute(
                "SELECT precio_actual, existencia FROM repuesto "
                "WHERE id_repuesto=%s AND activo=1 FOR UPDATE",
                (part_id,),
            )
            part = cursor.fetchone()
            if not part:
                raise ValueError("Uno de los repuestos ya no está activo o no existe")
            if quantity > part["existencia"]:
                raise ValueError(f"Existencia insuficiente para el repuesto {part_id}.")
            cursor.execute(
                "INSERT INTO detalle_repuesto "
                "(id_orden,id_repuesto,cantidad,precio_unitario_aplicado) VALUES (%s,%s,%s,%s)",
                (order_id, part_id, quantity, part["precio_actual"]),
            )
            cursor.execute(
                "UPDATE repuesto SET existencia=existencia-%s WHERE id_repuesto=%s",
                (quantity, part_id),
            )

        for mechanic_id, job, hours in participants:
            cursor.execute(
                "INSERT INTO participacion_mecanico "
                "(id_orden,id_mecanico,trabajo_realizado,horas_trabajadas) VALUES (%s,%s,%s,%s)",
                (order_id, mechanic_id, job, hours),
            )

        connection.commit()
        flash(f"Orden O{order_id:04d} registrada correctamente", "success")
        return redirect(url_for("consultas", consulta="1"))
    except (ValueError, mysql.connector.Error, RuntimeError) as error:
        if connection:
            connection.rollback()
        flash(str(error), "error")
        return redirect(url_for("nueva_orden"))
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


@app.route("/consultas", methods=["GET", "POST"])
def consultas():
    selected = request.values.get("consulta", "1")
    if selected not in REPORT_QUERIES:
        selected = "1"
    rows = []
    error = None
    try:
        rows = fetch_all(REPORT_QUERIES[selected])
    except (mysql.connector.Error, RuntimeError) as exception:
        error = str(exception)
    columns = list(rows[0].keys()) if rows else []
    return render_template(
        "consultas.html", reports=REPORT_TITLES, selected=selected,
        title=REPORT_TITLES[selected], rows=rows, columns=columns, error=error,
    )


@app.errorhandler(404)
def not_found(_error):
    return render_template("not_found.html"), 404


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=int(os.getenv("PORT", "5000")), debug=False)
#(#--#)