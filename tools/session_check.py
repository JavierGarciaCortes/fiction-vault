#!/usr/bin/env python3
"""
session_check.py — ¿Qué cambió desde la última sesión?

Ejecuta git diff, prose_scanner y consistency_check sobre los capítulos
modificados y presenta un resumen ejecutivo.

Uso:
    python tools/session_check.py                      # resumen completo
    python tools/session_check.py --quick              # solo diff + scores
    python tools/session_check.py --json               # salida JSON

Ideal para ejecutar al inicio de cada sesión de edición.
"""

import argparse
import json
import re
import subprocess

from vault import VAULT, CHAPTERS_DIR, ESTADO_FILE, PENDIENTES_FILE, get_chapter_number


def git_diff_stats() -> list[dict]:
    """Ejecuta git diff --stat contra HEAD y devuelve lista de archivos cambiados."""
    try:
        result = subprocess.run(
            ["git", "diff", "--stat", "HEAD"],
            capture_output=True, text=True, cwd=VAULT,
        )
        if result.returncode != 0:
            return []
        lines = result.stdout.strip().split("\n")
        files = []
        for line in lines:
            m = re.match(r"\s*(.+?\.md)\s*\|\s*(\d+)\s*[+-]+", line)
            if m:
                files.append({"file": m.group(1), "changes": int(m.group(2))})
        return files
    except FileNotFoundError:
        return []


def git_diff_files() -> list[str]:
    """Devuelve nombres de archivos .md modificados no commiteados."""
    try:
        result = subprocess.run(
            ["git", "diff", "--name-only", "HEAD"],
            capture_output=True, text=True, cwd=VAULT,
        )
        if result.returncode != 0:
            return []
        return [f.strip() for f in result.stdout.strip().split("\n") if f.strip().endswith(".md")]
    except FileNotFoundError:
        return []


def run_scanner(chapter: int) -> dict | None:
    """Ejecuta prose_scanner sobre un capítulo y devuelve score."""
    try:
        import prose_scanner
        data = prose_scanner.scan_chapter(f"{chapter:02d}")
        if data:
            return {
                "cap": data["cap"],
                "words": data["palabras"],
                "score": data["severidad"]["score"],
                "tier": data["severidad"]["tier"],
            }
    except Exception:
        pass
    return None


def read_pendientes() -> dict | None:
    """Lee Referencias/Pendientes.md y extrae tareas activas."""
    if not PENDIENTES_FILE.exists():
        return None
    try:
        text = PENDIENTES_FILE.read_text()
        info = {}
        # Fecha de última actualización
        m = re.search(r"última actualización:\s*(.+?)$", text, re.MULTILINE | re.IGNORECASE)
        if m:
            info["ultima_actualizacion"] = m.group(1).strip()
        # Tareas por prioridad
        altas = len(re.findall(r"🔴\s*Alta\s*\|", text))
        medias = len(re.findall(r"🟡\s*Media\s*\|", text))
        bajas = len(re.findall(r"🟢\s*Baja\s*\|", text))
        if altas or medias or bajas:
            info["tareas"] = {"altas": altas, "medias": medias, "bajas": bajas}
        return info
    except Exception:
        return None


def read_estado() -> dict | None:
    """Lee Referencias/Estado.md y extrae info relevante."""
    if not ESTADO_FILE.exists():
        return None
    try:
        text = ESTADO_FILE.read_text()
        info = {}
        # Última actualización (primera línea con fecha)
        m = re.search(r"última actualización.*?([^.]+\.)", text, re.IGNORECASE)
        if m:
            info["ultima_actualizacion"] = m.group(1).strip()
        # Palabras totales
        m = re.search(r"~([\d.]+)\s*palabras", text)
        if m:
            info["palabras"] = m.group(1)
        # Capítulos
        m = re.search(r"(\d+)\s*capítulos", text)
        if m:
            info["capitulos"] = int(m.group(1))
        # Puntos débiles activos (líneas que empiezan con | y tienen prioridad Baja/Media/Alta sin tachado)
        puntos_debiles = []
        for line in text.split("\n"):
            if line.startswith("|") and re.search(r"\|\s*(Baja|Media|Alta)\s*\|", line):
                if "~~" not in line:  # no tachados
                    puntos_debiles.append(line.strip())
            if line.startswith("##") and puntos_debiles:
                break  # siguiente sección
        info["puntos_debiles_activos"] = len(puntos_debiles)
        return info
    except Exception:
        return None


def format_summary(changed_files: list[dict], scanned: list[dict], estado: dict | None = None) -> str:
    lines = []
    lines.append("=" * 60)
    lines.append(f"  SESSION CHECK — {VAULT.name}")
    lines.append("=" * 60)
    lines.append("")

    if not changed_files:
        lines.append("  Sin cambios desde la última sesión. ✓")
        lines.append("")
        return "\n".join(lines)

    lines.append(f"  Archivos modificados: {len(changed_files)}")
    lines.append("")
    for f in changed_files:
        lines.append(f"    {f['file']} ({f['changes']} líneas)")
    lines.append("")

    # Detectar capítulos entre los cambios
    chapter_nums = sorted(set(
        n for f in changed_files
        if (n := get_chapter_number(f["file"])) is not None
    ))

    if chapter_nums:
        lines.append(f"  Capítulos afectados: {', '.join(f'{n:02d}' for n in chapter_nums)}")
        lines.append("")

        # Scanner stats
        if scanned:
            lines.append(f"  {'Cap':<6} {'Palabras':>8} {'Score':>6} {'Tier':<10}")
            lines.append(f"  {'-'*30}")
            for s in scanned:
                lines.append(f"  {s['cap']:<6} {s['words']:>8} {s['score']:>5.1f}  {s['tier']:<10}")
            lines.append("")

    # Total diff stats from git
    try:
        result = subprocess.run(
            ["git", "diff", "--shortstat", "HEAD"],
            capture_output=True, text=True, cwd=VAULT,
        )
        if result.stdout.strip():
            lines.append(f"  Git: {result.stdout.strip()}")
            lines.append("")
    except FileNotFoundError:
        pass

    # Estado.md info (solo en modo --full)
    if estado:
        lines.append(f"  --- Estado del proyecto ---")
        if estado.get("ultima_actualizacion"):
            lines.append(f"  Actualización: {estado['ultima_actualizacion']}")
        if estado.get("palabras"):
            lines.append(f"  Palabras: ~{estado['palabras']}")
        if estado.get("capitulos"):
            lines.append(f"  Capítulos: {estado['capitulos']}")
        if estado.get("puntos_debiles_activos", 0) > 0:
            lines.append(f"  Puntos débiles activos: {estado['puntos_debiles_activos']}")
        lines.append("")

    lines.append("  ---")
    lines.append("  Siguiente paso recomendado:")
    if chapter_nums:
        lines.append(f"    - scan_prose() para cada capítulo afectado")
        lines.append(f"    - check_transitions() si cambió tiempo/clima")
    lines.append(f"    - editorial_letter(beta=true) para foto global")
    lines.append(f"    - get_foreshadowing() para hilos abiertos")
    lines.append(f"    - Revisar Referencias/Estado.md para scores previos")
    lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Resumen de cambios entre sesiones")
    parser.add_argument("--quick", action="store_true", help="Solo diff + scores, sin scanner")
    parser.add_argument("--full", action="store_true", help="Incluye info de Estado.md y checklist del ritual")
    parser.add_argument("--json", action="store_true", help="Salida JSON")
    args = parser.parse_args()

    changed_files = git_diff_stats()
    changed_paths = git_diff_files()
    chapter_nums = sorted(set(
        n for p in changed_paths
        if (n := get_chapter_number(p)) is not None
    ))

    scanned = []
    if not args.quick and chapter_nums:
        for cn in chapter_nums:
            s = run_scanner(cn)
            if s:
                scanned.append(s)

    estado = None
    pendientes = None
    if args.full:
        estado = read_estado()
        pendientes = read_pendientes()

    if args.json:
        output = {
            "changed_files": changed_files,
            "chapter_numbers": chapter_nums,
            "scanned": scanned,
        }
        if estado:
            output["estado"] = estado
        if pendientes:
            output["pendientes"] = pendientes
        print(json.dumps(output, ensure_ascii=False, indent=2))
    else:
        # Mostrar pendientes activos siempre en modo --full
        if pendientes and pendientes.get("tareas"):
            t = pendientes["tareas"]
            print(f"  Pendientes: {t.get('altas', 0)}🔴 {t.get('medias', 0)}🟡 {t.get('bajas', 0)}🟢")
            if t.get('altas', 0) > 0:
                print(f"  ⚠️  Hay tareas de alta prioridad. Revisar Referencias/Pendientes.md")
            print("")
        print(format_summary(changed_files, scanned, estado))


if __name__ == "__main__":
    main()
