# Free Fire iOS Mod Menu

Proyecto de Mod Menu para **Garena Free Fire (iOS)** (`com.dts.freefireth`).

## Compilación Automática (GitHub Actions)
Este repositorio incluye un flujo automatizado en `.github/workflows/build.yml`:
1. Cada vez que se hace un `push` a la rama `main`, GitHub Actions compila automáticamente el tweak usando **Theos** en un runner de macOS.
2. Al terminar la compilación, puedes descargar **`FreeFireModMenu.dylib`** y el paquete **`.deb`** desde la sección de **Artifacts** en la pestaña **Actions**.
3. **Inyección directa a IPA:** Puedes ir a la pestaña **Actions** -> **Build & Inject Free Fire Mod Menu** -> **Run workflow**, e ingresar el enlace directo de descarga del archivo `.ipa` de Free Fire. El sistema descargará el juego, inyectará el mod con **Azule** y te entregará el IPA modificado listo para instalar.

## Instalación Local con Sideloadly (Windows)
1. Descarga el archivo `.ipa` de Free Fire.
2. Descarga `FreeFireModMenu.dylib` desde los Artifacts de GitHub Actions.
3. Abre **Sideloadly** y arrastra el IPA.
4. En **Advanced Options** -> **Inject dylibs/frameworks**, agrega `FreeFireModMenu.dylib` y `CydiaSubstrate.dylib`.
5. Conecta tu dispositivo iOS y presiona **Start**.
