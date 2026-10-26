
from sqlalchemy import Column, Integer, String, Numeric
from database import Base


class Producto(Base):
    __tablename__ = "productos"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    codigo = Column(String, unique=True, nullable=False)
    descripcion = Column(String, nullable=True)
    precio = Column(Numeric(12, 2), nullable=False)
    cantidad = Column(Integer, nullable=False)
    categoria = Column(String, nullable=False)
