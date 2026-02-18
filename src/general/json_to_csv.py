#!/usr/bin/env python3
"""
Convert JSON file to CSV using orjson for fast parsing.

This script reads a JSON file and converts it to CSV format.
If the JSON is an array of objects, it converts directly.
If the JSON is an object, it finds the first array of objects and converts that.

Usage: python json_to_csv.py <input.json> <output.csv>
"""

import csv
import sys
from typing import Any

import orjson


def load_json(file_path: str) -> Any:
    """
    Load JSON data from a file using orjson for performance.
    Supports both single JSON objects/arrays and JSON Lines format.

    Parameters:
        file_path (str): Path to the JSON file.

    Returns:
        Any: The parsed JSON data.

    Raises:
        SystemExit: If loading fails.
    """
    try:
        with open(file_path, "rb") as f:
            content = f.read()
            # Try to parse as single JSON first
            try:
                return orjson.loads(content)
            except orjson.JSONDecodeError as e:
                if "unexpected content after document" in str(e):
                    # Likely JSON Lines format, parse line by line
                    data = []
                    f.seek(0)  # Reset file pointer
                    for line in f:
                        line = line.strip()
                        if line:
                            data.append(orjson.loads(line))
                    return data
                else:
                    raise e
    except Exception as e:
        print(f"Error loading JSON: {e}")
        sys.exit(1)


def find_records(data: Any) -> list[dict[str, Any]] | None:
    """
    Extract the list of records from JSON data.

    If data is a list, return it.
    If data is a dict, find the first value that is a list of dicts.

    Parameters:
        data (Any): The JSON data.

    Returns:
        list[dict[str, Any]] | None: The list of records, or None if not found.
    """
    if isinstance(data, list):
        return data
    elif isinstance(data, dict):
        for value in data.values():
            if (
                isinstance(value, list)
                and value
                and isinstance(value[0], dict)
            ):
                return value
    return None


def write_csv(records: list[dict[str, Any]], output_file: str) -> None:
    """
    Write records to a CSV file.

    Parameters:
        records (list[dict[str, Any]]): The records to write.
        output_file (str): Path to the output CSV file.

    Raises:
        SystemExit: If writing fails.
    """
    if not records:
        print("No records to write")
        sys.exit(1)

    # Collect all unique fieldnames from all records
    fieldnames = set()
    for record in records:
        fieldnames.update(record.keys())
    fieldnames = sorted(fieldnames)

    try:
        with open(output_file, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            for record in records:
                writer.writerow(record)
    except Exception as e:
        print(f"Error writing CSV: {e}")
        sys.exit(1)


def main() -> None:
    """
    Main function to handle command line arguments and conversion.
    """
    if len(sys.argv) != 3:
        print("Usage: python json_to_csv.py <input.json> <output.csv>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    data = load_json(input_file)
    records = find_records(data)

    if records is None:
        print("No suitable records found in JSON")
        sys.exit(1)

    write_csv(records, output_file)
    print(f"Successfully converted {len(records)} records to {output_file}")


if __name__ == "__main__":
    main()
