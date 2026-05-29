#!/usr/bin/env python3
"""
consistency_check.py — Verificador de consistencia fina.

Chequea objetos, tiempo, clima, atributos de personaje y ubicaciones
contra un registro curado en .fiction/consistency.json.

Uso:
    python tools/consistency_check.py                   # resumen global
    python tools/consistency_check.py --cap 5           # detalle de un capítulo
    python tools/consistency_check.py --cap 5-8         # rango
    python tools/consistency_check.py --all             # todos los capítulos
    python tools/consistency_check.py --json            # salida JSON
"""

import argparse
import json
import sys

from vault import VAULT, CONSISTENCY_FILE, get_chapter_files, get_chapter_number, read_chapter, get_chapter_title


def load_consistency() -> dict:
    if not CONSISTENCY_FILE.exists():
        print(f"ERROR: {CONSISTENCY_FILE} no encontrado.")
        print("Créalo primero con los datos curados del proyecto.")
        sys.exit(1)
    return json.loads(CONSISTENCY_FILE.read_text("utf-8"))


# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

def check_objects(
    raw_text: str, clean_text: str, chapter: int, data: dict,
) -> list[dict]:
    issues = []
    objects = data.get("objects", {})

    for obj_id, obj in objects.items():
        aliases = [a.lower() for a in obj.get("aliases", [obj["name"]])]
        first = obj.get("first_chapter", 1)
        last = obj.get("last_chapter")
        owner = obj.get("owner", "")

        found = False
        matched_alias = ""
        for alias in aliases:
            if alias in clean_text:
                found = True
                matched_alias = alias
                break

        if found:
            if chapter < first:
                issues.append({
                    "type": "object",
                    "severity": "error",
                    "msg": f"'{obj['name']}' aparece en cap {chapter} "
                           f"pero su primera aparición es cap {first}.",
                    "context": f"Objeto: {obj_id}, alias: «{matched_alias}»",
                })
            if last and chapter > last:
                issues.append({
                    "type": "object",
                    "severity": "warn",
                    "msg": f"'{obj['name']}' aparece en cap {chapter} "
                           f"pero su última aparición registrada es cap {last}.",
                    "context": f"Objeto: {obj_id}, alias: «{matched_alias}»",
                })

    return issues


def check_time(
    raw_text: str, clean_text: str, chapter: int, data: dict, prev_chapter: int | None,
) -> list[dict]:
    issues = []
    chain = data.get("time_chain", [])
    entry = next((e for e in chain if e["chapter"] == chapter), None)
    if not entry:
        return issues

    recorded_keywords = entry.get("keywords", [])
    if not recorded_keywords:
        return issues

    found_keywords = [kw for kw in recorded_keywords if kw.lower() in clean_text]

    if recorded_keywords and not found_keywords:
        issues.append({
            "type": "time",
            "severity": "info",
            "msg": f"Tiempo registrado: «{entry['time']}». "
                   f"No se detectaron palabras clave en el texto.",
            "context": f"Keywords esperadas: {recorded_keywords[:3]}...",
        })

    return issues


def check_weather(
    raw_text: str, clean_text: str, chapter: int, data: dict,
) -> list[dict]:
    issues = []
    chain = data.get("weather_chain", [])
    entry = next((e for e in chain if e["chapter"] == chapter), None)
    if not entry:
        return issues

    recorded_keywords = entry.get("keywords", [])
    if not recorded_keywords:
        return issues

    found_keywords = [kw for kw in recorded_keywords if kw.lower() in clean_text]

    if recorded_keywords and not found_keywords:
        issues.append({
            "type": "weather",
            "severity": "info",
            "msg": f"Clima registrado: «{entry['weather']}». "
                   f"No se detectaron palabras clave en el texto.",
            "context": f"Keywords esperadas: {recorded_keywords[:3]}...",
        })

    return issues


def check_attributes(
    raw_text: str, clean_text: str, chapter: int, data: dict,
) -> list[dict]:
    issues = []
    attrs = data.get("attributes", [])

    for attr_entry in attrs:
        if attr_entry["chapter"] != chapter:
            continue
        keywords = attr_entry.get("keywords", [])
        found = [kw for kw in keywords if kw.lower() in clean_text]
        if not found:
            issues.append({
                "type": "attribute",
                "severity": "info",
                "msg": f"Atributo de {attr_entry['character']}: "
                       f"«{attr_entry['attr']} = {attr_entry['value']}». "
                       f"No se detectaron palabras clave en el capítulo.",
                "context": f"Keywords: {keywords[:2]}...",
            })

    return issues


def check_locations(
    raw_text: str, clean_text: str, chapter: int, data: dict,
) -> list[dict]:
    issues = []
    locs = data.get("locations", [])

    for loc_entry in locs:
        if loc_entry["chapter"] != chapter:
            continue
        keywords = loc_entry.get("keywords", [])
        found = [kw for kw in keywords if kw.lower() in clean_text]
        if not found:
            issues.append({
                "type": "location",
                "severity": "info",
                "msg": f"Ubicación de {loc_entry['character']}: "
                       f"«{loc_entry['location']}». "
                       f"No se detectaron palabras clave en el capítulo.",
                "context": f"Keywords: {keywords[:3]}...",
            })

    return issues


# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

SEVERITY_LABELS = {
    "error": "✗ ERROR",
    "warn": "⚠ WARN",
    "info": "ℹ INFO",
}


def format_issues(issues: list[dict], chapter: int, title: str) -> str:
    if not issues:
        return ""

    lines = [f"--- Capítulo {chapter}: {title} ---"]
    for iss in sorted(issues, key=lambda x: ("error", "warn", "info").index(x["severity"])):
        label = SEVERITY_LABELS.get(iss["severity"], "•")
        lines.append(f"  {label} {iss['msg']}")
        lines.append(f"        {iss['context']}")
    lines.append("")
    return "\n".join(lines)


def format_summary(results: list[dict]) -> str:
    if not results:
        return "Sin resultados."

    total_errors = sum(1 for r in results for i in r["issues"] if i["severity"] == "error")
    total_warns = sum(1 for r in results for i in r["issues"] if i["severity"] == "warn")
    total_infos = sum(1 for r in results for i in r["issues"] if i["severity"] == "info")
    total = total_errors + total_warns + total_infos

    lines = [
        "=" * 50,
        "VERIFICACIÓN DE CONSISTENCIA",
        "=" * 50,
        f"Capítulos analizados: {len(results)}",
        f"Total de incidencias: {total}",
        f"  {SEVERITY_LABELS['error']}: {total_errors}",
        f"  {SEVERITY_LABELS['warn']}: {total_warns}",
        f"  {SEVERITY_LABELS['info']}: {total_infos}",
        "",
    ]

    for r in results:
        issues = r["issues"]
        if not issues:
            lines.append(f"✓ Capítulo {r['chapter']}: {r['title']} — sin incidencias")
        else:
            lines.append(format_issues(issues, r["chapter"], r["title"]))

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_chapter_range(arg: str) -> set[int]:
    """Interpreta '5', '5-8', 'all' como conjunto de números de capítulo."""
    if arg in ("all", "--all", "*"):
        return {get_chapter_number(f) for f in get_chapter_files()}

    chapters = set()
    for part in arg.split(","):
        part = part.strip()
        if "-" in part:
            a, b = part.split("-", 1)
            chapters.update(range(int(a), int(b) + 1))
        else:
            chapters.add(int(part))
    return chapters


def check_transitions(data: dict) -> list[dict]:
    """Verifica transiciones de tiempo y clima entre capítulos consecutivos.

    Detecta saltos imposibles (ej. noche → mediodía sin transición) y
    cambios climáticos bruscos sin justificación narrativa.
    """
    issues = []
    time_chain = data.get("time_chain", [])
    weather_chain = data.get("weather_chain", [])

    for i, curr in enumerate(time_chain):
        if i == 0:
            continue
        prev = time_chain[i - 1]
        cn = curr["chapter"]
        pn = prev["chapter"]

        # Si capítulos no consecutivos, saltar
        if cn != pn + 1:
            continue

        p_time = prev.get("time", "")
        c_time = curr.get("time", "")

        # Detectar saltos problemáticos
        night_to_midday = ("noche" in p_time and "mediodía" in c_time)
        if night_to_midday:
            issues.append({
                "type": "time_transition",
                "severity": "warn",
                "msg": f"Capítulo {pn} termina de noche y capítulo {cn} es mediodía. "
                       "Transición temporal sin justificación.",
                "context": f"«{p_time}» → «{c_time}»",
            })

        # Clima: cambios bruscos
        w_prev = next((w for w in weather_chain if w["chapter"] == pn), None)
        w_curr = next((w for w in weather_chain if w["chapter"] == cn), None)
        if w_prev and w_curr:
            p_weather = w_prev.get("weather", "")
            c_weather = w_curr.get("weather", "")
            p_kw = set(w_prev.get("keywords", []))
            c_kw = set(w_curr.get("keywords", []))
            # Sin sol → sol brillante sin transición
            if "sin sol" in p_weather and "sol" in c_weather and "sol" not in p_kw:
                issues.append({
                    "type": "weather_transition",
                    "severity": "info",
                    "msg": f"Cambio climático entre capítulos {pn} y {cn}: "
                           f"«{p_weather}» → «{c_weather}». Verificar que sea intencional.",
                    "context": f"Sin palabras clave de transición compartidas",
                })
    return issues


def main():
    parser = argparse.ArgumentParser(
        description="Verificador de consistencia fina."
    )
    parser.add_argument(
        "--cap", "-c", type=str, default="all",
        help="Capítulo(s): número, rango (5-8), o 'all' (defecto)",
    )
    parser.add_argument(
        "--json", action="store_true",
        help="Salida JSON",
    )
    args = parser.parse_args()

    data = load_consistency()

    chapters_target = parse_chapter_range(args.cap)
    chapter_files = [f for f in get_chapter_files()
                     if get_chapter_number(f) in chapters_target]

    if not chapter_files:
        print(f"No se encontraron capítulos: {args.cap}")
        sys.exit(1)

    results = []
    for cf in chapter_files:
        num, raw, clean = read_chapter(cf)
        title = get_chapter_title(raw)

        issues = []
        issues.extend(check_objects(raw, clean, num, data))
        issues.extend(check_time(raw, clean, num, data, None))
        issues.extend(check_weather(raw, clean, num, data))
        issues.extend(check_attributes(raw, clean, num, data))
        issues.extend(check_locations(raw, clean, num, data))

        results.append({
            "chapter": num,
            "title": title,
            "issues": issues,
        })

    # Transiciones entre capítulos (solo en modo global)
    if args.cap == "all":
        trans_issues = check_transitions(data)
        if trans_issues:
            if args.json:
                results.append({"chapter": "transiciones", "title": "Entre capítulos", "issues": trans_issues})
            else:
                print(format_issues(trans_issues, 0, "Transiciones entre capítulos"))

    if args.json:
        print(json.dumps(results, ensure_ascii=False, indent=2))
    else:
        print(format_summary(results))


if __name__ == "__main__":
    main()
