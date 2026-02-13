#!/usr/bin/env python3
# This script written for superproductivity sync.md extension
# markdown files to remove HTML-like comments (<!-- comment -->).

import os
import re


# Function to remove HTML-like comments from a file
def remove_html_comments_from_file(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        content = file.read()

    # Regular expression to match HTML comments
    cleaned_content = re.sub(r"<!--.*?-->", "", content, flags=re.DOTALL)

    with open(file_path, "w", encoding="utf-8") as file:
        file.write(cleaned_content)


# Function to process multiple files in a directory
def process_markdown_files(directory_path):
    # Find all markdown files in the directory
    for filename in os.listdir(directory_path):
        if filename.endswith(".md"):  # You can modify this to match other formats
            file_path = os.path.join(directory_path, filename)
            remove_html_comments_from_file(file_path)
            print(f"Processed {file_path}")


# Example usage
directory = "./files"  # Folder containing the markdown files
process_markdown_files(directory)
