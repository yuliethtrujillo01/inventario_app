
from getpass import getpass

from database import engine, Base, SessionLocal
from models import Producto, Usuario
from security import hash_password


# Crear las tablas si todavía no existen
Base.metadata.create_all(bind=engine)


def crear_usuario():
    db = SessionLocal()

    try:
        print("\n=== REGISTRO DE USUARIO DE PRUEBA ===")

        nombre = input("Nombre completo: ").strip()
        correo = input("Correo electrónico: ").strip().lower()

        if not nombre or not correo:
            print("El nombre y el correo son obligatorios.")
            return

        usuario_existente = db.query(Usuario).filter(
            Usuario.correo == correo
        ).first()

        if usuario_existente:
            print("Ya existe un usuario registrado con ese correo.")
            return

        password = getpass("Crear contraseña: ")
        confirmar = getpass("Confirmar contraseña: ")

        if len(password) < 8:
            print("La contraseña debe tener al menos 8 caracteres.")
            return

        if password != confirmar:
            print("Las contraseñas no coinciden.")
            return

        nuevo_usuario = Usuario(
            nombre=nombre,
            correo=correo,
            password_hash=hash_password(password),
            activo=True
        )

        db.add(nuevo_usuario)
        db.commit()
        db.refresh(nuevo_usuario)

        print("\n¡Usuario creado correctamente!")
        print("ID:", nuevo_usuario.id)
        print("Nombre:", nuevo_usuario.nombre)
        print("Correo:", nuevo_usuario.correo)
        print("Contraseña: almacenada de forma segura.")

    except Exception as error:
        db.rollback()
        print("No fue posible crear el usuario:", error)

    finally:
        db.close()


if __name__ == "__main__":
    crear_usuario()
