#!/usr/bin/env python3
"""Check that external URLs in the repository still resolve.

``check_links.py`` covers relative links and deliberately skips external URLs,
because doing that needs network access. This script does the network half, and
is therefore run on a schedule rather than on every push: a rate-limited or
briefly unavailable host should not fail a build.

What it checks: an HTTP request that returns a definite answer. 2xx and 3xx
pass, 401/403 pass (the resource exists; the request is unauthorised), 429
passes (rate limited, not missing), and everything else fails.

What it cannot check: whether a page still says what the link claimed when it
was written. Only a human re-reading the page catches that, which is what the
``last_verified`` date and the What's New register are for.

Usage:
    python .github/scripts/check_external_links.py                 # all links
    python .github/scripts/check_external_links.py --limit 40      # cap requests
    python .github/scripts/check_external_links.py --file README.md
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EXCLUDE_DIRS = {".git", "node_modules", ".venv", "__pycache__", "site"}

FENCE_RE = re.compile(r"^\s{0,3}(`{3,}|~{3,})")
H1_RE = re.compile(r"^#\s+")
LINK_RE = re.compile(r"\[[^\]]*\]\(\s*(https?://[^\s)]+)\s*\)")

# Hosts that rate-limit aggressively, block HEAD, or are known to fail for
# reasons unrelated to whether the link in the docs is valid.
SKIP_HOSTS = {
    "twitter.com", "x.com", "linkedin.com", "facebook.com", "instagram.com",
    "reddit.com", "youtu.be", "pinterest.com", "tiktok.com",
}

# 401/403 mean the resource exists but the request is not authorised; 429 means
# rate limited. Neither indicates a dead link.
PASS_STATUSES = {200, 201, 202, 204, 301, 302, 303, 307, 308, 401, 403, 405, 429}


def mask_code(text: str) -> str:
    """Blank fenced blocks so example links are not treated as real ones."""
    out: list[str] = []
    fence: str | None = None
    for line in text.splitlines(keepends=True):
        m = FENCE_RE.match(line)
        if fence is None:
            if m:
                fence = m.group(1)
                out.append(" " * len(line.rstrip("\n")))
                continue
            out.append(line)
        else:
            stripped = line.strip()
            if stripped.startswith(fence[0] * len(fence)) and set(stripped) == {fence[0]}:
                fence = None
            out.append(" " * len(line.rstrip("\n")))
    return "".join(out)


def collect(target: str | None) -> dict[str, list[str]]:
    """Map URL to the files that reference it."""
    urls: dict[str, list[str]] = defaultdict(list)
    if target:
        paths = [os.path.join(REPO_ROOT, target)]
    else:
        paths = []
        for dirpath, dirnames, filenames in os.walk(REPO_ROOT):
            dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
            for name in sorted(filenames):
                if name.endswith(".md"):
                    paths.append(os.path.join(dirpath, name))

    for path in paths:
        with open(path, encoding="utf-8", errors="ignore") as fh:
            text = fh.read()
        rel_path = os.path.relpath(path, REPO_ROOT).replace(os.sep, "/")
        for url in LINK_RE.findall(mask_code(text)):
            url = url.rstrip(".,;")
            host = re.sub(r"^https?://([^/]+).*$", r"\1", url).lower()
            if host in SKIP_HOSTS:
                continue
            urls[url].append(rel_path)
    return urls


def check_url(url: str) -> tuple[str, int, str]:
    """Return (url, status, note). status 0 means the request failed outright.

    Retries transient failures. Hosts that serve large pages - YouTube in
    particular - routinely time out or reset mid-response under concurrency
    without being broken, so a single failure is not evidence of a dead link.
    """
    last_note = ""
    for attempt in range(3):
        try:
            result = subprocess.run(
                [
                    "curl", "-sS", "-o", "/dev/null",
                    "-L",                       # follow redirects
                    "--max-time", "25",
                    "--connect-timeout", "10",
                    "-w", "%{http_code}",
                    "-A", "Mozilla/5.0 (compatible; PowerBI-Hub link checker)",
                    url,
                ],
                capture_output=True,
                text=True,
                timeout=45,
            )
        except subprocess.TimeoutExpired:
            last_note = "timed out"
            continue

        if result.returncode != 0:
            err = (result.stderr or "").strip().splitlines()
            last_note = err[-1] if err else f"curl exit {result.returncode}"
            continue

        try:
            code = int((result.stdout or "0").strip()[-3:])
        except ValueError:
            return url, 0, f"unparseable status {result.stdout!r}"

        # A definitive HTTP answer, including 404, is not retried.
        return url, code, ""

    return url, 0, last_note


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--file", help="check a single file instead of the whole repo")
    parser.add_argument("--limit", type=int, default=0, help="cap the number of URLs checked")
    parser.add_argument("--jobs", type=int, default=8, help="concurrent requests")
    args = parser.parse_args()

    urls = collect(args.file)
    if not urls:
        print("No external URLs to check.")
        return 0

    if args.limit and len(urls) > args.limit:
        print(f"{len(urls)} external URLs found; checking the first {args.limit}.")
        urls = dict(list(urls.items())[: args.limit])
    else:
        print(f"{len(urls)} external URLs found. Checking...")

    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = list(pool.map(check_url, urls.keys()))

    # A request that never completed is not the same as a 404. Report the two
    # separately so a flaky network is not read as a content problem.
    hard = [(u, c, n) for u, c, n in results if c not in PASS_STATUSES and c != 0]
    soft = [(u, c, n) for u, c, n in results if c == 0]
    ok = len(results) - len(hard) - len(soft)
    print(f"{ok} reachable, {len(hard)} broken, {len(soft)} unreachable (network).")

    if soft:
        print("\nUnreachable after 3 attempts - likely transient, not a dead link:")
        for url, _, note in sorted(soft):
            print(f"  [{note}] {url}")

    if hard:
        print(f"\n{len(hard)} broken URL(s):\n")
        for url, code, _ in sorted(hard, key=lambda r: str(r[1])):
            where = ", ".join(urls[url][:3])
            print(f"  [HTTP {code}] {url}")
            print(f"      referenced by: {where}")
        return 1

    print("All external URLs resolve.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
