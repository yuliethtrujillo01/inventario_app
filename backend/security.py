
import os
from datetime import datetime, timedelta, timezone

import jwt
from dotenv import load_dotenv
from pwdlib import PasswordHash
from jwt.exceptions import InvalidTokenError


# Cargar las variables del archivo .env
load_dotenv()

# Configuración JWT
SECRET_KEY = os.getenv("JWT_SECRET_KEY")
ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")

ACCESS_TOKEN_EXPIRE_MINUTES = int(
    os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30")
)

REFRESH_TOKEN_EXPIRE_DAYS = int(
    os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", "7")
)

if not SECRET_KEY or SECRET_KEY == "REEMPLAZAR_POR_UNA_CLAVE_SECRETA":
    raise RuntimeError(
        "No se encontró una clave JWT_SECRET_KEY válida en el archivo .env"
    )


# Configuración para proteger contraseñas con Argon2
password_hasher = PasswordHash.recommended()


def hash_password(password: str) -> str:
    """Genera un hash seguro de una contraseña."""
    return password_hasher.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    """Comprueba una contraseña frente a su hash."""
    return password_hasher.verify(password, password_hash)


def create_access_token(user_id: int) -> str:
    """Genera un token de acceso JWT."""
    now = datetime.now(timezone.utc)

    payload = {
        "sub": str(user_id),
        "type": "access",
        "iat": now,
        "exp": now + timedelta(
            minutes=ACCESS_TOKEN_EXPIRE_MINUTES
        )
    }

    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def create_refresh_token(user_id: int) -> str:
    """Genera un token de renovación JWT."""
    now = datetime.now(timezone.utc)

    payload = {
        "sub": str(user_id),
        "type": "refresh",
        "iat": now,
        "exp": now + timedelta(
            days=REFRESH_TOKEN_EXPIRE_DAYS
        )
    }

    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def decode_token(token: str):
    """Valida y decodifica un token JWT."""
    try:
        return jwt.decode(
            token,
            SECRET_KEY,
            algorithms=[ALGORITHM]
        )
    except InvalidTokenError:
        return None
