#!/usr/bin/env python3
"""Validate Markdown frontmatter against the hub's schema.

Presence of a frontmatter block is not enough: a typo in a tag, an unknown
difficulty, or a malformed date silently breaks filtering in the generated
index. This checks values, not just existence.

Exit codes: 0 clean, 1 problems found.
"""

from __future__ import annotations

import difflib
import os
import re
import sys
from datetime import date

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EXCLUDE_DIRS = {".git", "node_modules", ".venv", "__pycache__", "site"}

REQUIRED = ("title", "tags", "audience", "difficulty", "last_verified")

VALID_TAGS = {
    "administration", "advanced", "agentic", "ai", "architecture", "assets", "automation", "best-practices",
    "ci-cd", "collaboration", "community", "constants", "contributing", "copilot", "csharp",
    "dashboards", "data", "data-connections", "dates", "deployment", "design", "development",
    "devops", "dax", "documentation", "etl", "fabric", "git", "governance", "hub", "integration",
    "learning", "mcp", "meta", "modeling", "monitoring", "navigation", "office", "onboarding",
    "operations", "optimization", "pbir", "pbip", "performance", "power-query", "powershell",
    "prompts", "python", "r", "reference", "references", "reports", "rest-api", "scripts",
    "security", "setup", "templates", "themes", "tmdl", "tooling", "tips", "visuals",
    "workspaces",
}
VALID_AUDIENCE = {"all", "bi-admin", "data-engineer", "developer", "model-author", "report-author"}
VALID_DIFFICULTY = {"beginner", "intermediate", "advanced", "reference"}

# Paths whose frontmatter follows a different schema (GitHub issue templates).
EXEMPT = {
    ".github/ISSUE_TEMPLATE/bug_report.md",
    ".github/ISSUE_TEMPLATE/feature_request.md",
}

DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")


def parse(text: str) -> tuple[dict[str, str], str] | None:
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---\n", 3)
    if end == -1:
        return None
    data: dict[str, str] = {}
    for line in text[4:end].splitlines():
        if ":" in line and not line.lstrip().startswith("#"):
            key, _, value = line.partition(":")
            data[key.strip()] = value.strip()
    return data, text[end + 5 :]


def check_value_list(value: str) -> list[str]:
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        return [v.strip() for v in inner.split(",") if v.strip()]
    return [value] if value else []


def main() -> int:
    problems: list[str] = []
    checked = 0

    for dirpath, dirnames, filenames in os.walk(REPO_ROOT):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        for name in sorted(filenames):
            if not name.endswith(".md"):
                continue
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, REPO_ROOT).replace(os.sep, "/")
            if rel in EXEMPT:
                continue
            checked += 1

            with open(path, encoding="utf-8") as fh:
                text = fh.read()

            parsed = parse(text)
            if parsed is None:
                problems.append(f"{rel}: missing or unterminated frontmatter")
                continue
            meta, body = parsed

            for key in REQUIRED:
                if key not in meta:
                    problems.append(f"{rel}: missing '{key}'")

            if "difficulty" in meta and meta["difficulty"] not in VALID_DIFFICULTY:
                # Suggest a near match: typos like 'beginnter' are otherwise
                # just as opaque as a deliberately wrong value.
                guess = difflib.get_close_matches(
                    meta["difficulty"], VALID_DIFFICULTY, n=1, cutoff=0.7
                )
                hint = f" Did you mean '{guess[0]}'?" if guess else ""
                problems.append(
                    f"{rel}: invalid difficulty '{meta['difficulty']}' "
                    f"(allowed: {', '.join(sorted(VALID_DIFFICULTY))}).{hint}"
                )

            if "last_verified" in meta:
                value = meta["last_verified"]
                if not DATE_RE.match(value):
                    problems.append(f"{rel}: last_verified '{value}' is not YYYY-MM-DD")
                else:
                    try:
                        parsed_date = date.fromisoformat(value)
                    except ValueError:
                        problems.append(f"{rel}: last_verified '{value}' is not a real date")
                    else:
                        if parsed_date > date.today():
                            problems.append(f"{rel}: last_verified '{value}' is in the future")

            for tag in check_value_list(meta.get("tags", "")):
                if tag not in VALID_TAGS:
                    problems.append(f"{rel}: unknown tag '{tag}'")

            for aud in check_value_list(meta.get("audience", "")):
                if aud not in VALID_AUDIENCE:
                    problems.append(f"{rel}: unknown audience '{aud}'")

            # The document must still start with its H1 after the frontmatter.
            if not body.lstrip().startswith("# "):
                problems.append(f"{rel}: no H1 heading after frontmatter")

    print(f"Checked frontmatter on {checked} file(s).")
    if problems:
        print(f"\n{len(problems)} problem(s):\n")
        for p in problems:
            print(f"  {p}")
        return 1
    print("All frontmatter is valid.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
