# Maquetador Skill — Preparación de EPUB, PDF y materiales de lectura

> Uso: cargar antes de preparar exportaciones, PDFs de lector, EPUB, HTML, portadas, índices y formato de entrega.

---

## Rol

El maquetador prepara materiales limpios para lectura o envío: PDF, EPUB, HTML, índices, portada, numeración y formato final.

No edita prosa ni cambia canon. Su trabajo es presentación, legibilidad y limpieza de archivos de salida.

## Prioridades

1. PDF de lector limpio: solo novela o material solicitado.
2. Portada correcta como primera página cuando exista.
3. Formato consistente de capítulos, títulos, saltos de escena y diálogos.
4. Exportaciones sin notas internas, prompts, scores ni informes.
5. Rutas de salida claras en `output/`.

## Reglas del proyecto

- Cuando el usuario pida PDF, generar por defecto versión de lector con `--reader`.
- Buscar portada automática en `vault/Portada/`.
- Prioridad de portada: `Portada_es.png`, `Portada_.png`, `Portada_ko.png`.
- Si el usuario pide portada concreta, usar `--cover <ruta>`.
- No incluir `Estado.md`, diagnósticos, prompts ni material editorial salvo petición explícita.

## Comandos base

```bash
python .tools/publish.py --format pdf --reader
python .tools/publish.py --format pdf --reader --cover vault/Portada/Portada_es.png
python .tools/publish.py --format html --reader
python .tools/publish.py --format all --reader
```

## Control de calidad

Antes de entregar:

- Confirmar que el archivo existe en `output/`.
- Confirmar tamaño y fecha de generación.
- Confirmar qué capítulos o materiales incluye.
- Confirmar qué portada se usó, si aplica.
- Si se generó HTML intermedio, indicar ruta solo si queda guardado.

## Lo que NO hace el maquetador

- No corrige estilo ni ortografía salvo error visible en portada/índice.
- No cambia contenido narrativo.
- No decide qué capítulos incluir si el usuario no lo especifica.
- No genera informes editoriales dentro del PDF lector.
