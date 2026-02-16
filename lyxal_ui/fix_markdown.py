"""
Strip corrupted markdown artifacts from .rs files.
Only removes:
  - Lines that are exactly "```rust" or "```" (with optional whitespace)
  - Lines starting with "### C:\" (aggregator comments)
Does NOT touch any actual Rust code.
"""
import os
import re

SRC_DIR = r"C:\Users\Administrator\Downloads\Lyxal_Solution-main\lyxal_ui\crates\ui-kits\lyx-ui-leptonic\leptonic\src"

PATTERNS = [
    re.compile(r'^\s*```rust\s*$'),
    re.compile(r'^\s*```\s*$'),
    re.compile(r'^###\s+C:\\'),
]

fixed_count = 0
for root, dirs, files in os.walk(SRC_DIR):
    for fname in files:
        if not fname.endswith('.rs'):
            continue
        fpath = os.path.join(root, fname)
        with open(fpath, 'r', encoding='utf-8', errors='replace') as f:
            lines = f.readlines()

        new_lines = []
        changed = False
        for line in lines:
            stripped = line.rstrip('\r\n')
            if any(p.match(stripped) for p in PATTERNS):
                changed = True
                continue
            new_lines.append(line)

        if changed:
            # Remove leading blank lines
            while new_lines and new_lines[0].strip() == '':
                new_lines.pop(0)
            # Remove trailing blank lines
            while new_lines and new_lines[-1].strip() == '':
                new_lines.pop()
            new_lines.append('\n')

            with open(fpath, 'w', encoding='utf-8', newline='\r\n') as f:
                f.writelines(new_lines)
            fixed_count += 1
            print(f"Fixed: {os.path.relpath(fpath, SRC_DIR)}")

print(f"\nTotal files cleaned: {fixed_count}")
