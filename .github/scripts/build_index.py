#!/usr/bin/env python3
"""Generate ``Documentation/Topic_Index.md`` from Markdown frontmatter.

The index is the hub's front door: it lists every document once, grouped so
that a reader can either browse alphabetically or filter by tag, audience, or
difficulty. Because it is generated, it cannot drift out of sync with the
tree the way a hand-maintained list does.

Run after adding or re-tagging content:

    python .github/scripts/build_index.py            # rewrite the index
    python .github/scripts/build_index.py --check    # exit 1 if stale (for CI)
"""

from __future__ import annotations

import argparse
import os
import posixpath
import sys
from collections import Counter, defaultdict

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUTPUT = os.path.join(REPO_ROOT, "Documentation", "Topic_Index.md")
EXCLUDE_DIRS = {".git", "node_modules", ".venv", "__pycache__", "site"}

# GitHub issue templates use GitHub's own frontmatter schema, not ours.
EXCLUDE_FILES = {
    ".github/ISSUE_TEMPLATE/bug_report.md",
    ".github/ISSUE_TEMPLATE/feature_request.md",
}

# The index itself and the root README are entry points, not index rows.
EXCLUDE_FILES.add("Documentation/Topic_Index.md")

# Folders with no README.md. These are repository plumbing rather than browsable
# content, so their section heading links to the folder itself.
NO_README = {".github"}

AUDIENCE_ORDER = ["all", "report-author", "model-author", "developer", "bi-admin"]
DIFFICULTY_ORDER = ["beginner", "intermediate", "advanced", "reference"]

AUDIENCE_LABEL = {
    "all": "Everyone",
    "report-author": "Report authors",
    "model-author": "Model authors",
    "developer": "Developers",
    "bi-admin": "BI admins",
}


def parse_frontmatter(text: str) -> dict[str, object] | None:
    """Return the simple key/value frontmatter block, or None if absent.

    Deliberately minimal: this repo's frontmatter is flat scalar or inline
    list values, so a full YAML dependency would be unjustified.
    """
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---\n", 3)
    if end == -1:
        return None
    block = text[4:end]
    data: dict[str, object] = {}
    for line in block.splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if ":" not in line:
            continue
        key, _, value = line.partition(":")
        value = value.strip()
        if value.startswith("[") and value.endswith("]"):
            inner = value[1:-1].strip()
            data[key.strip()] = [v.strip() for v in inner.split(",") if v.strip()]
        else:
            data[key.strip()] = value
    return data


def collect() -> list[dict[str, object]]:
    docs: list[dict[str, object]] = []
    for dirpath, dirnames, filenames in os.walk(REPO_ROOT):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        for name in sorted(filenames):
            if not name.endswith(".md"):
                continue
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, REPO_ROOT).replace(os.sep, "/")
            if rel in EXCLUDE_FILES:
                continue
            with open(path, encoding="utf-8") as fh:
                text = fh.read()
            meta = parse_frontmatter(text)
            if not meta or "title" not in meta:
                continue
            docs.append(
                {
                    "path": rel,
                    "title": str(meta["title"]),
                    "tags": meta.get("tags", []),
                    "audience": meta.get("audience", []),
                    "difficulty": str(meta.get("difficulty", "beginner")),
                    "last_verified": str(meta.get("last_verified", "")),
                }
            )
    # Group by folder (root first) so each folder renders as one section.
    return sorted(docs, key=lambda d: (folder_sort_key(top_of(d)), d["path"].lower()))


def link(rel: str, from_dir: str) -> str:
    """Render a repo-relative path as a link relative to the index file.

    The index lives in ``Documentation/``, so a repo-root path like
    ``Queries/DAX/README.md`` must be emitted as ``../Queries/DAX/README.md``
    to resolve from the file's own location.
    """
    trimmed = rel[: -len(".md")] if rel.endswith(".md") else rel
    return posixpath.relpath(trimmed, from_dir)


def top_of(doc: dict[str, object]) -> str:
    """Top-level folder for a document; ``.`` for repository-root files."""
    path = str(doc["path"])
    return path.split("/")[0] if "/" in path else "."


def folder_sort_key(folder: str) -> tuple[int, str]:
    """Sort the repository root first, then folders alphabetically."""
    return (0 if folder == "." else 1, folder.lower())


def anchor_for(folder: str) -> str:
    """Match the heading anchor GitHub generates for a folder section."""
    return folder.lower().replace(".", "").replace("/", "")


def render(docs: list[dict[str, object]], from_dir: str) -> str:
    out: list[str] = []
    out.append("---")
    out.append("title: Topic Index")
    out.append("tags: [meta, navigation]")
    out.append("audience: [all]")
    out.append("difficulty: reference")
    out.append("last_verified: 2026-09-29")
    out.append("---")
    out.append("")
    out.append("# Topic Index")
    out.append("")
    out.append("<!-- GENERATED FILE - do not edit by hand. -->")
    out.append("<!-- Regenerate: python .github/scripts/build_index.py -->")
    out.append("")
    out.append(
        f"Every document in the hub ({len(docs)} files). Browse the "
        "[table of contents](#table-of-contents) below, the "
        "[learning paths](./LearningPaths/), or filter by "
        "[audience](#by-audience) and [tag](#by-tag)."
    )
    out.append("")
    out.append(
        "> Generated file. To add or re-tag content, edit the source Markdown "
        "and run `python .github/scripts/build_index.py`. CI fails if this "
        "file is out of date."
    )
    out.append("")

    # Table of contents, one row per top-level folder.
    by_folder: dict[str, int] = Counter()
    for doc in docs:
        by_folder[top_of(doc)] += 1
    out.append("## Table of Contents")
    out.append("")
    out.append("| Folder | Docs | Topic |")
    out.append("|-------|-----:|-------|")
    for folder in sorted(by_folder, key=folder_sort_key):
        if folder == ".":
            out.append(f"| *(repository root)* | {by_folder[folder]} | [Jump](#repository-root) |")
        elif folder in NO_README:
            # Repo plumbing (.github/) has no README; link the folder itself.
            out.append(
                f"| [{folder}/]({link(folder, from_dir)}/) | {by_folder[folder]} "
                f"| [Jump](#{anchor_for(folder)}) |"
            )
        else:
            out.append(
                f"| [{folder}/]({link(folder + '/README.md', from_dir)}) | {by_folder[folder]} "
                f"| [Jump](#{anchor_for(folder)}) |"
            )
    out.append("")

    # Full alphabetical listing.
    out.append("## All Topics (A-Z)")
    out.append("")
    current = None
    for doc in docs:
        top = top_of(doc)
        if top != current:
            # A blank line before each heading keeps MD022 satisfied now and
            # after any regeneration.
            if out and out[-1] != "":
                out.append("")
            current = top
            if top == ".":
                out.append("### Repository root")
            elif top in NO_README:
                out.append(f"### {top}/")
            else:
                out.append(f"### [{top}]({link(top + '/README.md', from_dir)})")
            out.append("")
            out.append("| Topic | Tags | Audience | Level | Verified |")
            out.append("|-------|------|----------|-------|----------|")
        tags = ", ".join(f"`{t}`" for t in doc["tags"])  # type: ignore[union-attr]
        audience = ", ".join(doc["audience"])  # type: ignore[arg-type]
        out.append(
            f"| [{doc['title']}]({link(str(doc['path']), from_dir)}) | {tags} | {audience} "
            f"| {doc['difficulty']} | {doc['last_verified']} |"
        )
    out.append("")

    # Audience filter.
    out.append("## By Audience")
    out.append("")
    out.append("| Audience | Docs |")
    out.append("|----------|-----:|")
    for aud in AUDIENCE_ORDER:
        n = sum(1 for d in docs if aud in d["audience"])  # type: ignore[operator]
        out.append(f"| {AUDIENCE_LABEL[aud]} (`{aud}`) | {n} |")
    out.append("")

    # Tag index.
    tag_counts: Counter[str] = Counter()
    tag_docs: dict[str, list[dict[str, object]]] = defaultdict(list)
    for doc in docs:
        for tag in doc["tags"]:  # type: ignore[union-attr]
            tag_counts[tag] += 1
            tag_docs[tag].append(doc)
    out.append("## By Tag")
    out.append("")
    out.append("| Tag | Docs |")
    out.append("|-----|-----:|")
    for tag, n in sorted(tag_counts.items(), key=lambda kv: (-kv[1], kv[0])):
        out.append(f"| `{tag}` | {n} |")
    out.append("")

    # Difficulty summary.
    out.append("## By Difficulty")
    out.append("")
    out.append("| Level | Docs |")
    out.append("|-------|-----:|")
    for level in DIFFICULTY_ORDER:
        n = sum(1 for d in docs if d["difficulty"] == level)
        out.append(f"| {level} | {n} |")
    out.append("")

    # Collapse any trailing blank lines so the file ends with exactly one
    # newline (MD012 / MD047).
    while out and out[-1] == "":
        out.pop()
    return "\n".join(out) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="exit 1 if the index is stale")
    args = parser.parse_args()

    docs = collect()
    from_dir = os.path.relpath(os.path.dirname(OUTPUT), REPO_ROOT).replace(os.sep, "/")
    content = render(docs, from_dir)
    rel = os.path.relpath(OUTPUT, REPO_ROOT).replace(os.sep, "/")

    if args.check:
        if not os.path.exists(OUTPUT):
            print(f"{rel} does not exist. Run: python .github/scripts/build_index.py")
            return 1
        with open(OUTPUT, encoding="utf-8") as fh:
            existing = fh.read()
        if existing != content:
            print(f"{rel} is out of date. Run: python .github/scripts/build_index.py")
            return 1
        print(f"{rel} is up to date ({len(docs)} documents).")
        return 0

    with open(OUTPUT, "w", encoding="utf-8") as fh:
        fh.write(content)
    print(f"Wrote {rel} ({len(docs)} documents).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
