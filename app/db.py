"""Configuración y conexión MySQL para el sistema local del taller."""

from __future__ import annotations

import os
from pathlib import Path

import mysql.connector


def _load_env_file() -> None:
    """Carga app/.env sin reemplazar variables ya definidas en el sistema."""
    env_path = Path(__file__).with_name(".env")
    if not env_path.exists():
        return
    for raw_line in env_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        name, value = line.split("=", 1)
        value = value.strip().strip('"').strip("'")
        os.environ.setdefault(name.strip(), value)


_load_env_file()


def connect_db():
    """Abre una conexión nueva con los datos del archivo .env o del entorno."""
    required = ["DB_HOST", "DB_NAME", "DB_USER"]
    missing = [name for name in required if not os.getenv(name)]
    if missing:
        raise RuntimeError(
            "Faltan variables de conexión: " + ", ".join(missing) + ". Configura app/.env."
        )
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "127.0.0.1"),
        port=int(os.getenv("DB_PORT", "3306")),
        database=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.getenv("DB_PASSWORD", ""),
        charset="utf8mb4",
        collation="utf8mb4_0900_ai_ci",
        autocommit=False,
    )
