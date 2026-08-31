import os
import glob
import re

migrations_dir = r"C:\Users\HP\Desktop\Lyxal_Solution\lyxal_booking\calrs-main\migrations"
sql_files = sorted(glob.glob(os.path.join(migrations_dir, "*.sql")))

tables = {}

for fpath in sql_files:
    fname = os.path.basename(fpath)
    with open(fpath, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Find CREATE TABLE
    create_tables = re.findall(r"CREATE\ TABLE\ (?:IF\ NOT\ EXISTS\ )?([a-zA-Z0-9_]+)\s*\((.*?)\);", content, re.DOTALL | re.IGNORECASE)
    for tname, body in create_tables:
        if tname not in tables:
            tables[tname] = {"columns": {}, "created_in": fname}
        
        # parse lines inside table definition
        lines = body.split(",")
        # handle multiline column definitions
        col_defs = []
        current_def = ""
        for line in lines:
            line_str = line.strip()
            if not line_str:
                continue
            if any(line_str.upper().startswith(k) for k in ["PRIMARY KEY", "FOREIGN KEY", "UNIQUE", "CHECK", "CONSTRAINT"]):
                continue
            col_defs.append(line_str)
        
        for col_def in col_defs:
            parts = col_def.split()
            if parts:
                col_name = parts[0].strip('`"[]')
                col_type = parts[1] if len(parts) > 1 else "TEXT"
                tables[tname]["columns"][col_name] = col_type

    # Find ALTER TABLE ADD COLUMN
    alters = re.findall(r"ALTER\ TABLE\ ([a-zA-Z0-9_]+)\ ADD\ (?:COLUMN\ )?([a-zA-Z0-9_]+)\ (.*?)(?:;|$)", content, re.IGNORECASE)
    for tname, col_name, col_type in alters:
        if tname in tables:
            tables[tname]["columns"][col_name] = col_type.strip()
        else:
            tables[tname] = {"columns": {col_name: col_type.strip()}, "created_in": fname}

print(f"Total tables found: {len(tables)}")
for tname, data in sorted(tables.items()):
    print(f"\nTABLE: {tname} (created in {data['created_in']})")
    for col, ctype in sorted(data["columns"].items()):
        print(f"  - {col}: {ctype}")
