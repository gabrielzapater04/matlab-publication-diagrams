# MATLAB publication diagrams

Skill para crear diagramas de publicación en MATLAB y Octave con la biblioteca vectorial pdlib.

Incluye diagramas de flujo, procesos, arquitectura, plantas y redes neuronales, seis ejemplos y documentación de la API.

## Instalar en Codex

Pide a Codex: "Instala el skill del repositorio gabrielzapater04/matlab-publication-diagrams, ruta skills/matlab-publication-diagrams, usando skill-installer".

El skill estará disponible en el siguiente turno después de instalarlo.

## Uso

Pide un diagrama en MATLAB para un paper e indica el contenido, el idioma y la revista si la conoces.

Para ejecutar los scripts, agrega skills/matlab-publication-diagrams/scripts/pdlib al path de MATLAB. Consulta SKILL.md y los ejemplos para el flujo completo.

Los archivos originales del ZIP se conservan. La carpeta .claude-plugin contiene los metadatos originales para Claude.

## Instalación manual en Codex (Windows)

1. Descarga el ZIP del repositorio desde **Code > Download ZIP** y descomprímelo.
2. Copia la carpeta `skills/matlab-publication-diagrams` completa a `%USERPROFILE%\.codex\skills\matlab-publication-diagrams`. Crea la carpeta `skills` si no existe.
3. Comprueba que el archivo quede en `%USERPROFILE%\.codex\skills\matlab-publication-diagrams\SKILL.md`, junto a las carpetas `scripts`, `references` y `examples`.
4. Abre un nuevo chat en Codex. Si el skill no aparece, reinicia la aplicación.
5. Invócalo con `$matlab-publication-diagrams` y describe el diagrama que necesitas.

Si usas un `CODEX_HOME` personalizado, coloca la carpeta en `CODEX_HOME/skills` en lugar de la ruta anterior. En macOS/Linux, la ruta predeterminada es `~/.codex/skills/matlab-publication-diagrams`.

El skill aporta las instrucciones y la biblioteca. Para ejecutar y exportar los diagramas necesitas MATLAB u Octave en el entorno de trabajo.
