import os
import re

base_path = r"C:\Users\Administrator\Downloads\Lyxal_Solution-main\lyxal_ui"
core_path = os.path.join(base_path, "crates", "core", "lyx-core-leptos")

def fix_cargo(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    dir_name = os.path.basename(os.path.dirname(file_path))
    
    # Fix empty name
    new_content = re.sub(r'name = ""', f'name = "{dir_name}"', content)
    
    # Fix missing name if [package] is present but name is missing
    if '[package]' in new_content and 'name =' not in new_content:
        new_content = new_content.replace('[package]', f'[package]\nname = "{dir_name}"')
    
    # Fix version = "*" in package section
    # Use a multiline regex to match [package] block
    package_match = re.search(r'\[package\].*?version = "\*"', new_content, re.DOTALL)
    if package_match:
        # Only replace if it's within the first 10 lines or so of [package]
        lines = new_content.splitlines()
        for i, line in enumerate(lines):
            if '[package]' in line:
                for j in range(i, min(i+10, len(lines))):
                    if 'version = "*"' in lines[j]:
                        lines[j] = 'version = "0.8.0"'
                        break
        new_content = '\n'.join(lines)
    
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed {file_path}")

for root, dirs, files in os.walk(core_path):
    if 'Cargo.toml' in files:
        fix_cargo(os.path.join(root, 'Cargo.toml'))
