
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from database import get_db
from models import Usuario
from auth_schemas import (
    LoginRequest,
    UsuarioRespuesta,
    TokenRespuesta,
    RefreshRequest
)
from security import (
    verify_password,
    create_access_token,
    create_refresh_token,
    decode_token,
    ACCESS_TOKEN_EXPIRE_MINUTES
)


router = APIRouter(prefix="/api/auth", tags=["Autenticación"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")


# Obtener y validar el usuario a partir del token
def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
):
    credenciales_invalidas = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token inválido, vencido o no autorizado",
        headers={"WWW-Authenticate": "Bearer"}
    )

    payload = decode_token(token)

    if payload is None or payload.get("type") != "access":
        raise credenciales_invalidas

    try:
        user_id = int(payload.get("sub"))
    except (TypeError, ValueError):
        raise credenciales_invalidas

    usuario = db.get(Usuario, user_id)

    if usuario is None or not usuario.activo:
        raise credenciales_invalidas

    return usuario


# 1. INICIAR SESIÓN
@router.post("/login", response_model=TokenRespuesta)
def login(
    datos: LoginRequest,
    db: Session = Depends(get_db)
):
    usuario = db.query(Usuario).filter(
        Usuario.correo == datos.correo
    ).first()

    if (
        usuario is None
        or not usuario.activo
        or not verify_password(datos.password, usuario.password_hash)
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Correo o contraseña incorrectos",
            headers={"WWW-Authenticate": "Bearer"}
        )

    return {
        "access_token": create_access_token(usuario.id),
        "refresh_token": create_refresh_token(usuario.id),
        "token_type": "bearer",
        "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        "usuario": usuario
    }


# 2. RENOVAR TOKENS
@router.post("/refresh", response_model=TokenRespuesta)
def refresh_tokens(
    datos: RefreshRequest,
    db: Session = Depends(get_db)
):
    payload = decode_token(datos.refresh_token)

    if payload is None or payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de renovación inválido o vencido"
        )

    try:
        user_id = int(payload.get("sub"))
    except (TypeError, ValueError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de renovación inválido"
        )

    usuario = db.get(Usuario, user_id)

    if usuario is None or not usuario.activo:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario no autorizado"
        )

    return {
        "access_token": create_access_token(usuario.id),
        "refresh_token": create_refresh_token(usuario.id),
        "token_type": "bearer",
        "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        "usuario": usuario
    }


# 3. CONSULTAR USUARIO AUTENTICADO
@router.get("/me", response_model=UsuarioRespuesta)
def obtener_usuario_actual(
    usuario: Usuario = Depends(get_current_user)
):
    return usuario
