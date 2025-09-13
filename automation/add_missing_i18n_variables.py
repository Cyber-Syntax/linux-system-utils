#!/usr/bin/env python3
"""
This script converted from add-missing-i18n-variables.js to Python.

This script was created for superproductivity but would be work for most of the typescript projects
that use i18n JSON files.

This script updates all language translation files (i18n JSON files) in the project.
It ensures that every language file has all the keys present in the English file (en.json),
and keeps the same order of keys as in en.json. Existing translations are preserved.

Folder structure: tools/add_missing_i18n_variables.py
Usage: python tools/add_missing_i18n_variables.py
"""

import json
import os
import sys
from collections import OrderedDict

# Step 1: Locate the i18n directory relative to this script
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
I18N_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "../src/assets/i18n"))
EN_PATH = os.path.join(I18N_DIR, "en.json")


# Step 2: Merge function (recursive, preserves order and existing translations)
def merge_in_order(en_obj, lang_obj):
    if not isinstance(en_obj, dict):
        return lang_obj
    result = OrderedDict()
    for key in en_obj:
        en_val = en_obj[key]
        lang_val = lang_obj.get(key) if lang_obj else None
        if isinstance(en_val, dict):
            result[key] = merge_in_order(
                en_val, lang_val if isinstance(lang_val, dict) else {}
            )
        else:
            result[key] = lang_val if lang_val is not None else en_val
    return result


# Step 3: Check for required files and directories
if not os.path.exists(I18N_DIR):
    print("i18n directory not found at src/assets/i18n/", file=sys.stderr)
    sys.exit(1)
if not os.path.exists(EN_PATH):
    print("en.json not found in src/assets/i18n/", file=sys.stderr)
    sys.exit(1)

# Step 4: Read en.json as reference
with open(EN_PATH, "r", encoding="utf-8") as f:
    en = json.load(f, object_pairs_hook=OrderedDict)

# Step 5: Find all language files except en.json
files = sorted(
    [f for f in os.listdir(I18N_DIR) if f.endswith(".json") and f != "en.json"]
)
print(f"Found {len(files)} language files to update:")
for f in files:
    print(f"  - {f}")
print()

updated_files = 0
errors = 0

# Step 6: Process each language file
for file in files:
    lang_path = os.path.join(I18N_DIR, file)
    try:
        if os.path.exists(lang_path):
            with open(lang_path, "r", encoding="utf-8") as f:
                content = f.read().strip()
                try:
                    lang_data = (
                        json.loads(content, object_pairs_hook=OrderedDict)
                        if content
                        else {}
                    )
                except json.JSONDecodeError as jde:
                    print(f"✗ Error decoding JSON in {file}: {jde}", file=sys.stderr)
                    errors += 1
                    continue
        else:
            lang_data = {}
        merged = merge_in_order(en, lang_data)
        with open(lang_path, "w", encoding="utf-8") as f:
            json.dump(merged, f, ensure_ascii=False, indent=2)
        print(f"✓ Updated {file}")
        updated_files += 1
    except Exception as e:
        print(f"✗ Error processing {file}: {e}", file=sys.stderr)
        errors += 1

print("\nSummary:")
print(f"  - Updated files: {updated_files}")
print(f"  - Errors: {errors}")
print(f"  - Total files processed: {len(files)}")
if errors == 0:
    print(
        "\nAll language files updated successfully with missing keys in the same order as en.json."
    )
else:
    print("\nSome files had errors. Please check the output above.")
    sys.exit(1)
