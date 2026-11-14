
from pydantic import BaseModel, Field


class LoginRequest(BaseModel):
    correo: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=1, max_length=128)


class UsuarioRespuesta(BaseModel):
    id: int
    nombre: str
    correo: str


class TokenRespuesta(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
    usuario: UsuarioRespuesta


class RefreshRequest(BaseModel):
    refresh_token: str
