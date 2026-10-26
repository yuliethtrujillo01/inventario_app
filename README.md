
# InventarioApp

## Sistema de Gestión de Inventario

Proyecto desarrollado para el Segundo Parcial Práctico de
Electiva Profesional I — Desarrollo de Aplicaciones Móviles.

## Descripción

InventarioApp es un sistema de gestión de inventario
compuesto por una API REST desarrollada con FastAPI
y una aplicación Flutter.

Permite registrar, consultar, actualizar y eliminar productos,
manteniendo la información en una base de datos SQLite.

## Tecnologías utilizadas

### Backend
- Python 3.11
- FastAPI
- SQLAlchemy
- SQLite
- Uvicorn

### Frontend
- Flutter
- Dart
- Dio
- go_router
- flutter_dotenv
- intl

## Estructura del proyecto

inventario_app/
- backend/
  - main.py
  - database.py
  - models.py
  - schemas.py
  - seed.py
  - requirements.txt
- frontend/
  - lib/
  - android/
  - pubspec.yaml
  - .env.example

## Instalación del backend

1. Ingresar a la carpeta backend:

   cd backend

2. Crear el entorno virtual:

   python -m venv venv

3. Activar el entorno virtual en Windows:

   .\venv\Scripts\Activate.ps1

4. Instalar las dependencias:

   python -m pip install -r requirements.txt

5. Registrar los productos iniciales:

   python seed.py

6. Ejecutar la API:

   python -m uvicorn main:app --reload

La API estará disponible en:

http://127.0.0.1:8000

Documentación Swagger:

http://127.0.0.1:8000/docs

## Endpoints de la API

| Método | Endpoint | Descripción |
|---|---|---|
| GET | /api/productos | Listar productos |
| GET | /api/productos/{id} | Consultar producto |
| POST | /api/productos | Registrar producto |
| PUT | /api/productos/{id} | Actualizar producto |
| DELETE | /api/productos/{id} | Eliminar producto |

## Ejemplo de petición POST

{
  "nombre": "Arroz Diana 500g",
  "codigo": "PROD001",
  "descripcion": "Arroz blanco de 500 gramos",
  "precio": 4200,
  "cantidad": 35,
  "categoria": "Granos"
}

En una base de datos nueva, una petición POST exitosa
retorna HTTP 201 e incluye el ID autogenerado.

## Instalación del frontend

1. Ingresar a frontend:

   cd frontend

2. Instalar dependencias:

   flutter pub get

3. Copiar .env.example a .env.

4. Configurar API_URL según el dispositivo.

Para Chrome en el mismo computador:

API_URL=http://127.0.0.1:8000

Para el emulador Android:

API_URL=http://10.0.2.2:8000

5. Ejecutar la aplicación:

   flutter run -d chrome

Para Android, seleccionar un emulador disponible.

## Funcionalidades

- Dashboard con indicadores del inventario.
- Listado y búsqueda de productos.
- Consulta individual por ID.
- Registro de productos.
- Edición de productos.
- Eliminación con confirmación.
- Validación de formularios.
- Manejo de errores de conexión.
- Navegación mediante go_router.
- Persistencia de datos con SQLite.
- Formato de precios en pesos colombianos.

## Persistencia

Los productos se almacenan en SQLite y permanecen
registrados después de cerrar o reiniciar el servidor.

El archivo local de base de datos no se incluye en GitHub.
Se proporciona seed.py para inicializar los datos de prueba.

## Autor

Yulieth Yahaira Trujillo Rivera - 230232015
yulieth.trujillo02@uecva.edu.co
