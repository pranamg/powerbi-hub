#!/usr/bin/env python3
"""Add YAML frontmatter to every Markdown file in the repository.

Frontmatter is what makes the hub navigable: ``build_index.py`` reads it to
generate ``Documentation/Topic_Index.md``, and the CI freshness check reads
``last_verified`` to flag content that has gone stale.

Metadata is derived from the file's path (see ``RULES`` and ``OVERRIDES``) so
that the tags for a folder stay consistent as files are added to it. Run this
after adding files; it is idempotent and never touches a file that already
has frontmatter.

Usage:
    python .github/scripts/add_frontmatter.py            # add missing frontmatter
    python .github/scripts/add_frontmatter.py --dry-run  # report, change nothing
    python .github/scripts/add_frontmatter.py --check    # exit 1 if any file lacks it
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from datetime import date

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EXCLUDE_DIRS = {".git", "node_modules", ".venv", "__pycache__", "site"}
TODAY = date.today().isoformat()

FENCE_RE = re.compile(r"^\s{0,3}(`{3,}|~{3,})")
H1_RE = re.compile(r"^#\s+(.+?)\s*$")

# Paths that are repo infrastructure rather than hub content. They are still
# indexed (contributors need to find CONTRIBUTING) but tagged differently.
INFRA = {
    "AGENTS.md",
    "Contributions/CONTRIBUTING.md",
    "Contributions/CodeOfConduct.md",
    "Contributions/README.md",
    "README.md",
}

# Explicit per-file overrides. Only needed where the path rules cannot infer
# something meaningful. Values are (tags, audience, difficulty).
OVERRIDES: dict[str, tuple[list[str], list[str], str]] = {
    "README.md": (["hub", "navigation"], ["all"], "beginner"),
    "AGENTS.md": (["meta", "contributing"], ["all"], "reference"),
    "Contributions/CONTRIBUTING.md": (["contributing", "meta"], ["all"], "beginner"),
    "Contributions/CodeOfConduct.md": (["contributing", "meta"], ["all"], "reference"),
    "Contributions/README.md": (["contributing", "meta"], ["all"], "reference"),
    "Documentation/CHECKLIST.md": (["meta", "onboarding"], ["all"], "beginner"),
    "Documentation/IMPLEMENTATION_PLAN.md": (["meta"], ["all"], "reference"),
    "References/Articles.md": (["references", "learning"], ["all"], "reference"),
    "References/BlogPosts.md": (["references", "learning"], ["all"], "reference"),
    "References/Books.md": (["references", "learning"], ["all"], "reference"),
    "References/GitHubRepos.md": (["references", "tooling"], ["developer"], "reference"),
    "References/OtherResources.md": (["references", "learning"], ["all"], "reference"),
    "References/YouTube/Channels.md": (["references", "learning"], ["all"], "reference"),
    "References/YouTube/Playlists.md": (["references", "learning"], ["all"], "reference"),
    "References/README.md": (["references"], ["all"], "reference"),
    "PromptLibrary/DAXPrompts.md": (["prompts", "dax", "ai"], ["developer"], "intermediate"),
    "PromptLibrary/ETLPrompts.md": (["prompts", "power-query", "ai"], ["developer"], "intermediate"),
    "PromptLibrary/MCPPrompts.md": (["prompts", "mcp", "ai"], ["developer"], "intermediate"),
    "PromptLibrary/PowerQueryPrompts.md": (["prompts", "power-query", "ai"], ["developer"], "intermediate"),
    "PromptLibrary/VisualsPrompts.md": (["prompts", "visuals", "ai"], ["report-author"], "intermediate"),
    "PromptLibrary/GeneralPrompts.md": (["prompts", "ai"], ["all"], "beginner"),
    "PromptLibrary/README.md": (["prompts", "ai"], ["all"], "beginner"),
}

# Path-prefix rules, checked in order; first match wins. Each entry is
# (prefix, tags, audience, difficulty).
RULES: list[tuple[str, list[str], list[str], str]] = [
    ("AgenticDevelopment/AgentsAndSkills", ["agentic", "ai", "tooling"], ["developer"], "intermediate"),
    ("AgenticDevelopment/MCPTools", ["agentic", "mcp", "ai"], ["developer"], "advanced"),
    ("AgenticDevelopment/CustomCommands", ["agentic", "automation", "tooling"], ["developer"], "advanced"),
    ("AgenticDevelopment/Workflows", ["agentic", "automation", "tooling"], ["developer"], "advanced"),
    ("AgenticDevelopment/Hooks", ["agentic", "ci-cd", "automation"], ["developer"], "advanced"),
    ("AgenticDevelopment", ["agentic", "ai"], ["developer"], "intermediate"),

    ("Data/Constants/DateTable", ["modeling", "dax", "dates"], ["model-author"], "intermediate"),
    ("Data/Constants/ColorTable", ["visuals", "design"], ["report-author"], "beginner"),
    ("Data/Constants", ["modeling", "constants"], ["model-author"], "beginner"),
    ("Data/DataModels", ["modeling", "tmdl", "reference"], ["model-author"], "advanced"),
    ("Data/DataSources", ["data-connections", "power-query"], ["developer"], "intermediate"),
    ("Data/Datasets", ["modeling", "deployment"], ["model-author"], "intermediate"),
    ("Data/ETL", ["power-query", "etl"], ["developer"], "intermediate"),
    ("Data", ["data", "modeling"], ["developer"], "intermediate"),

    ("Queries/DAX/CalculationGroups", ["dax", "advanced", "modeling"], ["model-author"], "advanced"),
    ("Queries/DAX/FieldParameters", ["dax", "advanced", "visuals"], ["model-author"], "advanced"),
    ("Queries/DAX/UserDefinedFunctions", ["dax", "advanced"], ["model-author"], "advanced"),
    ("Queries/DAX/CalculatedColumns", ["dax", "modeling"], ["model-author"], "intermediate"),
    ("Queries/DAX/BestPractices", ["dax", "best-practices"], ["model-author"], "intermediate"),
    ("Queries/DAX", ["dax"], ["model-author"], "intermediate"),
    ("Queries/PowerQuery", ["power-query", "etl"], ["developer"], "intermediate"),
    ("Queries", ["dax", "power-query"], ["model-author"], "beginner"),

    ("Optimization", ["performance", "optimization"], ["model-author"], "advanced"),
    ("Governance", ["governance", "security"], ["bi-admin"], "advanced"),
    ("Monitoring", ["monitoring", "operations"], ["bi-admin"], "intermediate"),
    ("Deployment", ["deployment", "ci-cd"], ["developer"], "advanced"),
    ("Collaboration", ["collaboration", "workspaces"], ["bi-admin"], "intermediate"),
    ("Integrations/MCP", ["mcp", "agentic", "ai"], ["developer"], "advanced"),
    ("Integrations/Fabric", ["fabric", "data-connections"], ["developer"], "advanced"),
    ("Integrations", ["integration"], ["developer"], "intermediate"),

    ("Visuals/CustomVisuals", ["visuals", "development"], ["developer"], "advanced"),
    ("Visuals/RVisuals", ["visuals", "r"], ["developer"], "advanced"),
    ("Visuals/PythonVisuals", ["visuals", "python"], ["developer"], "advanced"),
    ("Visuals/Layouts", ["visuals", "design"], ["report-author"], "intermediate"),
    ("Visuals", ["visuals"], ["report-author"], "beginner"),

    ("Design/Themes", ["design", "themes"], ["report-author"], "intermediate"),
    ("Design/AtomicElements", ["design", "visuals"], ["report-author"], "intermediate"),
    ("Design/BackgroundImages", ["design", "assets"], ["report-author"], "beginner"),
    ("Design", ["design"], ["report-author"], "beginner"),

    ("Reports", ["reports", "design"], ["report-author"], "intermediate"),
    ("Dashboards", ["dashboards", "design"], ["report-author"], "intermediate"),

    ("Scripts/TMDL", ["tmdl", "modeling", "templates"], ["model-author"], "advanced"),
    ("Scripts/CSharp", ["automation", "csharp"], ["developer"], "advanced"),
    ("Scripts/PowerShell", ["automation", "powershell", "devops"], ["developer"], "advanced"),
    ("Scripts/JupyterNotebooks", ["automation", "python", "rest-api"], ["developer"], "advanced"),
    ("Scripts/AzureAutomation", ["automation", "devops"], ["developer"], "advanced"),
    ("Scripts/Macros", ["automation", "office"], ["developer"], "intermediate"),
    ("Scripts", ["automation", "scripts"], ["developer"], "intermediate"),

    ("TipsAndTricks", ["tips"], ["all"], "intermediate"),

    ("Documentation/UserGuides/Copilot", ["copilot", "ai", "reports"], ["report-author"], "intermediate"),
    ("Documentation/UserGuides/TMDLView", ["tmdl", "modeling", "tooling"], ["model-author"], "intermediate"),
    ("Documentation/UserGuides/DAXQueryView", ["dax", "tooling"], ["model-author"], "beginner"),
    ("Documentation/UserGuides/FabricGitIntegration", ["fabric", "git", "ci-cd"], ["developer"], "advanced"),
    ("Documentation/UserGuides/TeamCollaboration", ["collaboration", "workspaces"], ["bi-admin"], "intermediate"),
    ("Documentation/UserGuides", ["documentation"], ["all"], "beginner"),
    ("Documentation/ArchitectureDiagrams", ["architecture", "documentation"], ["all"], "intermediate"),
    ("Documentation/DesignDocuments", ["architecture", "documentation"], ["all"], "intermediate"),
    ("Documentation/Setup", ["setup", "tooling"], ["all"], "beginner"),
    ("Documentation", ["documentation"], ["all"], "beginner"),
]

DEFAULT_META: tuple[list[str], list[str], str] = (["documentation"], ["all"], "beginner")


def humanize(stem: str) -> str:
    """Turn a filename into a readable title.

    ``DAXQueryView`` -> ``DAXQueryView`` (acronym-heavy names are left alone
    rather than mangled), ``user-guide`` -> ``User Guide``.
    """
    if "-" in stem or "_" in stem:
        parts = re.split(r"[-_]+", stem)
        return " ".join(p[:1].upper() + p[1:] for p in parts if p)
    return stem


def extract_title(text: str, rel: str) -> str:
    """Prefer the document's own H1; fall back to the filename."""
    in_fence = False
    fence: str | None = None
    for line in text.splitlines():
        m = FENCE_RE.match(line)
        if in_fence:
            if m and m.group(1)[0] == fence[0] and len(m.group(1)) >= len(fence):
                in_fence = False
            continue
        if m:
            fence = m.group(1)
            in_fence = True
            continue
        m = H1_RE.match(line)
        if m:
            return m.group(1).strip()
    return humanize(os.path.splitext(os.path.basename(rel))[0])


def meta_for(rel: str) -> tuple[list[str], list[str], str]:
    if rel in OVERRIDES:
        return OVERRIDES[rel]
    for prefix, tags, audience, difficulty in RULES:
        if rel.startswith(prefix):
            return tags, audience, difficulty
    return DEFAULT_META


def has_frontmatter(text: str) -> bool:
    return text.startswith("---\n") or text.startswith("---\r\n")


def render(meta: dict[str, object], body: str) -> str:
    lines = ["---"]
    for key in ("title", "tags", "audience", "difficulty", "last_verified"):
        value = meta[key]
        if isinstance(value, list):
            lines.append(f"{key}: [{', '.join(str(v) for v in value)}]")
        else:
            lines.append(f"{key}: {value}")
    lines.append("---")
    return "\n".join(lines) + "\n\n" + body.lstrip("\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="report changes, write nothing")
    parser.add_argument("--check", action="store_true", help="exit 1 if any file lacks frontmatter")
    args = parser.parse_args()

    changed: list[str] = []
    missing: list[str] = []

    for dirpath, dirnames, filenames in os.walk(REPO_ROOT):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        for name in sorted(filenames):
            if not name.endswith(".md"):
                continue
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, REPO_ROOT).replace(os.sep, "/")
            with open(path, encoding="utf-8") as fh:
                text = fh.read()

            if has_frontmatter(text):
                continue
            if args.check:
                missing.append(rel)
                continue

            tags, audience, difficulty = meta_for(rel)
            meta = {
                "title": extract_title(text, rel),
                "tags": tags,
                "audience": audience,
                "difficulty": difficulty,
                "last_verified": TODAY,
            }
            if not args.dry_run:
                with open(path, "w", encoding="utf-8") as fh:
                    fh.write(render(meta, text))
            changed.append(rel)

    if args.check:
        if missing:
            print(f"{len(missing)} file(s) missing frontmatter:")
            for rel in missing:
                print(f"  {rel}")
            return 1
        print("All Markdown files have frontmatter.")
        return 0

    verb = "Would add frontmatter to" if args.dry_run else "Added frontmatter to"
    print(f"{verb} {len(changed)} file(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
