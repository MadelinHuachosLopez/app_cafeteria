# MI CAFETERIA APP — Documentación técnica

## 1. Análisis general del proyecto

**MI CAFETERIA APP** es una aplicación móvil desarrollada con **Flutter** que combina dos capas de persistencia:

| Capa | Tecnología | Propósito |
|------|------------|-----------|
| Autenticación | **SQLite** (`sqflite`) | Registro e inicio de sesión de usuarios locales |
| Gestión de productos | **Firebase Firestore** | CRUD de productos en la nube en tiempo real |

### Flujo de la aplicación

```
Inicio → ¿Hay sesión guardada?
           ├─ Sí  → Pantalla de Bienvenida (muestra correo)
           └─ No  → Pantalla de Login
                      ├─ REGISTRARSE → Formulario (6 campos) → SQLite → vuelve al Login
                      └─ Iniciar sesión → validación → Bienvenida → Ir a la Cafetería
```

### Pantallas implementadas

| Pantalla | Archivo | Descripción |
|----------|---------|-------------|
| Login | `lib/screens/login_screen.dart` | Correo, contraseña, botón de acceso, enlace REGISTRARSE, nombre del desarrollador |
| Registro | `lib/screens/register_screen.dart` | 6 campos: nombre, email, teléfono, contraseña, spinner (tipo usuario), checkbox (términos) |
| Bienvenida | `lib/screens/welcome_screen.dart` | Muestra nombre y correo del usuario autenticado |
| Cafetería | `lib/screens/pantalla_cafeteria.dart` | Listado y CRUD de productos con Firestore |

### Cumplimiento de criterios de evaluación

- **Interfaz de usuario:** formularios con iconos, colores consistentes (naranja/café), mensajes de error mediante `SnackBar` y validaciones en formularios.
- **Login:** autenticación contra SQLite, mensajes de éxito/error, redirección a bienvenida con correo visible.
- **Registro:** almacenamiento en SQLite, redirección automática al login tras registro exitoso.
- **Validaciones:** formato de email, contraseña mínima de 6 caracteres, campos obligatorios, teléfono numérico, términos aceptados.
- **Sesión persistente:** `SharedPreferences` guarda el correo y nombre del usuario entre aperturas de la app.

---

## 2. Estructura del proyecto

```
lib/
├── main.dart                    # Punto de entrada e inicio con verificación de sesión
├── database/
│   └── database_helper.dart     # Operaciones SQLite (CRUD usuarios)
├── services/
│   └── session_service.dart     # Persistencia de sesión con SharedPreferences
├── utils/
│   └── validators.dart          # Validaciones reutilizables
└── screens/
    ├── login_screen.dart
    ├── register_screen.dart
    ├── welcome_screen.dart
    └── pantalla_cafeteria.dart
```

---

## 3. Sustentación de algoritmos utilizados

### 3.1 Algoritmo de validación de correo electrónico

**Ubicación:** `lib/utils/validators.dart`

**Descripción:** Se utiliza una **expresión regular (RegExp)** para verificar que el texto ingresado cumpla con la estructura estándar de un correo: `usuario@dominio.ext`.

```
Patrón: ^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$
```

**Justificación:** Las expresiones regulares permiten validar formatos de texto de forma declarativa y eficiente. Este patrón cubre la mayoría de correos válidos en contexto académico y evita registros con datos incorrectos antes de consultar la base de datos.

**Complejidad temporal:** O(n), donde n es la longitud del correo, ya que el motor de RegExp recorre la cadena una vez.

---

### 3.2 Algoritmo de validación de contraseña

**Ubicación:** `lib/utils/validators.dart`

**Descripción:** Verificación secuencial en dos pasos:

1. Comprobar que la contraseña no esté vacía.
2. Comprobar que su longitud sea **≥ 6 caracteres**.

**Justificación:** Cumple el requisito del enunciado (mínimo 6 caracteres). La validación se ejecuta en el cliente antes de cualquier operación de base de datos, reduciendo operaciones innecesarias de I/O.

**Complejidad temporal:** O(1) — solo se evalúa la longitud de la cadena.

---

### 3.3 Algoritmo de autenticación (Login)

**Ubicación:** `lib/database/database_helper.dart` → `validarCredenciales()`

**Descripción:** Algoritmo de **búsqueda y comparación**:

```
ENTRADA: email, password
1. Normalizar email (trim + minúsculas)
2. Ejecutar consulta SQL: SELECT * FROM usuarios WHERE email = ?
3. SI no hay resultados → retornar null (credenciales inválidas)
4. SI password almacenada ≠ password ingresada → retornar null
5. SI coinciden → retornar registro del usuario
SALIDA: usuario autenticado o null
```

**Justificación:** Es un algoritmo de autenticación por **comparación directa** contra un registro único identificado por email (campo `UNIQUE` en SQLite). La consulta parametrizada (`whereArgs`) previene inyección SQL.

**Complejidad temporal:** O(1) en promedio gracias al índice implícito sobre la clave primaria y la restricción UNIQUE sobre email.

---

### 3.4 Algoritmo de registro de usuario

**Ubicación:** `lib/database/database_helper.dart` → `registrarUsuario()`

**Descripción:** Operación **INSERT** con restricción de unicidad:

```
ENTRADA: datos del formulario (6 campos)
1. Validar todos los campos en el formulario (FormState.validate)
2. Validar checkbox de términos y spinner seleccionado
3. INSERT INTO usuarios (...) VALUES (...)
4. SI email duplicado → capturar DatabaseException → mensaje de error
5. SI éxito → navegar al Login
```

**Justificación:** SQLite garantiza integridad referencial con `UNIQUE` en el campo email, evitando duplicados sin necesidad de una consulta previa explícita (patrón *optimistic insert*). Si el INSERT falla por restricción UNIQUE, se informa al usuario.

**Complejidad temporal:** O(1) para el INSERT; O(1) para detectar duplicado vía excepción.

---

### 3.5 Algoritmo de persistencia de sesión

**Ubicación:** `lib/services/session_service.dart`

**Descripción:** Algoritmo de **almacenamiento clave-valor** persistente:

```
Al iniciar sesión:
  guardar("usuario_email", email)
  guardar("usuario_nombre", nombre)

Al abrir la app:
  SI existe("usuario_email") → redirigir a Bienvenida
  SINO → redirigir a Login

Al cerrar sesión:
  eliminar("usuario_email")
  eliminar("usuario_nombre")
```

**Justificación:** `SharedPreferences` es un mecanismo ligero de persistencia local ideal para guardar tokens o datos de sesión simples. No requiere base de datos relacional y persiste entre reinicios de la aplicación.

**Complejidad temporal:** O(1) para lectura/escritura de cada clave.

---

### 3.6 Algoritmo de resolución de pantalla inicial

**Ubicación:** `lib/main.dart` → `PantallaInicio._resolverPantallaInicial()`

**Descripción:** Patrón **FutureBuilder** con decisión condicional:

```
FUTURO resolverPantallaInicial():
  sesion = await haySesionActiva()
  SI sesion:
    email, nombre = await obtenerDatosSesion()
    SI datos válidos → return WelcomeScreen
  return LoginScreen
```

**Justificación:** Evita parpadeos de navegación incorrecta al esperar la lectura asíncrona de SharedPreferences antes de renderizar la pantalla definitiva. Mientras el Future está en progreso, se muestra un indicador de carga.

**Complejidad temporal:** O(1) — dos lecturas de preferencias como máximo.

---

### 3.7 Algoritmo de sincronización en tiempo real (Firestore)

**Ubicación:** `lib/screens/pantalla_cafeteria.dart`

**Descripción:** Patrón **Observer / Stream** con `StreamBuilder`:

```
1. Suscribirse al stream: collection('productos').snapshots()
2. Cada cambio en Firestore emite un nuevo QuerySnapshot
3. StreamBuilder reconstruye la ListView automáticamente
4. Operaciones CRUD (add/update/delete) modifican Firestore → el stream notifica → UI se actualiza
```

**Justificación:** El patrón reactivo elimina la necesidad de recargar manualmente la lista tras cada operación. Firestore actúa como fuente de verdad y el cliente solo observa cambios.

**Complejidad temporal:** O(m) por reconstrucción de lista, donde m es el número de productos.

---

## 4. Base de datos SQLite — Esquema

```sql
CREATE TABLE usuarios (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre_completo TEXT NOT NULL,
  email           TEXT NOT NULL UNIQUE,
  telefono        TEXT NOT NULL,
  password        TEXT NOT NULL,
  tipo_usuario    TEXT NOT NULL
);
```

**Archivo físico:** `cafeteria_usuarios.db` en el directorio de bases de datos del dispositivo.

---

## 5. Consideraciones de seguridad

> **Nota académica:** Las contraseñas se almacenan en texto plano para simplificar la demostración del flujo CRUD con SQLite. En un entorno de producción se debe aplicar un algoritmo de hash unidireccional como **bcrypt** o **Argon2** antes de persistir las credenciales.

---

## 6. Ejecución y entrega

### Ejecutar en dispositivo

```bash
flutter pub get
flutter run
```

### Generar APK

```bash
flutter build apk --release
```

El archivo APK se genera en: `build/app/outputs/flutter-apk/app-release.apk`

---

## 7. Desarrollador

**Madelin Huachos López**

Repositorio: [github.com/MadelinHuachosLopez/app_cafeteria](https://github.com/MadelinHuachosLopez/app_cafeteria)
