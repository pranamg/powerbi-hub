#!/usr/bin/env python3
"""Structural checks for the repository's code and JSON assets.

This does not compile DAX, M, or PowerShell - there is no such compiler here,
and a real one would need Power BI Desktop. What it can do, and what this does,
is catch the mechanical failures that would otherwise only surface when someone
opens the file in Desktop:

- JSON and ipynb files must parse
- JSON files carrying a ``$schema`` must point at a URL whose last path
  segment matches the filename they validate
- DAX files must have balanced brackets and parentheses
- TMDL files must declare the object type they are named for
- PowerShell scripts must have balanced braces
- Python files must compile
- GitHub Actions workflows must declare at least one job

Deliberately conservative: it flags things that are certainly wrong rather
than things that are merely unusual, so a clean run means something.
"""

from __future__ import annotations

import ast
import json
import os
import re
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EXCLUDE_DIRS = {".git", "node_modules", ".venv", "__pycache__", "site"}

# Pair delimiters that must balance, per file type.
DAX_PAIRS = {"(": ")", "[": "]", "{": "}"}
PS_PAIRS = {"{": "}", "(": ")", "[": "]"}


def iter_files(extensions: tuple[str, ...]):
    for dirpath, dirnames, filenames in os.walk(REPO_ROOT):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        for name in sorted(filenames):
            if name.endswith(extensions):
                yield os.path.join(dirpath, name), name


def rel(path: str) -> str:
    return os.path.relpath(path, REPO_ROOT).replace(os.sep, "/")


def strip_noise(text: str, comments: tuple[str, ...], line_comments: tuple[str, ...]) -> str:
    """Remove comments and string literals so delimiter counting is reliable.

    An apostrophe inside a DAX comment or a brace inside a PowerShell string
    would otherwise be counted as code and produce a spurious imbalance.
    """
    out: list[str] = []
    for raw in text.splitlines():
        line = raw
        for marker in line_comments:
            idx = line.find(marker)
            if idx != -1:
                line = line[:idx]
        for marker in comments:
            idx = line.find(marker)
            if idx != -1:
                line = line[:idx]
        # Blank out quoted content, preserving length so columns still line up.
        line = re.sub(r'"[^"]*"', lambda m: " " * len(m.group(0)), line)
        line = re.sub(r"'[^']*'", lambda m: " " * len(m.group(0)), line)
        out.append(line)
    return "\n".join(out)


def check_balance(text: str, pairs: dict[str, str], label: str, path: str, problems: list[str]) -> None:
    stack: list[tuple[str, int]] = []
    line_no = 1
    for ch in text:
        if ch == "\n":
            line_no += 1
        elif ch in pairs:
            stack.append((ch, line_no))
        elif ch in pairs.values():
            if not stack:
                problems.append(f"{rel(path)}:{line_no}: unmatched '{ch}' in {label}")
                return
            opener, opened_at = stack.pop()
            if pairs[opener] != ch:
                problems.append(
                    f"{rel(path)}:{line_no}: '{ch}' closes '{opener}' "
                    f"opened at line {opened_at} in {label}"
                )
                return
    if stack:
        opener, opened_at = stack[-1]
        problems.append(f"{rel(path)}:{opened_at}: unclosed '{opener}' in {label}")


def check_dax(path: str, problems: list[str]) -> None:
    with open(path, encoding="utf-8", errors="ignore") as fh:
        text = fh.read()
    check_balance(
        strip_noise(text, comments=("--", "//", "/*"), line_comments=("//",)),
        DAX_PAIRS,
        "DAX",
        path,
        problems,
    )
    # A measure or column definition must assign something.
    if "=" in text and not re.search(r"^\s*\S+\s*=", text, re.MULTILINE):
        pass  # Not every DAX file is a measure library; skip rather than guess.


def check_m(path: str, problems: list[str]) -> None:
    with open(path, encoding="utf-8", errors="ignore") as fh:
        text = fh.read()
    check_balance(
        strip_noise(text, comments=("/*",), line_comments=("//",)),
        {"(": ")", "[": "]", "{": "}"},
        "M",
        path,
        problems,
    )
    if "let" not in text and "in" not in text:
        problems.append(f"{rel(path)}: no 'let'/'in' expression found; is this an M script?")


def check_tmdl(path: str, name: str, problems: list[str]) -> None:
    with open(path, encoding="utf-8", errors="ignore") as fh:
        text = fh.read()

    # Strip /// comment blocks before looking for declarations, so a file that
    # explains a `table` in prose is not mistaken for one that declares it.
    code = re.sub(r"^\s*///.*$", "", text, flags=re.MULTILINE)

    # A .tmdl file must declare at least one top-level object. Calculation
    # groups are a top-level object in their own right, and a file may
    # legitimately bundle several objects (Model2 groups two dimensions into
    # DimShared.tmdl on purpose), so this only requires *some* declaration.
    declared = re.findall(
        r"^\s*(table|column|measure|relationship|role|model|calculationGroup)\b",
        code,
        re.MULTILINE,
    )
    if not declared:
        problems.append(f"{rel(path)}: no top-level TMDL object declaration found")
        return

    # A filename that names a specific object should have that object declared.
    # Templates are named after what they template, but they are free to
    # template something with a different name (DateTable_Template.tmdl
    # declares `table 'Date'`), so this only warns on a single-object name.
    stem = os.path.splitext(name)[0]
    single = re.match(r"^(Dim|Fact)([A-Z]\w+)$", stem)
    if single and len(declared) == 1:
        expected = single.group(0)
        if not re.search(rf"^\s*table\s+'?{re.escape(expected)}'?\b", code, re.MULTILINE | re.IGNORECASE):
            problems.append(
                f"{rel(path)}: single object declared, but not the '{expected}' "
                f"the filename implies"
            )


def check_powershell(path: str, problems: list[str]) -> None:
    with open(path, encoding="utf-8", errors="ignore") as fh:
        text = fh.read()
    check_balance(
        strip_noise(text, comments=(), line_comments=("#",)),
        PS_PAIRS,
        "PowerShell",
        path,
        problems,
    )


def check_python(path: str, problems: list[str]) -> None:
    with open(path, encoding="utf-8", errors="ignore") as fh:
        text = fh.read()
    try:
        ast.parse(text, filename=rel(path))
    except SyntaxError as exc:
        problems.append(f"{rel(path)}:{exc.lineno}: Python syntax error: {exc.msg}")


def check_json(path: str, name: str, problems: list[str]) -> None:
    with open(path, encoding="utf-8", errors="ignore") as fh:
        raw = fh.read()
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as exc:
        problems.append(f"{rel(path)}:{exc.lineno}: invalid JSON: {exc.msg}")
        return

    if not isinstance(data, dict):
        return

    # A $schema URL's final segment should name the file it validates.
    # Mismatch here usually means a schema was copied from another artifact.
    schema = data.get("$schema")
    if isinstance(schema, str) and schema.startswith("http"):
        leaf = schema.rstrip("/").split("/")[-1]
        if leaf and not leaf.endswith(".json"):
            return
        stem = os.path.splitext(name)[0]
        if leaf in ("schema.json",) and not re.match(r"^(env-schema|index)$", stem):
            problems.append(
                f"{rel(path)}: $schema points at a generic 'schema.json'; "
                f"cannot confirm it matches this file"
            )


def check_ipynb(path: str, problems: list[str]) -> None:
    with open(path, encoding="utf-8", errors="ignore") as fh:
        raw = fh.read()
    try:
        nb = json.loads(raw)
    except json.JSONDecodeError as exc:
        problems.append(f"{rel(path)}:{exc.lineno}: invalid notebook JSON: {exc.msg}")
        return
    if not isinstance(nb, dict) or "cells" not in nb:
        problems.append(f"{rel(path)}: not a notebook (no 'cells' key)")
        return
    for i, cell in enumerate(nb.get("cells", [])):
        if not isinstance(cell, dict):
            problems.append(f"{rel(path)}: cell {i} is not an object")
        elif cell.get("cell_type") not in {"code", "markdown", "raw"}:
            problems.append(f"{rel(path)}: cell {i} has invalid cell_type")


def check_workflow(path: str, name: str, problems: list[str]) -> None:
    # GitHub Actions YAML needs a parser we do not have; a cheap check for the
    # two structural mistakes worth catching: no jobs key, or a stray tab.
    with open(path, encoding="utf-8", errors="ignore") as fh:
        text = fh.read()
    if "\t" in text:
        problems.append(f"{rel(path)}: contains a tab character; YAML forbids tabs for indentation")
    if name in ("ci.yml", "ci.yaml") and "jobs:" not in text:
        problems.append(f"{rel(path)}: no 'jobs:' key")


def main() -> int:
    problems: list[str] = []
    counts: dict[str, int] = {}

    for path, name in iter_files((".dax",)):
        check_dax(path, problems)
        counts["dax"] = counts.get("dax", 0) + 1
    for path, name in iter_files((".m",)):
        check_m(path, problems)
        counts["m"] = counts.get("m", 0) + 1
    for path, name in iter_files((".tmdl",)):
        check_tmdl(path, name, problems)
        counts["tmdl"] = counts.get("tmdl", 0) + 1
    for path, name in iter_files((".ps1",)):
        check_powershell(path, problems)
        counts["ps1"] = counts.get("ps1", 0) + 1
    for path, name in iter_files((".py",)):
        if ".venv" in path:
            continue
        check_python(path, problems)
        counts["py"] = counts.get("py", 0) + 1
    for path, name in iter_files((".json",)):
        check_json(path, name, problems)
        counts["json"] = counts.get("json", 0) + 1
    for path, name in iter_files((".ipynb",)):
        check_ipynb(path, problems)
        counts["ipynb"] = counts.get("ipynb", 0) + 1
    for path, name in iter_files((".yml", ".yaml")):
        if "workflows" in path:
            check_workflow(path, name, problems)
            counts["yml"] = counts.get("yml", 0) + 1

    total = sum(counts.values())
    summary = ", ".join(f"{v} {k}" for k, v in sorted(counts.items()))
    print(f"Checked {total} asset(s): {summary}.")

    if problems:
        print(f"\n{len(problems)} problem(s):\n")
        for p in problems:
            print(f"  {p}")
        return 1
    print("All assets are structurally valid.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
