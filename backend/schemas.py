
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional
from decimal import Decimal


class ProductoBase(BaseModel):
    nombre: str = Field(min_length=1)
    codigo: str = Field(min_length=1)
    descripcion: Optional[str] = None
    precio: Decimal = Field(ge=0, decimal_places=2)
    cantidad: int = Field(ge=0)
    categoria: str = Field(min_length=1)


class ProductoCrear(ProductoBase):
    pass


class ProductoRespuesta(ProductoBase):
    id: int

    model_config = ConfigDict(from_attributes=True)
