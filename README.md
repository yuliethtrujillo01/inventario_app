
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

# Sistema de Inventario con Autenticación JWT

Aplicación móvil de gestión de inventario desarrollada con **Flutter** y **FastAPI**, que permite administrar productos mediante operaciones CRUD y cuenta con un sistema de autenticación basado en tokens JWT.

## Tecnologías utilizadas

### Backend
- Python 3.11
- FastAPI
- SQLAlchemy
- SQLite
- PyJWT
- Argon2 para el hash de contraseñas

### Frontend
- Flutter
- Dart
- Dio para las solicitudes HTTP
- GoRouter para la navegación
- Flutter Secure Storage para el almacenamiento seguro de tokens
- Flutter Dotenv para la configuración de variables de entorno

## Funcionalidades principales

### Autenticación y seguridad
- Inicio de sesión mediante correo electrónico y contraseña.
- Generación de tokens JWT (Access Token y Refresh Token).
- Almacenamiento seguro de los tokens en el dispositivo.
- Protección de los endpoints de productos.
- Validación de usuarios autenticados.
- Renovación automática de tokens cuando expira el Access Token.
- Persistencia de sesión al cerrar y volver a abrir la aplicación.
- Cierre de sesión y eliminación de tokens almacenados.
- Contraseñas protegidas mediante hash Argon2.

### Gestión de productos
- Consultar productos.
- Registrar nuevos productos.
- Actualizar productos.
- Eliminar productos.

## Estructura del proyecto

```text
inventario_app/
│
├── backend/
│   ├── main.py
│   ├── models.py
│   ├── database.py
│   ├── security.py
│   ├── auth_routes.py
│   ├── auth_schemas.py
│   ├── crear_usuario.py
│   ├── requirements.txt
│   └── .env.example
│
└── frontend/
    ├── lib/
    │   ├── main.dart
    │   ├── screens/
    │   │   ├── login_screen.dart
    │   │   └── dashboard_screen.dart
    │   └── services/
    │       ├── api_service.dart
    │       ├── auth_service.dart
    │       ├── secure_storage_service.dart
    │       └── producto_service.dart
    ├── .env.example
    └── pubspec.yaml
```

## Requisitos previos

Antes de ejecutar el proyecto se debe contar con:

- Python 3.11 o superior.
- Flutter y Dart instalados.
- Android Studio o un dispositivo Android.
- Git.
- Visual Studio Code (opcional).

## Instalación y ejecución del Backend

1. Ingresar a la carpeta del backend:

```bash
cd backend
```

2. Crear un entorno virtual:

```bash
python -m venv venv
```

3. Activar el entorno virtual en Windows PowerShell:

```powershell
.\venv\Scripts\Activate.ps1
```

4. Instalar las dependencias:

```bash
pip install -r requirements.txt
```

5. Configurar las variables de entorno creando un archivo `.env` a partir de `.env.example`.

Configurar los siguientes valores:

```env
JWT_SECRET_KEY=TU_CLAVE_SECRETA_SEGURA
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
```

**Importante:** reemplazar `TU_CLAVE_SECRETA_SEGURA` por una clave privada y no publicar el archivo `.env`.

6. Ejecutar el servidor:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

7. Consultar la documentación interactiva de la API:

```text
http://127.0.0.1:8000/docs
```

## Instalación y ejecución del Frontend

1. Abrir una nueva terminal e ingresar a la carpeta del frontend:

```bash
cd frontend
```

2. Instalar las dependencias:

```bash
flutter pub get
```

3. Crear el archivo `.env` tomando como referencia `.env.example`.

Para ejecutar en un emulador Android:

```env
API_URL=http://10.0.2.2:8000
```

Para ejecutar en un navegador o entorno local:

```env
API_URL=http://127.0.0.1:8000
```

4. Verificar los dispositivos disponibles:

```bash
flutter devices
```

5. Ejecutar la aplicación:

```bash
flutter run
```

## Endpoints de autenticación

| Método | Endpoint | Descripción |
|---|---|---|
| POST | `/api/auth/login` | Iniciar sesión |
| POST | `/api/auth/refresh` | Renovar los tokens |
| GET | `/api/auth/me` | Consultar usuario autenticado |

## Endpoints de productos

Los endpoints CRUD requieren autenticación mediante un token JWT válido.

| Método | Endpoint | Descripción |
|---|---|---|
| GET | `/api/productos` | Consultar productos |
| POST | `/api/productos` | Registrar producto |
| PUT | `/api/productos/{id}` | Actualizar producto |
| DELETE | `/api/productos/{id}` | Eliminar producto |

## Pruebas realizadas

Se realizaron pruebas funcionales para verificar:

- Inicio de sesión y generación de tokens.
- Acceso no autorizado a endpoints protegidos.
- Consulta de productos con autenticación.
- Registro, actualización y eliminación de productos.
- Persistencia de sesión después de cerrar la aplicación.
- Cierre de sesión y eliminación de credenciales almacenadas.
- Renovación automática del Access Token mediante el Refresh Token.

## Seguridad

- Las contraseñas no se almacenan en texto plano.
- Se utiliza Argon2 para proteger las contraseñas.
- Los tokens se almacenan mediante Flutter Secure Storage.
- Los endpoints de gestión de productos requieren autenticación.
- Las claves y configuraciones privadas se mantienen en archivos `.env`, excluidos del repositorio.


## Autor

Yulieth Yahaira Trujillo Rivera - 230232015
yulieth.trujillo02@uecva.edu.co
