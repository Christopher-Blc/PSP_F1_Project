# F1 App (Flutter + Jolpi API)

## Funcionalidades
- Pantalla principal con 4 secciones:
  - Drivers
  - Teams
  - Circuits
  - Seasons
- Consumo de múltiples endpoints REST.
- Carga asíncrona de datos mediante `FutureBuilder` (no bloquea la UI).
- Conversión automática de JSON a entidades tipadas.
- Manejo de errores HTTP (4xx, 5xx), timeout y falta de conexión.
- Sistema de caché en memoria para evitar peticiones repetidas.
- Lista de drivers con avatar (Wikipedia) y pantalla de detalle de driver con imagen grande.
- Uso de `cached_network_image` para optimizar la carga y caché de imágenes.
- Control explícito del ciclo de vida de recursos (`AppBootstrap` + `dispose` en repositorio/cliente).

## APIs utilizadas
### 1️⃣ Jolpi API (datos principales)
Base URL:
- `https://api.jolpi.ca/ergast/f1`

Endpoints utilizados:
- `GET /current/drivers.json`
- `GET /current/constructors.json`
- `GET /current/circuits.json`
- `GET /seasons.json`

No requiere autenticación ni API key.

### 2️⃣ Wikipedia REST API (imágenes de drivers)
Endpoint:
- `https://en.wikipedia.org/api/rest_v1/page/summary/{title}`

- Se utiliza `originalimage.source` si existe.
- Se usa `thumbnail.source` como fallback.
- En caso de no existir imagen, se muestra placeholder con icono.

## Arquitectura del proyecto
```text
lib/
 ├── models/          → Entidades (Driver, Team, Circuit, Season)
 ├── services/        → Cliente API Jolpi + Servicio Wikipedia
 ├── repositories/    → Lógica de acceso a datos + caché
 ├── screens/         → Pantallas principales y detalle de driver
 ├── components/      → Widgets reutilizables
```

Se aplica:
- Separación por capas
- Lógica asíncrona con async/await
- Control de errores centralizado
- Caché en memoria
- Control del ciclo de vida de recursos

## Instalación y ejecución
### Requisitos
- Flutter SDK instalado
- Android Studio / VS Code

### Ejecutar en modo debug
```bash
flutter pub get
flutter run
```

### Generar APK
```bash
flutter build apk --release
```

La APK se genera en:
- `build/app/outputs/flutter-apk/app-release.apk`

## Dependencias principales
- `http`
- `cached_network_image`

## Aspectos técnicos evaluables (rúbrica)
- ✔ Uso de múltiples endpoints
- ✔ Conversión JSON -> objetos tipados
- ✔ Lógica asíncrona sin bloqueo de interfaz
- ✔ Manejo de errores HTTP y red
- ✔ Caché en memoria
- ✔ Control del ciclo de vida de recursos
- ✔ Gestión de imágenes remotas (drivers)

## Autor
- Nombre del estudiante
- Curso / Asignatura
