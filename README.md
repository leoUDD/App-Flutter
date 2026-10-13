# app_flutter

App móvil de estadísticas de Fórmula 1 hecha con Flutter. Consume la API pública
[Jolpica (formato Ergast)](https://api.jolpi.ca/ergast/f1) para mostrar datos de la temporada.

---

## Organización del repositorio

```
App-Flutter/
  app/          # el proyecto Flutter completo (código, android, ios, pubspec.yaml...)
  documentos/   # documentación del proyecto (.docx y .md)
  README.md     # este archivo
```

Los comandos de `flutter` se ejecutan **dentro de la carpeta `app/`**.

---

## Requisitos

Todo lo siguiente debe estar instalado antes de ejecutar la app (el equivalente a un
`requirements.txt` en Flutter).

| Herramienta | Versión | Para qué | Descarga |
|---|---|---|---|
| Git | cualquiera reciente | Clonar el repositorio | https://git-scm.com/downloads |
| Flutter SDK | canal **stable** (probado con 3.47.7, incluye Dart ^3.13.5) | Framework de la app | https://docs.flutter.dev/get-started/install |
| Android Studio | reciente | Incluye el SDK de Android y el emulador | https://developer.android.com/studio |
| Android SDK Platform | **36** | Compilar para Android | Android Studio > SDK Manager |
| Android SDK Command-line Tools | latest | Licencias y herramientas por consola | Android Studio > SDK Manager > SDK Tools |
| Android SDK Platform-Tools | latest | `adb` (comunicación con el emulador) | Android Studio > SDK Manager > SDK Tools |
| Android Emulator | latest | Ejecutar la app sin celular físico | Android Studio > SDK Manager > SDK Tools |
| Imagen de sistema | Android 36, x86_64, Google Play | Dispositivo virtual | Android Studio > Device Manager |
| Conexión a internet | — | La app consulta Jolpica | — |

Requisitos del equipo (Windows): virtualización activada en la BIOS y al menos 8 GB de RAM
(recomendado 16 GB). El emulador usa Windows Hypervisor Platform.

Dependencias de Dart (se instalan solas con `flutter pub get`): `dio`.

**No hace falta** Visual Studio, salvo que quieras compilar la versión de escritorio de Windows.

---

## Instalación del entorno (una sola vez)

1. Instala **Git**, **Flutter** y **Android Studio** desde los enlaces de la tabla.
2. Descomprime Flutter en una ruta sin espacios ni `OneDrive` (por ejemplo `C:\src\flutter`)
   y agrega `C:\src\flutter\bin` a la variable de entorno `Path`.
3. Abre Android Studio, completa el asistente inicial e instala el plugin **Flutter**
   (acepta también Dart) desde *Plugins*.
4. En *SDK Manager > SDK Tools* marca **Android SDK Command-line Tools**, **Platform-Tools**
   y **Android Emulator**.
5. En *Device Manager > Create Device* crea un **Pixel** con imagen **Android 36 (x86_64)**.
   Anota el nombre que le pongas (en estas instrucciones: `Pixel_API36`).
6. Acepta las licencias de Android:
   ```bash
   flutter doctor --android-licenses
   ```
7. Verifica que todo esté bien:
   ```bash
   flutter doctor
   ```
   Debes ver una marca verde en **Flutter**, **Android toolchain** y **Connected device**.
   El aviso de Visual Studio puedes ignorarlo.

---

## Ejecutar la app (paso a paso)

### 1. Clonar el repositorio
```bash
git clone https://github.com/leoUDD/App-Flutter.git
cd App-Flutter/app
```

### 2. Instalar las dependencias
```bash
flutter pub get
```

### 3. Abrir el emulador
```bash
emulator -avd Pixel_API36
```
Si el comando `emulator` no se reconoce, agrega a tu `Path` las carpetas `emulator` y
`platform-tools` de tu SDK de Android (por ejemplo `C:\Android\Sdk\emulator`), o abre el emulador
desde Android Studio con *Device Manager > ▶*.

Espera entre 30 y 60 segundos a que Android termine de cargar. Para comprobar que está listo:
```bash
adb devices
```
Debe aparecer `emulator-5554   device`.

### 4. Ejecutar la app
Con el emulador abierto, desde la carpeta `app/`:
```bash
flutter run
```
Si te pregunta por el dispositivo, elige el que dice `emulator-5554` (no Windows ni Chrome).

Con la app corriendo en la terminal:

| Tecla | Acción |
|---|---|
| `r` | Recarga en caliente (aplica los cambios al instante) |
| `R` | Reinicia la app |
| `q` | Cierra la app |

### Ejecutar desde Android Studio (alternativa)
1. *File > Open* y elige la carpeta `app/` (no la raíz del repositorio).
2. Selecciona el emulador en la barra superior.
3. Pulsa el botón verde ▶ **Run**.

---

## Comandos útiles

```bash
flutter analyze     # revisa el código en busca de problemas
flutter test        # ejecuta las pruebas
flutter devices     # lista los dispositivos disponibles
flutter doctor -v   # diagnóstico detallado del entorno
```

---

## Estructura de la app (`app/`)

```
app/
  lib/
    main.dart                     # punto de entrada
    models/                       # clases que representan los datos de la API
      driver_standing.dart
      race.dart
    services/
      jolpica_service.dart        # llamadas a la API (con caché de 5 minutos)
    screens/
      standings_screen.dart       # campeonato de pilotos
  test/
    widget_test.dart              # pruebas de los modelos
  pubspec.yaml                    # dependencias del proyecto
```

## API utilizada

- **Jolpica:** `https://api.jolpi.ca/ergast/f1` — calendario, campeonatos, resultados e historia. No requiere clave.
- **OpenF1** (planificada): `https://api.openf1.org/v1` — vueltas, neumáticos y telemetría por sesión. No requiere clave para datos históricos.

Ambas APIs limitan la cantidad de peticiones, por eso el servicio guarda las respuestas en caché.

---

## Problemas frecuentes

| Problema | Solución |
|---|---|
| `Unable to find suitable Visual Studio toolchain` | Elegiste Windows como dispositivo. Abre el emulador y ejecuta `flutter run -d emulator-5554`. |
| `flutter run` solo ofrece Windows, Chrome y Edge | El emulador aún no terminó de cargar o no está abierto. Espera y revisa `adb devices`. |
| `emulator` no se reconoce como comando | Agrega la carpeta `emulator` del SDK al `Path` y abre una terminal nueva. |
| `Cannot find AVD system path` / `Broken AVD system path` | Define `ANDROID_SDK_ROOT` y `ANDROID_HOME` con la ruta de tu SDK y abre una terminal nueva. |
| `Android license status unknown` | Ejecuta `flutter doctor --android-licenses` y acepta todo con `y`. |
| La lista de pilotos muestra "No se pudo conectar" | Revisa tu conexión a internet y pulsa **Reintentar**. |
