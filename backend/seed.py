
from decimal import Decimal

from database import Base, engine, SessionLocal
from models import Producto

Base.metadata.create_all(bind=engine)

productos = [
    ("Arroz Diana 500g", "PROD001", "Granos", 4200, 35),
    ("Aceite Girasol 1L", "PROD002", "Aceites", 12500, 15),
    ("Azúcar Blanca 1kg", "PROD003", "Granos", 4800, 30),
    ("Leche Entera 1L", "PROD004", "Lácteos", 4200, 25),
    ("Café Molido 250g", "PROD005", "Bebidas", 11000, 18),
    ("Pasta Espagueti 500g", "PROD006", "Pastas", 3900, 40),
    ("Sal 1kg", "PROD007", "Condimentos", 2200, 35),
    ("Galletas 300g", "PROD008", "Snacks", 5500, 22),
    ("Chocolate de Mesa 500g", "PROD009", "Bebidas", 9500, 12),
    ("Harina de Trigo 1kg", "PROD010", "Harinas", 4500, 28),
]

db = SessionLocal()

try:
    agregados = 0

    for nombre, codigo, categoria, precio, cantidad in productos:
        existente = db.query(Producto).filter(
            Producto.codigo == codigo
        ).first()

        if existente is None:
            producto = Producto(
                nombre=nombre,
                codigo=codigo,
                descripcion=f"Producto de categoría {categoria}",
                precio=Decimal(str(precio)),
                cantidad=cantidad,
                categoria=categoria,
            )

            db.add(producto)
            agregados += 1

    db.commit()

    print(f"Productos nuevos registrados: {agregados}")
    print("Inicialización finalizada correctamente.")

except Exception:
    db.rollback()
    raise

finally:
    db.close()
