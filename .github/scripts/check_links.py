#!/usr/bin/env python3
"""Validate relative Markdown links across the repository.

Exits non-zero if any relative link points at a path that does not exist,
so broken cross-references are caught in CI instead of in review.

Absolute URLs (http/https), mailto: and tel: links, and pure fragment
references are skipped: the first two cannot be validated without network
access, and fragments are checked separately when a fragment is present on a
relative target.
"""

from __future__ import annotations

import os
import re
import sys
import unicodedata

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EXCLUDE_DIRS = {".git", "node_modules", ".venv", "__pycache__"}

# [label](target) - label may contain escaped brackets, which is rare here.
LINK_RE = re.compile(r"\[([^\]]*)\]\(\s*([^)\s]+)(?:\s+\"[^\"]*\")?\s*\)")
FENCE_OPEN_RE = re.compile(r"^\s{0,3}(`{3,}|~{3,})")
EXTERNAL_SCHEMES = ("http://", "https://", "mailto:", "tel:", "ftp://", "#")


def mask_code(text: str) -> str:
    """Blank out code spans and fenced blocks, preserving line structure.

    Markdown examples such as `` `[My UDF](parameter)` `` are not links, so
    they must not be collected. A simple regex is not enough: a run of
    backticks appearing in prose ("use triple backticks (```) ...") desyncs
    naive pairing and silently unmasks the rest of the file. This walks the
    text instead, tracking fence state and matching inline spans by backtick
    run length, per the CommonMark rule.
    """
    out: list[str] = []
    fence: str | None = None

    for line in text.splitlines(keepends=True):
        m = FENCE_OPEN_RE.match(line)
        if fence is None:
            if m and m.group(1)[0] in "`~":
                fence = m.group(1)
                out.append(" " * len(line.rstrip("\n")))
                continue
            out.append(mask_inline_code(line))
        else:
            # Inside a fenced block: only a matching closing fence ends it.
            stripped = line.strip()
            if stripped.startswith(fence[0] * len(fence)) and set(stripped) == {fence[0]}:
                fence = None
            out.append(" " * len(line.rstrip("\n")))
    return "".join(out)


def mask_inline_code(line: str) -> str:
    """Blank out inline code spans in a single line of prose."""
    out: list[str] = []
    i = 0
    n = len(line)
    while i < n:
        ch = line[i]
        if ch != "`":
            out.append(ch)
            i += 1
            continue
        # Measure the opening backtick run.
        start = i
        while i < n and line[i] == "`":
            i += 1
        width = i - start
        # A span closes on a run of exactly the same length.
        close = line.find("`" * width, i)
        if close == -1:
            out.append(" " * width)  # unmatched run; treat as literal
            continue
        out.append(" " * (close + width - start))
        i = close + width
    return "".join(out)


def slugify(heading: str) -> str:
    """Approximate GitHub's heading-anchor algorithm."""
    heading = re.sub(r"`([^`]*)`", r"\1", heading)
    heading = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", heading)
    heading = re.sub(r"[*_~]", "", heading)
    heading = heading.strip().lower()
    # Drop everything that is not alphanumeric, space, or hyphen.
    heading = "".join(c for c in heading if c.isalnum() or c in " -_")
    heading = heading.replace(" ", "-")
    return unicodedata.normalize("NFKD", heading)


def collect_fragments(path: str) -> set[str]:
    """Return the set of in-page anchors a Markdown file defines."""
    try:
        with open(path, encoding="utf-8", errors="ignore") as fh:
            text = fh.read()
    except OSError:
        return set()
    return {slugify(m.group(1)) for m in re.finditer(r"^#{1,6}\s+(.*?)\s*$", text, re.MULTILINE)}


def iter_markdown_files():
    for dirpath, dirnames, filenames in os.walk(REPO_ROOT):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        for name in sorted(filenames):
            if name.endswith(".md"):
                yield os.path.join(dirpath, name)


def main() -> int:
    fragment_cache: dict[str, set[str]] = {}
    broken: list[tuple[str, int, str, str]] = []
    checked = 0
    files = 0

    for path in iter_markdown_files():
        files += 1
        with open(path, encoding="utf-8", errors="ignore") as fh:
            lines = fh.readlines()

        # mask_code keeps one output line per input line, so lineno stays exact.
        body = mask_code("".join(lines))

        for lineno, line in enumerate(body.splitlines(), 1):
            for label, raw_target in LINK_RE.findall(line):
                target = raw_target.strip().strip("<>")
                if not target or target.startswith(EXTERNAL_SCHEMES):
                    continue
                checked += 1

                path_part, _, fragment = target.partition("#")
                path_part = path_part.split("?", 1)[0]

                if path_part:
                    resolved = os.path.normpath(os.path.join(os.path.dirname(path), path_part))
                    if not os.path.exists(resolved):
                        broken.append((os.path.relpath(path, REPO_ROOT), lineno, label, target))
                        continue
                    if fragment and resolved.endswith(".md"):
                        if resolved not in fragment_cache:
                            fragment_cache[resolved] = collect_fragments(resolved)
                        if fragment.lower() not in fragment_cache[resolved]:
                            broken.append(
                                (os.path.relpath(path, REPO_ROOT), lineno, label, target)
                            )
                elif fragment:
                    if path not in fragment_cache:
                        fragment_cache[path] = collect_fragments(path)
                    if fragment.lower() not in fragment_cache[path]:
                        broken.append((os.path.relpath(path, REPO_ROOT), lineno, label, target))

    print(f"Checked {checked} relative links across {files} Markdown files.")
    if broken:
        print(f"\n{len(broken)} broken link(s):\n")
        for rel, lineno, label, target in broken:
            print(f"  {rel}:{lineno}  [{label}]({target})")
        return 1

    print("All relative links resolve.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
