#!/usr/bin/env bash
# setup.sh — Inicializa las tools de escritura en una bóveda de Obsidian.
#
# Uso:
#   ./setup.sh                          # desde la raíz de la bóveda
#   ./setup.sh /ruta/a/la/boveda        # o pasar ruta como argumento
#
# Sin dependencias externas. Solo requiere Python 3.11+.

set -euo pipefail

VAULT="${1:-$(pwd)}"
VAULT="$(cd "$VAULT" && pwd)"

echo "📁 Inicializando fiction-forge en: $VAULT"
echo ""

# ----- tools/ -----
mkdir -p "$VAULT/tools"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for tool in vault.py fiction_mcp.py prose_scanner.py publish.py new_chapter.py editorial_letter.py editorial_insights.py consistency_check.py session_check.py manifiesto.py sync_manifiesto.py; do
    if [ -f "$SCRIPT_DIR/$tool" ]; then
        cp "$SCRIPT_DIR/$tool" "$VAULT/tools/$tool"
        echo "  ✅ tools/$tool copiado"
    fi
done

# ----- Makefile & pyproject.toml (raíz del vault) -----
for rootfile in Makefile pyproject.toml; do
    if [ -f "$SCRIPT_DIR/../$rootfile" ]; then
        cp "$SCRIPT_DIR/../$rootfile" "$VAULT/$rootfile"
        echo "  ✅ $rootfile copiado"
    fi
done

# ----- templates/ -----
if [ -d "$SCRIPT_DIR/templates" ]; then
    mkdir -p "$VAULT/tools/templates"
    cp -r "$SCRIPT_DIR/templates/"* "$VAULT/tools/templates/"
    echo "  ✅ tools/templates/ copiado"
fi

# ----- editorial_skill.md -----
if [ ! -f "$VAULT/tools/editorial_skill.md" ]; then
    SKL_SOURCE="$SCRIPT_DIR/templates/editorial_skill.md"
    if [ -f "$SKL_SOURCE" ]; then
        cp "$SKL_SOURCE" "$VAULT/tools/editorial_skill.md"
        echo "  ✅ tools/editorial_skill.md creado desde plantilla"
    fi
fi

# ----- .fiction/ -----
mkdir -p "$VAULT/.fiction"

if [ ! -f "$VAULT/.fiction/config.json" ]; then
    CFG_SOURCE="$SCRIPT_DIR/templates/config.json"
    if [ -f "$CFG_SOURCE" ]; then
        cp "$CFG_SOURCE" "$VAULT/.fiction/config.json"
        echo "  ✅ .fiction/config.json creado desde plantilla"
    else
        echo "  · config.json no encontrado en templates — saltando"
    fi
else
    echo "  · .fiction/config.json ya existe"
fi

if [ ! -f "$VAULT/.fiction/continuity.json" ]; then
    cat > "$VAULT/.fiction/continuity.json" << 'EOF'
{
  "deaths": [],
  "reveals": [],
  "status_changes": []
}
EOF
    echo "  ✅ .fiction/continuity.json creado (vacío — edítalo con las reglas de tu libro)"
else
    echo "  · .fiction/continuity.json ya existe"
fi

if [ ! -f "$VAULT/.fiction/character_states.json" ]; then
    cat > "$VAULT/.fiction/character_states.json" << 'EOF'
{
  "description": "Estados de personaje por rango de capítulos.",
  "characters": {
    "Protagonista": [
      [1, 5, "Introducción. Descubriendo el mundo."],
      [6, 10, "Conflicto. Enfrentando al antagonista."],
      [11, 15, "Clímax. Decisión final."]
    ]
  }
}
EOF
    echo "  ✅ .fiction/character_states.json creado (plantilla — edítalo con tus personajes)"
else
    echo "  · .fiction/character_states.json ya existe"
fi

# ----- Directorios de referencia -----
for d in Escritura Referencias Mundo Estilo; do
    if [ ! -d "$VAULT/$d" ]; then
        mkdir -p "$VAULT/$d"
        echo "  📂 $d/ creado"
    fi
done
for d in Mundo/Personajes Mundo/Lugares Mundo/Historia; do
    if [ ! -d "$VAULT/$d" ]; then
        mkdir -p "$VAULT/$d"
        echo "  📂 $d/ creado"
    fi
done

# ----- Consejos Sanderson (universal) -----
for _file in "Consejos Sanderson.md" "Consejos Stephen King.md" "Sanderson vs King.md"; do
    if [ ! -f "$VAULT/Estilo/$_file" ]; then
        _source="$SCRIPT_DIR/../Estilo/$_file"
        if [ -f "$_source" ]; then
            cp "$_source" "$VAULT/Estilo/$_file"
            echo "  ✅ Estilo/$_file copiado desde plantilla"
        else
            echo "  · Estilo/$_file no encontrado — saltando"
        fi
    else
        echo "  · Estilo/$_file ya existe"
    fi
done

# ----- Guía general (agnóstica) -----
if [ ! -f "$VAULT/Estilo/Guía general.md" ]; then
    STYLE_SOURCE="$SCRIPT_DIR/../Estilo/Guía general.md"
    if [ -f "$STYLE_SOURCE" ]; then
        cp "$STYLE_SOURCE" "$VAULT/Estilo/Guía general.md"
        echo "  ✅ Estilo/Guía general.md copiado desde plantilla"
    else
        echo "  · Estilo/Guía general.md no encontrado — se usará plantilla por defecto"
    fi
else
    echo "  · Estilo/Guía general.md ya existe"
fi

# ----- Guía de estilo (específica del proyecto) -----
if [ ! -f "$VAULT/Estilo/Guía de estilo.md" ]; then
    cat > "$VAULT/Estilo/Guía de estilo.md" << 'EOF'
# Guía de estilo del proyecto — [Nombre del libro]

> Aplicación concreta de [[Estilo/Guía general|Guía general]] a este proyecto.

## Sobre este libro

- **Título**: [Nombre del libro]
- **Género**:
- **Extensión**:
- **POV**:
- **Tono**:

## Vocabulario del mundo

| Término | Uso | Notas |
|---------|-----|-------|
|  |  |  |

## Voces de personaje (resumen)

| Personaje | Patrón de habla | Rasgos |
|-----------|----------------|--------|
|  |  |  |
EOF
    echo "  ✅ Estilo/Guía de estilo.md creado (plantilla — rellena las secciones de tu proyecto)"
else
    echo "  · Estilo/Guía de estilo.md ya existe"
fi

# ----- patrones.json (scanner) -----
if [ ! -f "$VAULT/Estilo/patrones.json" ]; then
    PTRN_SOURCE="$SCRIPT_DIR/templates/patrones.json"
    if [ -f "$PTRN_SOURCE" ]; then
        cp "$PTRN_SOURCE" "$VAULT/Estilo/patrones.json"
        echo "  ✅ Estilo/patrones.json copiado desde plantilla (20 patrones)"
    else
        echo "  · Estilo/patrones.json no encontrado en templates — saltando"
    fi
else
    echo "  · Estilo/patrones.json ya existe (borra y vuelve a ejecutar para resetear)"
fi

# ----- Fichas de personaje/lugar placeholder -----
if [ ! -f "$VAULT/Mundo/Personajes/Protagonista.md" ]; then
    if [ -f "$SCRIPT_DIR/templates/character.md" ]; then
        cp "$SCRIPT_DIR/templates/character.md" "$VAULT/Mundo/Personajes/Protagonista.md"
        echo "  ✅ Mundo/Personajes/Protagonista.md creado desde plantilla"
        echo "    (Renómbralo y edítalo para cada personaje de tu libro)"
    fi
fi
if [ ! -f "$VAULT/Mundo/Lugares/Lugar ejemplo.md" ]; then
    if [ -f "$SCRIPT_DIR/templates/location.md" ]; then
        cp "$SCRIPT_DIR/templates/location.md" "$VAULT/Mundo/Lugares/Lugar ejemplo.md"
        echo "  ✅ Mundo/Lugares/Lugar ejemplo.md creado desde plantilla"
        echo "    (Renómbralo y edítalo para cada ubicación de tu mundo)"
    fi
fi

# ----- lore placeholder (Mundo/Historia/) -----
if [ ! -f "$VAULT/Mundo/Historia/Lore ejemplo.md" ]; then
    if [ -f "$SCRIPT_DIR/templates/lore.md" ]; then
        cp "$SCRIPT_DIR/templates/lore.md" "$VAULT/Mundo/Historia/Lore ejemplo.md"
        echo "  ✅ Mundo/Historia/Lore ejemplo.md creado desde plantilla"
        echo "    (Renómbralo y edítalo para cada entrada de lore de tu mundo)"
    fi
fi

# ----- manifiesto.json (orden de capítulos) -----
if [ ! -f "$VAULT/Escritura/manifiesto.json" ]; then
    cat > "$VAULT/Escritura/manifiesto.json" << 'MANIFEOF'
{
  "descripcion": "Orden narrativo de los capítulos. El índice del array = número de capítulo (0 = prólogo).",
  "orden": []
}
MANIFEOF
    echo "  ✅ Escritura/manifiesto.json creado (vacío — se llena al crear capítulos)"
fi

# ----- outliner (Referencias/) -----
if [ ! -f "$VAULT/Referencias/Outliner.md" ]; then
    if [ -f "$SCRIPT_DIR/templates/outliner.md" ]; then
        cp "$SCRIPT_DIR/templates/outliner.md" "$VAULT/Referencias/Outliner.md"
        echo "  ✅ Referencias/Outliner.md creado desde plantilla"
    fi
fi

# ----- opencode.json -----
if [ ! -f "$VAULT/opencode.json" ]; then
    cat > "$VAULT/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["AGENTS.md"],
  "model": "opencode-go/deepseek-v4-pro",
  "small_model": "opencode-go/deepseek-v4-flash",
  "agent": {
    "writer": {
      "model": "opencode-go/deepseek-v4-pro",
      "mode": "subagent",
      "description": "Escritor creativo. Genera y edita prosa, diálogo, brainstorming y arcos de personaje."
    },
    "editor": {
      "model": "opencode-go/deepseek-v4-pro",
      "mode": "primary",
      "description": "Editor disciplinado. Coordina subagentes, analiza consistencia y lore, aplica cambios en formato estricto. NUNCA improvisa de memoria: consulta las tools del MCP antes de emitir juicios sobre worldbuilding."
    },
    "structurer": {
      "model": "opencode-go/deepseek-v4-pro",
      "mode": "subagent",
      "description": "Estructurador narrativo. Outline, ritmo, sistemas de magia, agujeros de guion. Cuando reciba feedback del crítico: (1) implementa cada punto o (2) explica por qué lo rechaza. No ignores objeciones sin respuesta."
    },
    "lector": {
      "model": "opencode-go/deepseek-v4-pro",
      "mode": "subagent",
      "description": "Lector beta con ojos frescos. Lee el manuscrito sin contexto de worldbuilding, ignorando todo conocimiento previo sobre la obra. Juzga como lector, no como editor."
    },
    "critico": {
      "model": "opencode-go/deepseek-v4-pro",
      "mode": "subagent",
      "description": "Crítico con ojo de guionista. Busca agujeros de guion, clichés manidos, hilos sueltos, reglas rotas, promesas incumplidas. Implacable. No endulza nada. Si el structurer ignora objeciones, las reitera con más fuerza. Pide evidencias, no promesas."
    }
  },
  "mcp": {
    "fiction-context": {
      "type": "local",
      "command": ["python3", "tools/fiction_mcp.py"],
      "enabled": true,
      "description": "Contexto de escritura: personajes, lore, continuidad, foreshadowing"
    }
  }
}
EOF
    echo "  ✅ opencode.json creado"
else
    echo "  · opencode.json ya existe (verifica que tenga la sección mcp.fiction-context)"
fi

# ----- Referencias/ templates (Estado, Foreshadowing, Trama, Cronología) -----
REF_TEMPLATES="estado.md foreshadowing.md trama.md cronologia.md"
for _file in $REF_TEMPLATES; do
    _dest="$VAULT/Referencias/$(echo $_file | sed 's/estado/Estado/; s/foreshadowing/Foreshadowing/; s/trama/Trama principal/; s/cronologia/Cronología/')"
    if [ ! -f "$_dest" ]; then
        _source="$SCRIPT_DIR/templates/$_file"
        if [ -f "$_source" ]; then
            cp "$_source" "$_dest"
            echo "  ✅ $(basename "$_dest") creado desde plantilla"
        fi
    else
        echo "  · $(basename "$_dest") ya existe"
    fi
done

# ----- .fiction/consistency.json -----
if [ ! -f "$VAULT/.fiction/consistency.json" ]; then
    CSNC_SOURCE="$SCRIPT_DIR/templates/consistency.json"
    if [ -f "$CSNC_SOURCE" ]; then
        cp "$CSNC_SOURCE" "$VAULT/.fiction/consistency.json"
        echo "  ✅ .fiction/consistency.json creado desde plantilla"
    else
        echo "  · consistency.json no encontrado en templates — saltando"
    fi
else
    echo "  · .fiction/consistency.json ya existe"
fi

# ----- voice_profiles.json -----
if [ ! -f "$VAULT/.fiction/voice_profiles.json" ]; then
    cat > "$VAULT/.fiction/voice_profiles.json" << 'EOF'
{
  "description": "Perfiles de voz de personajes para check_voice_consistency y editorial_letter.",
  "profiles": {
    "Protagonista": {
      "esperado": "Describe el patrón de habla de tu protagonista (ej. preguntativa, imperativa, formal, etc.)",
      "checks": [["preguntas", null], ["imperativos", null]]
    },
    "Antagonista": {
      "esperado": "Describe el patrón de habla del antagonista",
      "checks": [["elipsis", null], ["longitud_media", null]]
    }
  }
}
EOF
    echo "  ✅ .fiction/voice_profiles.json creado (plantilla — edítalo con los perfiles de tus personajes)"
else
    echo "  · .fiction/voice_profiles.json ya existe"
fi

# ----- .gitignore -----
if [ -f "$VAULT/.gitignore" ]; then
    for pattern in "output/" "__pycache__/" ".venv/" "*.egg-info/" ".ruff_cache/" "dist/"; do
        if ! grep -q "^$pattern" "$VAULT/.gitignore" 2>/dev/null; then
            echo "$pattern" >> "$VAULT/.gitignore"
            echo "  ✅ $pattern añadido a .gitignore"
        fi
    done
fi

echo ""
echo "✅ Listo. La estructura de la bóveda está inicializada."
echo ""
if [ ! -f "$VAULT/AGENTS.md" ]; then
    cat > "$VAULT/AGENTS.md" << 'EOF'
# AGENTS.md

> Contexto del proyecto para el asistente. Cubre estructura, voces, herramientas, workflow.
> Las secciones marcadas con **PROYECTO** son específicas de tu libro; lo demás es plantilla agnóstica.

---

## 1. Estructura de la bóveda

```
├── Escritura/           # Capítulos + manifiesto.json (orden narrativo)
├── Mundo/
│   ├── Personajes/      # Fichas de personaje
│   ├── Lugares/         # Geografía y localizaciones
│   └── Historia/        # Lore, magia, cronología
├── Referencias/
│   ├── Trama principal.md
│   ├── Outliner.md         # Word counts, decisiones, hoja de ruta
│   ├── Cronología.md
│   ├── Foreshadowing.md
│   ├── Estado.md
├── Estilo/
│   ├── Guía general.md       # Reglas universales de ficción en español
│   ├── Guía de estilo.md     # Reglas específicas del proyecto
│   ├── patrones.json         # Patrones de prosa para el scanner
│   ├── Consejos Sanderson.md # Teoría de trama, personajes, worldbuilding
│   └── Consejos Stephen King.md # On Writing: disciplina, voz, oficio
├── .fiction/
│   ├── config.json           # Config del proyecto (rutas, acts, POV, etc.)
│   ├── continuity.json       # Reglas de continuidad (muertes, revelaciones)
│   ├── character_states.json # Estados de personaje por rango de capítulos
│   ├── consistency.json      # Objetos, tiempo, clima, atributos, ubicaciones
│   └── voice_profiles.json   # Perfiles de voz para herramientas de diagnóstico
├── tools/
│   ├── templates/            # Plantillas (chapter, character, location, patrones, …)
│   ├── fiction_mcp.py        # MCP context server
│   ├── prose_scanner.py      # Escáner de patrones de prosa
│   ├── publish.py            # Generador EPUB/HTML/PDF
│   ├── new_chapter.py        # Creador de capítulos
│   ├── editorial_letter.py   # Carta editorial automatizada
│   ├── editorial_insights.py # Análisis avanzados (estilo, diálogo, Save the Cat)
│   ├── consistency_check.py  # Verificador de consistencia
│   ├── session_check.py      # Resumen de cambios entre sesiones
│   ├── vault.py               # Módulo compartido (vault discovery, text/chapter utils)
│   ├── manifiesto.py         # Módulo compartido para leer manifiesto.json
│   ├── sync_manifiesto.py    # Sincroniza YAML desde manifiesto
│   └── setup.sh              # Inicializar bóveda nueva
├── opencode.json
└── AGENTS.md
```

---

## 2. MCP Context Server (`tools/fiction_mcp.py`)

Sin dependencias externas (stdlib). Se registra en `opencode.json` y se inicia solo.

### Tools base (10)

| Tool | Uso |
|---|---|
| `search_bible(query)` | Búsqueda en personajes, mundo, referencias, estilo |
| `get_character(name, chapter?)` | Perfil + estado opcional en un capítulo |
| `get_location(name)` | Perfil de ubicación: descripción, atmósfera, sonidos, capítulos asociados |
| `get_chapter_context(num)` | Apertura/cierre y transición con capítulos vecinos |
| `check_continuity(text, chapter)` | Valida contra reglas de muerte/revelación/estado |
| `check_consistency(chapter)` | Verifica objetos, tiempo, clima, atributos y ubicaciones |
| `check_transitions()` | Transiciones de tiempo/clima entre capítulos consecutivos |
| `get_foreshadowing(thread?)` | Ledger de siembras/pagos, completo o por hilo |
| `scan_prose(chapter?, include_context?)` | Ejecuta el scanner de prosa; resumen global o detalle por capítulo |
| `check_chapter(chapter)` | Meta-tool: ejecuta todos los análisis sobre un capítulo |

### Herramientas de diagnóstico por capítulo (9)

| Tool | Uso |
|---|---|
| `check_voice_consistency(chapter, character)` | Valida diálogo contra perfil de voz y NUNCA diría |
| `check_emotional_arc(chapter?)` | Intensidad emocional: párrafos planos, picos, saturados |
| `check_scenes(chapter?)` | Clasifica escenas por tipo y función narrativa |
| `check_hooks(chapter?)` | Evalúa ganchos de apertura/cierre |
| `check_show_dont_tell(chapter?)` | Emociones contadas sin anclaje físico |
| `check_backstory_dumps(chapter?)` | Info-dumps de backstory (pluscuamperfecto denso) |
| `check_dialogue_quality(chapter?)` | Atribuciones, info-dumps, diferenciación de voz |
| `get_style_diagnostics(chapter?)` | Legibilidad, filter words, adverbios, voz pasiva |
| `check_pacing(chapter?)` | Variación de longitud de frases; alerta ritmo plano |

### Herramientas estructurales (5)

| Tool | Uso |
|---|---|
| `get_pacing()` | Outliers de ritmo, balance de actos |
| `get_story_arc()` | Arco Vonnegut del manuscrito completo |
| `get_save_the_cat()` | 15 beats de Save the Cat |
| `get_chekhov_gun()` | Objetos sembrados vs pagados |
| `editorial_letter(chapter?, summary_only?, beta?, plan?, insights?, output_format?)` | Carta editorial completa |

---

## 3. Scanner (`tools/prose_scanner.py`)

```bash
python tools/prose_scanner.py              # resumen global
python tools/prose_scanner.py --cap XX     # detalle de un capítulo
python tools/prose_scanner.py --cap XX --context full  # con párrafos completos
python tools/prose_scanner.py --json        # salida JSON
python tools/prose_scanner.py --review      # modo interactivo
python tools/prose_scanner.py --ritmo       # estadísticas de longitud de frases
python tools/prose_scanner.py --validate    # detectar overlaps entre patrones
```

Patrones en `Estilo/patrones.json`. Categorías:
- `ai_fingerprint` — alta prioridad, filtrar siempre
- `fragile` — evaluar caso a caso
- `voice` — solo si es muletilla

---

## 4. Workflow de revisión <!-- PROYECTO — adapta los capítulos a tu libro -->

### ⚠️ Regla fundamental: quién escribe

**El único que escribe prosa creativa es el agente `writer` (o el usuario).** El editor (asistente principal) NUNCA redacta prosa por sí mismo. Su rol es:

1. **Detectar** problemas (con scanner, tools de diagnóstico, o lectura directa)
2. **Recopilar contexto** para el writer: pasaje completo, perfil del personaje, voz, reglas de estilo, lo que se necesita mejorar
3. **Pedir al writer** que genere la prosa nueva/modificada con instrucciones precisas
4. **Revisar** la propuesta del writer: verificar rayas en narrativa, voz del personaje, wikilinks, consistencia. **El editor puede iterar con el writer**: si la propuesta no convence, se le pide que la ajuste con indicaciones concretas. El editor no reescribe la prosa del writer — le da feedback para que el writer produzca una versión mejor. Solo cuando el editor considera que la propuesta está lista, pasa al paso 5.
5. **Formatear** con la metodología estándar (bloque ACTUAL/PROPUESTA) y **presentar al usuario** para su aprobación

El writer puede ser invocado vía `task` con `subagent_type="writer"`. El editor NUNCA redacta prosa directamente.

### Preliminar (cada sesión)
1. **Ejecutar `python tools/session_check.py`** — resumen de qué cambió (no opcional)
2. **`editorial_letter(beta=true)`** — carta editorial sintética con todas las analíticas. Foto global del manuscrito.
3. **`get_foreshadowing()`** — ledger completo de siembras y pagos
4. **Leer `Referencias/Estado.md`** — scores pre-cambio, puntos débiles conocidos
5. **Para el capítulo concreto**: `get_chapter_context(num)` + `get_character(POV, num)` + `get_location(relevante)`
6. **Para voz de personaje**: `check_voice_consistency(num, nombre)` para diagnóstico
7. **Para hilos narrativos**: `get_foreshadowing(thread?)` o consultar `Referencias/Foreshadowing.md`

### ⚠️ Regla de oro: NO improvisar de memoria

El editor NUNCA asume que recuerda un dato del worldbuilding. Ante cualquier consulta:
1. **Consultar la tool del MCP correspondiente** (`get_character`, `get_location`, `search_bible`, etc.)
2. **Solo después de leer la respuesta**, emitir un juicio o proponer una edición

Sin atajos. La memoria del editor es volátil; las tools y los archivos son la fuente de verdad.

### Pasada de prosa
1. `get_style_diagnostics()` + `scan_prose()` → identificar caps peor puntuados
2. `scan_prose(--cap XX)` + `check_show_dont_tell(XX)` → detalle de un capítulo
3. `check_backstory_dumps(XX)` + `check_dialogue_quality(XX)`
4. **Formato de edición línea a línea** (obligatorio para cada cambio):

   ```
   **Anterior (línea N):**  ← línea completa ANTES de la cambiada
   🔴 ACTUAL (línea M):     ← línea completa que se va a cambiar
   🟢 PROPUESTA (línea M):  ← línea completa modificada
   **Posterior (línea O):** ← línea completa DESPUÉS de la cambiada
   Motivo: explicación + enlace a regla
   ```

   - Las 4 líneas (anterior, actual, propuesta, posterior) son SIEMPRE completas.
   - Se usa `question()` con opciones `[Sí, No, Escribir respuesta]` antes de aplicar.
   - Tras cada cambio aceptado: editar → actualizar story bible.

### Pasada estructural
1. `get_pacing()` → outliers de ritmo y balance de actos
2. `check_scenes()` → escenas sin función narrativa
3. `check_hooks()` → ganchos débiles
4. `check_emotional_arc()` → párrafos planos o saturados
5. `get_story_arc()` → arco Vonnegut
6. `get_save_the_cat()` + `get_chekhov_gun()` → beats y objetos

### Post-edición
1. **Re-scan** tras cambios (`scan_prose()`)
2. `check_consistency(num)` + `check_transitions()` si se tocó tiempo/clima
3. `check_voice_consistency(num, personaje)` si se tocó diálogo
4. **Actualizar story bible**: personajes, lugares, historia, cronología, trama
5. Actualizar `Estado.md` con nuevos scores

---

## 5. Criterios de edición

### Aceptar
- `filter_sintió/oyó/vio/notó` → verbo directo o eliminar
- `filter_parecía` → "era"/"estaba" en descripción objetiva
- `había_participio` → pretérito simple si el orden se entiende
- `de_repente` → "de golpe", "sin aviso", o eliminar
- `empezó_a` → verbo directo
- `algo_vago` → nombre concreto o "lo que"
- `hedging` → eliminar si es muletilla
- `como_si` → indicativo si el símil no aporta

### Rechazar
- `como_un` + sustantivo (símiles literarios intencionales)
- Muletillas de voz de personaje
- Metáforas que funcionan

---

## 6. Voces de personaje  <!-- PROYECTO — rellena con tus personajes -->

| Personaje | Voz | Patrón dominante |
|---|---|---|
| **Protagonista** | [descripción breve] | [ej: preguntativa, imperativa, etc.] |
| **Antagonista** | [descripción breve] | [ej: evasiva, telegráfica, etc.] |
| **Secundario** | [descripción breve] | [ej: medida, formal, etc.] |

Fichas completas en `Mundo/Personajes/*.md`.

---

## 7. Compatibilidad Windows

El MCP server usa `python3` en `opencode.json`. En Windows, cambiar a `python`:

```json
"command": ["python", "tools/fiction_mcp.py"]
```

El resto funciona igual — `pathlib` maneja las rutas automáticamente.

---

## 8. Reglas de estilo

- **Raya (`—`) solo para diálogo**. Nunca en narrativa.
  `—Te he estado esperando —dijo sin volverse.` ✓
- **Voz y acción corporal tras raya**: en **minúscula** (salvo nombres propios).
- **Acción sin verbo dicendi**: en párrafo aparte si el diálogo termina.
- **Wiki links** `[[Entre dobles corchetes]]` para conceptos, personajes, lugares.
- **Metadata YAML** al inicio de cada capítulo (`--- capítulo: 1 título: ... ---`).
- **Elipsis entre capítulos**: no recapitular, saltar al siguiente momento relevante.

---

## 9. Skill de edición

El archivo `tools/editorial_skill.md` contiene instrucciones detalladas para cada tipo de tarea:
- **Edición de prosa**: orden de tools, criterios de aceptación/rechazo
- **Edición de diálogo**: verificación de voz por personaje, NUNCA diría
- **Edición estructural**: pacing, escenas, hooks, arco emocional
- **Post-edición**: re-scan automático tras cada cambio

---

## 10. Post-cambio: actualizar el proyecto

Después de CUALQUIER modificación (editar prosa, crear/renumerar capítulos, añadir tools, modificar patrones, cambiar lore, etc.), actualizar:

1. **`AGENTS.md`** — secciones 1 (estructura), 2 (tools MCP), 12 (tabla de capítulos), 13 (reglas POV), 14 (puntos débiles) si aplica
2. **`Referencias/Estado.md`** — tabla de scores, herramientas, pendientes, última actualización
3. **Story bible** — personajes, lugares, historia, cronología, trama si se tocó lore o eventos
4. **`.fiction/`** — consistency.json, character_states.json si se tocó tiempo/clima/estados
5. **`tools/editorial_skill.md`** — si se añadieron nuevas tools, flags o flujos
6. **Tabla de comandos** en sección 10 — si se añadieron flags nuevos a tools existentes
7. **`Escritura/manifiesto.json`** — si se insertó/eliminó/reordenó un capítulo
8. **Ejecutar `sync_manifiesto.py`** tras modificar manifiesto para que los YAML reflejen el orden
9. **Ejecutar `prose_scanner.py --validate`** después de modificar `patrones.json` para detectar overlaps

---

## 11. Comandos rápidos (Makefile)

```bash
make                    # listar todos los targets
make ritual             # chequeo completo del manuscrito
make scan               # prose scanner global
make scan-cap cap=07    # prose scanner de un capítulo
make publish            # EPUB
make publish-all        # EPUB + HTML + PDF
make letter             # carta editorial completa
make letter-cap cap=07  # carta editorial de un capítulo
make insights           # análisis avanzado (todos los módulos)
make session            # session check
make consistency        # consistencia global
make sync               # sincronizar YAML desde manifiesto
make lint               # ruff check
make format             # ruff format
```

### Equivalencias directas

```bash
python tools/prose_scanner.py                         # scan global
python tools/prose_scanner.py --cap XX --context full # detalle con contexto
python tools/prose_scanner.py --review                # interactivo
python tools/publish.py                               # EPUB → output/
python tools/publish.py --format all                  # EPUB + HTML + PDF
python tools/publish.py --beta                        # HTML con números de línea
python tools/editorial_letter.py                      # carta completa
python tools/editorial_letter.py --resumen            # solo prioridades
python tools/editorial_letter.py --plan               # plan de revisión faseado
python tools/editorial_letter.py --beta               # informe profesional
python tools/editorial_letter.py --insights           # análisis avanzado
python tools/editorial_letter.py --compare old/ new/  # comparar versiones
python tools/editorial_insights.py --module style     # diagnóstico de estilo
python tools/editorial_insights.py --module dialogue  # calidad de diálogo
python tools/new_chapter.py --list                    # listar capítulos
python tools/new_chapter.py "Título" -p 5            # insertar en posición 5
python tools/sync_manifiesto.py                       # sincronizar YAML
python tools/sync_manifiesto.py --dry                 # simular
python tools/consistency_check.py                     # consistencia global
python tools/consistency_check.py --cap XX            # capítulo específico
python tools/consistency_check.py --json              # salida JSON
```

---

## 12. Configuración

| Archivo | Propósito |
|---|---|
| `opencode.json` | Registra MCP server, apunta a AGENTS.md |
| `.fiction/config.json` | Config del proyecto (rutas, acts, POV, etc.) |
| `.fiction/continuity.json` | Reglas de muertes, revelaciones, cambios de estado |
| `.fiction/character_states.json` | Estado de cada personaje por rango de capítulos |
| `.fiction/consistency.json` | Objetos, tiempo, clima, atributos, ubicaciones por capítulo |
| `.fiction/voice_profiles.json` | Perfiles de voz para check_voice_consistency |
| `Mundo/Personajes/*.md` | Fichas con voz, tics, NUNCA diría |
| `Mundo/Lugares/*.md` | Fichas con atmósfera, sonidos, capítulos |
| `tools/editorial_skill.md` | Skill de edición: flujos paso a paso por tipo de tarea |

---

## 13. Para crear otra bóveda nueva

```bash
bash tools/setup.sh /ruta/a/otra-boveda
```

El script replica toda la estructura. Después editar secciones PROYECTO.

---

## 14. Tabla de capítulos (resumen rápido)  <!-- PROYECTO -->

| Cap | Título | POV | Lugar | Palabras | Arco |
|-----|--------|-----|-------|----------|------|
| 01 | [título] | [POV] | [lugar] | 0 | [acto / función] |
| 02 | [título] | [POV] | [lugar] | 0 | [acto / función] |

Estructura tres actos: setup (01–0X) → confrontación (0X–0Y) → resolución (0Y–0Z).

---

## 15. Reglas POV  <!-- PROYECTO — una sección por personaje-POV -->

### [Personaje 1] (caps XX–YY)
- **Tiempo verbal**: [ej: pretérito perfecto simple e imperfecto]
- **Filtro sensorial**: [ej: externo, táctico. Describe acciones, distancias, amenazas]
- **Lo que sabe / no sabe por capítulo**: listar capítulo a capítulo

### [Personaje 2] (caps XX–YY)
- Mismo formato

---

## 16. Puntos débiles conocidos  <!-- PROYECTO -->

| Cap | Problema | Prioridad |
|-----|----------|-----------|
| XX | [Problema detectado en ediciones previas] | Alta/Media/Baja |
| YY | [Otro problema] | Media |

---

## 17. Ritual de inicio de sesión (OBLIGATORIO)

Al empezar CUALQUIER sesión de edición/escritura, ejecutar estos pasos en orden. No saltarse ninguno. Si la sesión es solo de consulta (sin modificar texto), pueden omitirse los pasos 4 y 5.

1. **`python tools/session_check.py`** — resumen de qué cambió desde la última sesión. No es opcional. Si hubo cambios, el script ya identifica capítulos afectados.
2. **`editorial_letter(beta=true)`** — carta editorial sintética con todas las analíticas. Foto global del manuscrito: estructura, escenas, emociones, sensorial, foreshadowing, show/tell, hooks. Imprescindible para no perder perspectiva.
3. **`get_foreshadowing()`** — ledger completo de siembras y pagos. Saber qué hilos están abiertos antes de tocar cualquier capítulo.
4. **Leer `Referencias/Estado.md`** — scores pre-cambio, puntos débiles conocidos, pendientes. No editar a ciegas.
5. **Para el capítulo concreto a editar**: `get_chapter_context(num)` + `get_character(POV, num)` + `get_location(relevante)`. Ejecutar ANTES de leer o modificar el capítulo, para tener el contexto fresco.

### ⚠️ Regla de oro: NO improvisar de memoria

El editor NUNCA asume que recuerda un dato del worldbuilding. Ante cualquier consulta sobre un personaje, lugar, regla mágica, evento de la trama o estado de un hilo narrativo, la secuencia obligatoria es:

1. **Consultar la tool correspondiente del MCP** (`get_character`, `get_location`, `search_bible`, `get_foreshadowing`, `check_consistency`, `check_continuity`, etc.)
2. **Solo después de leer la respuesta de la tool**, emitir un juicio o proponer una edición

El editor nunca responde «creo que...», «si no recuerdo mal...» o «según recuerdo...» sobre datos del manuscrito. Si no hay tool que responda la pregunta, se lee el archivo fuente directamente. La memoria del editor es volátil; las tools y los archivos son la fuente de verdad.

---

## 18. Coordinación multi-agente

El editor actúa como coordinador único entre el usuario y los subagentes. Para decisiones que afectan a estructura, trama o worldbuilding, el editor delega en paralelo para obtener perspectivas independientes y no contaminadas.

### Cuándo delegar en paralelo

| Situación | Agentes | Por qué |
|-----------|---------|---------|
| Decisión estructural (expansión, reordenamiento, nuevo arco) | `structurer` + `critico` | Structurer diseña, critico busca fallos en el diseño |
| Evaluación de un capítulo nuevo o reescrito | `critico` + `lector` | Critico busca fallos técnicos, lector juzga experiencia de lectura sin contexto |
| Problema complejo de worldbuilding | `structurer` + `critico` + `lector` | Tres ángulos: lógica interna, agujeros de guion, credibilidad para el lector |
| Revisión de voz/personaje | `writer` + `critico` | Writer propone prosa, critico evalúa consistencia con el perfil |
| Antes de cerrar una ronda de revisión | `critico` + `lector` | Validación final: ¿quedan fallos? ¿funciona como lectura? |

### Protocolo de síntesis

1. **Lanzar los subagentes en paralelo** (un solo mensaje con múltiples `task`). Cada uno recibe el mismo contexto pero instrucciones específicas según su rol.
2. **Recoger los tres (o dos) informes.** No leerlos secuencialmente mientras el otro sigue pendiente — esperar a tener todos.
3. **Identificar conflictos**: si structurer dice A y critico dice ¬A, el editor resuelve el conflicto aplicando las reglas del proyecto (AGENTS.md, guías de estilo, decisiones cerradas).
4. **Sintetizar para el usuario**: presentar los hallazgos consolidados, marcando explícitamente los desacuerdos entre agentes. No presentar tres informes crudos — el editor filtra, jerarquiza y unifica.
5. **Pedir decisión al usuario** solo sobre los puntos donde haya desacuerdo sin resolver o donde la decisión sea creativa (no técnica).

### Protocolo de iteración (OBLIGATORIO para structurer + critico)

Cuando el critico detecta problemas que el structurer no resolvió, el editor **NO** presenta el plan al usuario inmediatamente. En su lugar:

1. **El editor reenvía las objeciones del critico al structurer** con instrucciones precisas: «Responde a CADA punto del crítico. Impleméntalo o explica por qué lo rechazas. No ignores ninguno.»
2. **El structurer refina** su plan respondiendo explícitamente a cada objeción. No puede ignorar ninguna. Si rechaza una, debe argumentar.
3. **El editor verifica** que todas las objeciones tienen respuesta (implementación o rechazo razonado).
4. **Si el critico detecta nuevas objeciones** tras la refinación, se repite el ciclo (máximo 3 rondas).
5. **Solo cuando el critico está satisfecho** (o el desacuerdo restante es menor y creativo), el editor presenta el plan consolidado al usuario.

Este protocolo aplica a TODA decisión estructural o de diseño. No es opcional.

### Reglas de rol

- **El critico es implacable.** No acepta medias tintas. Si el structurer ignora una objeción, el critico la reitera con más fuerza. Pide evidencias concretas, no promesas. No endulza.
- **El structurer responde a todo.** Cada objeción del critico recibe una de dos respuestas: (a) «Implementado en cap X así: ...» o (b) «Rechazado porque: ...». El silencio no es una opción.
EOF
    echo "  ✅ AGENTS.md creado (plantilla completa — edita las secciones PROYECTO)"
else
    echo "  · AGENTS.md ya existe"
fi

# ----- git init -----
if [ ! -d "$VAULT/.git" ]; then
    echo ""
    echo "¿Inicializar repositorio git en esta bóveda?"
    echo "  y) Sí — git init + commit inicial"
    echo "  n) No (puedes hacerlo más tarde)"
    echo ""
    printf "  [y/N]: "
    read -r GIT_CHOICE
    if [ "$GIT_CHOICE" = "y" ] || [ "$GIT_CHOICE" = "Y" ]; then
        cd "$VAULT"
        git init
        git add -A
        git commit -m "Inicializar bóveda con fiction-forge"
        echo "  ✅ Repositorio git inicializado y primer commit creado"
    else
        echo "  · Omitiendo git init. Para hacerlo más tarde: cd '$VAULT' && git init && git add -A && git commit -m 'Primer commit'"
    fi
fi

echo ""
echo "Próximos pasos:"
echo "  1. Edita AGENTS.md (secciones PROYECTO) con tus personajes, capítulos y reglas"
echo "  2. Edita .fiction/voice_profiles.json con los perfiles de voz de tus personajes"
echo "  3. Edita Referencias/ con tu trama, cronología y foreshadowing"
echo "  4. Edita .fiction/continuity.json con muertes, revelaciones y cambios de estado"
echo "  5. Edita .fiction/character_states.json con los estados de tus personajes"
echo "  6. Edita Mundo/Personajes/*.md, Mundo/Lugares/*.md y Mundo/Historia/*.md"
echo "  7. Revisa tools/editorial_skill.md para los flujos de edición detallados"
echo "  8. Usa Referencias/Outliner.md para planificar tu manuscrito"
echo "  9. Abre la bóveda en opencode — el MCP server se inicia solo"
echo ""
echo "Para instalar las tools como paquete (recomendado):"
echo "  python3 -m venv .venv && .venv/bin/pip install -e ."
echo "  make             # ver targets disponibles"
echo "  make ritual      # chequeo completo del manuscrito"
echo "  make publish     # generar EPUB"
echo ""
echo "Para PDF (opcional — necesita weasyprint):"
echo "  .venv/bin/pip install weasyprint"
echo "  make publish-pdf"
echo ""
echo "Para probar el server manualmente:"
echo "  echo '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/list\",\"params\":{}}' | python3 tools/fiction_mcp.py"
