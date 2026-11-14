
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from fastapi.middleware.cors import CORSMiddleware

from database import engine, Base, get_db
from models import Producto, Usuario
from auth_routes import router as auth_router, get_current_user
from schemas import ProductoCrear, ProductoRespuesta


app = FastAPI(
    title="API de Gestión de Inventario",
    description="Sistema de inventario con FastAPI, SQLite y autenticación JWT",
    version="1.0.0"
)

app.include_router(auth_router)
Base.metadata.create_all(bind=engine)


@app.get("/")
def inicio():
    return {
        "mensaje": "Bienvenido a la API de Inventario",
        "estado": "Funcionando correctamente"
    }


# 1. LISTAR PRODUCTOS
@app.get("/api/productos", response_model=list[ProductoRespuesta])
def listar_productos(
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(get_current_user)
):
    return db.query(Producto).all()


# 2. CONSULTAR PRODUCTO POR ID
@app.get(
    "/api/productos/{producto_id}",
    response_model=ProductoRespuesta
)
def obtener_producto(
    producto_id: int,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(get_current_user)
):
    producto = db.get(Producto, producto_id)

    if producto is None:
        raise HTTPException(
            status_code=404,
            detail="Producto no encontrado"
        )

    return producto


# 3. REGISTRAR PRODUCTO
@app.post(
    "/api/productos",
    response_model=ProductoRespuesta,
    status_code=status.HTTP_201_CREATED
)
def crear_producto(
    datos: ProductoCrear,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(get_current_user)
):
    nuevo_producto = Producto(**datos.model_dump())

    db.add(nuevo_producto)

    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=422,
            detail="El código del producto ya existe"
        )

    db.refresh(nuevo_producto)
    return nuevo_producto


# 4. ACTUALIZAR PRODUCTO
@app.put(
    "/api/productos/{producto_id}",
    response_model=ProductoRespuesta
)
def actualizar_producto(
    producto_id: int,
    datos: ProductoCrear,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(get_current_user)
):
    producto = db.get(Producto, producto_id)

    if producto is None:
        raise HTTPException(
            status_code=404,
            detail="Producto no encontrado"
        )

    for campo, valor in datos.model_dump().items():
        setattr(producto, campo, valor)

    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=422,
            detail="El código del producto ya existe"
        )

    db.refresh(producto)
    return producto


# 5. ELIMINAR PRODUCTO
@app.delete("/api/productos/{producto_id}")
def eliminar_producto(
    producto_id: int,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(get_current_user)
):
    producto = db.get(Producto, producto_id)

    if producto is None:
        raise HTTPException(
            status_code=404,
            detail="Producto no encontrado"
        )

    db.delete(producto)
    db.commit()

    return {"mensaje": "Producto eliminado correctamente"}


# CONFIGURACIÓN CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)
