"""Carga las siete consultas desde el SQL entregado para evitar duplicarlas."""

from pathlib import Path
import re


SQL_FILE = Path(__file__).resolve().parents[1] / "sql" / "03_consultas.sql"


def load_report_queries() -> dict[str, str]:
    text = SQL_FILE.read_text(encoding="utf-8")
    text = re.sub(r"(?m)^\s*--.*$", "", text)
    statements = [part.strip() for part in text.split(";") if part.strip()]
    queries = [stmt for stmt in statements if not stmt.upper().startswith("USE ")]
    if len(queries) != 7:
        raise RuntimeError(f"Se esperaban siete consultas en {SQL_FILE}, se encontraron {len(queries)}.")
    return {str(index): query for index, query in enumerate(queries, start=1)}


REPORT_QUERIES = load_report_queries()
REPORT_TITLES = {
    "1": "Resumen de órdenes de reparación",
    "2": "Historial de reparaciones por vehículo",
    "3": "Mecánicos con mayor participación",
    "4": "Servicios más solicitados",
    "5": "Consumo de repuestos",
    "6": "Ingresos por cliente y tipo de servicio",
    "7": "Clientes con gastos superiores al promedio",
}
