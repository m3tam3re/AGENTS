#!/usr/bin/env python3
"""
Audit [[wikilinks]] in an Obsidian vault.

Scans all .md files for [[wikilink]] references and reports:
- Broken links (target file doesn't exist)
- Ambiguous links (multiple files match the basename)
- Code-example false positives ([[wikilinks]] inside backticks)

Usage:
    python3 audit-wikilinks.py [VAULT_PATH]

If VAULT_PATH is omitted, defaults to ~/m3ta-brain.

Exit codes:
    0 = no broken links (ambiguous/code-examples are warnings only)
    1 = broken links found
"""
import sys
import os
import re
from collections import defaultdict

VAULT = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/m3ta-brain")

# Collect all .md files
md_files = []
for root, dirs, files in os.walk(VAULT):
    if '.git' in root:
        continue
    for f in files:
        if f.endswith('.md'):
            full_path = os.path.join(root, f)
            rel_path = os.path.relpath(full_path, VAULT)
            md_files.append((rel_path, full_path))

# Build indices
basename_index = defaultdict(list)
fullpath_set = set()
for rel_path, full_path in md_files:
    basename = os.path.basename(rel_path).replace('.md', '')
    basename_index[basename].append(rel_path)
    fullpath_set.add(rel_path)

print(f"Total .md files: {len(md_files)}")

# Extract and validate wikilinks
# Pattern matches [[target]], [[target|alias]], [[target#heading]], [[target#heading|alias]]
wikilink_pattern = re.compile(r'\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|[^\]]*)?\]\]')
# Pattern to detect if a wikilink is inside backtick code
backtick_pattern = re.compile(r'`[^`]*\[\[[^\]]*\]\][^`]*`')

broken_links = []
ambiguous_links = []
code_example_links = []
valid_links = 0
total_links = 0

for rel_path, full_path in md_files:
    with open(full_path, 'r') as f:
        lines = f.readlines()
    for i, line in enumerate(lines, 1):
        for match in wikilink_pattern.finditer(line):
            target = match.group(1).strip()
            if target.startswith('./'):
                target = target[2:]
            total_links += 1

            # Check if this link is inside backtick code on the same line
            # (simplified: checks if backticks surround the match on this line)
            start = match.start()
            prefix = line[:start]
            backtick_count_before = prefix.count('`')
            in_code = backtick_count_before % 2 == 1

            if '/' in target:
                target_path = target + '.md' if not target.endswith('.md') else target
                if target_path in fullpath_set:
                    valid_links += 1
                elif in_code:
                    code_example_links.append((rel_path, i, match.group(0), target))
                else:
                    broken_links.append((rel_path, i, match.group(0), target))
            else:
                matches = basename_index.get(target, [])
                if len(matches) == 0:
                    if in_code:
                        code_example_links.append((rel_path, i, match.group(0), target))
                    else:
                        broken_links.append((rel_path, i, match.group(0), target))
                elif len(matches) > 1:
                    ambiguous_links.append((rel_path, i, match.group(0), target, matches))
                else:
                    valid_links += 1

print(f"Total wikilinks: {total_links}")
print(f"Valid: {valid_links}")
print(f"Broken: {len(broken_links)}")
print(f"Ambiguous: {len(ambiguous_links)}")
print(f"Code-example (in backticks, OK): {len(code_example_links)}")

if broken_links:
    print("\n=== BROKEN LINKS ===")
    by_target = defaultdict(list)
    for src, line, raw, target in broken_links:
        by_target[target].append((src, line))
    for target in sorted(by_target.keys()):
        sources = by_target[target]
        print(f"\n  '{target}' — {len(sources)} ref(s):")
        for src, line in sources[:5]:
            print(f"    {src}:{line}")

if ambiguous_links:
    print("\n=== AMBIGUOUS LINKS ===")
    for src, line, raw, target, matches in ambiguous_links:
        print(f"  '{target}' in {src}:{line} → {matches}")

# Exit code
if broken_links:
    print("\n⚠️  Broken links found — fix before committing.")
    sys.exit(1)
else:
    print("\n✅ No broken links.")
    sys.exit(0)
