# Sistema de gestión de órdenes de reparación
# Documenta generado con IA(.md)
Aplicación académica para administrar clientes, vehículos y órdenes de un taller automotriz. Usa MySQL 8.0.16 o superior y Python 3.10 o superior con Flask.

## Contenido

- `docs/Documento_Analisis.md`: análisis del problema, alcance, reglas y decisiones de diseño.
- `outputs/01a1b26e-8a9d-7720-981f-eef222032cd7/Normalizacion_Proyecto_Final.xlsx`: normalización explicada en una sola hoja.
- `outputs/01a1b26e-8a9d-7720-981f-eef222032cd7/Diagrama_ER_Taller.png` y `.svg`: diagrama entidad-relación en pata de gallo.
- `sql/01_crear_bd_y_tablas.sql`: base de datos, tablas, restricciones e índices.
- `sql/02_insertar_datos.sql`: datos ficticios de demostración.
- `sql/03_consultas.sql`: siete consultas solicitadas.
- `app/`: aplicación web y sus plantillas.
- `docs/Guion_video_evidencias.md`: secuencia sugerida para grabar la demostración.

## 1. Crear la base de datos

1. Inicia MySQL Server y abre MySQL Workbench.
2. Abre `sql/01_crear_bd_y_tablas.sql` y ejecútalo completo con el botón del rayo. El script crea `taller_reparaciones`, sus nueve tablas, restricciones y cinco índices adicionales.
3. Abre `sql/02_insertar_datos.sql` y ejecútalo completo. Inserta los datos de prueba y puede volver a ejecutarse para actualizar esos registros.
4. Abre `sql/03_consultas.sql` y ejecuta cada bloque por separado para revisar sus resultados.

El esquema usa `CHECK` y la intercalación `utf8mb4_0900_ai_ci`, por lo que requiere MySQL 8.0.16 o superior.

## 2. Preparar las credenciales de la aplicación

1. Desde la carpeta raíz del proyecto, copia `app/.env.example` como `app/.env`.
2. En MySQL Workbench, usando tu conexión administrativa, crea una cuenta local exclusiva para la aplicación. Reemplaza `TU_CLAVE_LOCAL` antes de ejecutar:

   ```sql
   CREATE USER IF NOT EXISTS 'taller_app'@'127.0.0.1' IDENTIFIED BY 'TU_CLAVE_LOCAL';
   GRANT SELECT, INSERT, UPDATE ON taller_reparaciones.* TO 'taller_app'@'127.0.0.1';
   ```

3. Pon la misma clave elegida en `DB_PASSWORD` dentro de `app/.env`. No compartas ni entregues ese archivo. El usuario de la aplicación solo necesita consultar, insertar y actualizar registros.

## 3. Instalar y ejecutar

En Ubuntu o Debian, primero instala el paquete que permite crear entornos virtuales. En Ubuntu 24.04 con Python 3.12:

```bash
sudo apt update
sudo apt install python3.12-venv
```

En otras versiones, instala el paquete `python3-venv` correspondiente a la versión de Python del sistema. Después, desde la carpeta raíz del proyecto:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r app/requirements.txt
python app/app.py
```

Si `python3 -m venv .venv` falla y deja una carpeta `.venv` incompleta, instala primero el paquete anterior, elimina únicamente ese entorno incompleto con `rm -rf .venv` y vuelve a ejecutar los comandos. El comando `python` está disponible dentro del entorno virtual activado; si se ejecuta sin activar el entorno, usa `python3`.

Abre `http://127.0.0.1:5000` en el navegador. La aplicación escucha solo en la computadora local.

## 4. Usar la aplicación

1. En **Clientes y vehículos**, registra un cliente y, opcionalmente, su vehículo inicial. También puedes agregar otro vehículo a un cliente existente.
2. En **Nueva orden**, selecciona vehículo y mecánico responsable, registra recepción, problema y estado.
3. Agrega uno o varios servicios. El sistema guarda el precio de referencia vigente como precio aplicado de la orden.
4. Agrega los repuestos usados. El sistema valida existencias, guarda el precio vigente como valor histórico y descuenta la cantidad en la misma transacción.
5. Si participaron otros mecánicos, registra cada uno con el trabajo y horas dedicadas.
6. En **Consultas**, selecciona cualquiera de los siete reportes del enunciado.

## Decisiones de integridad

- `RESTRICT` protege clientes, vehículos, mecánicos y catálogos con historial.
- `CASCADE` se usa solo para detalles y participaciones dependientes de una orden borrada expresamente. La aplicación no incorpora una opción para borrar órdenes.
- `SET NULL` no se usa porque las referencias del modelo son obligatorias.
- Los precios históricos viven en los detalles; cambiar el precio de catálogo no modifica órdenes existentes.
- Si una orden no tiene existencia suficiente de un repuesto, toda la transacción se revierte.

## Solución de problemas

| Síntoma | Causa probable | Acción |
|---|---|---|
| No se puede acceder a MySQL | El servidor está detenido o el usuario/contraseña de `app/.env` no coincide. | Inicia MySQL Server y revisa `DB_HOST`, `DB_PORT`, `DB_USER` y `DB_PASSWORD`. |
| La base o una tabla no existe | No se ejecutó el script de creación en Workbench. | Ejecuta `01_crear_bd_y_tablas.sql` y después `02_insertar_datos.sql`. |
| La aplicación no inicia por un módulo faltante | No se instalaron las dependencias en el entorno virtual. | Activa `.venv` e instala `app/requirements.txt`. |
| No aparece un mecánico, servicio o repuesto en el formulario | El registro está inactivo o no se insertaron los datos iniciales. | Revisa la columna `activo` y ejecuta el script de datos. |
| No se registra una orden por inventario | La cantidad solicitada supera la existencia actual. | Ajusta la cantidad o actualiza el inventario desde MySQL Workbench. |

## Alcance de la demostración

El sistema está preparado para una demostración local académica. No incluye cuentas de usuario, publicación en internet, facturación fiscal ni registro de movimientos de inventario anteriores al uso de la aplicación. Las credenciales de MySQL y la grabación final deben configurarse en el equipo del estudiante.
