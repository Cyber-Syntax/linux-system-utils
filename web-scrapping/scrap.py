# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "beautifulsoup4>=4.14.3",
#     "certifi>=2026.1.4",
#     "charset-normalizer>=3.4.4",
#     "idna>=3.11",
#     "markdownify>=1.2.2",
#     "requests>=2.32.5",
#     "six>=1.17.0",
#     "soupsieve>=2.8.1",
#     "typing-extensions>=4.15.0",
#     "urllib3>=2.6.3",
# ]
# ///
"""A simple web scraper that fetches a webpage, extracts the <article> tag,
converts it to Markdown, and saves it to a file."""

import sys
from pathlib import Path
from typing import Optional

import requests
from bs4 import BeautifulSoup
from markdownify import markdownify as md


def extract_article(html: str) -> str:
    """
    Extract the <article> tag and its content from the HTML.

    Args:
        html (str): HTML content.

    Returns:
        str: HTML content containing only the <article> tag, or the original HTML if not found.
    """
    soup = BeautifulSoup(html, "html.parser")
    article = soup.find("article")
    if article is not None:
        return str(article)
    return html


def parse_args(argv: list[str]) -> tuple[str, Optional[str]]:
    """
    Parse command-line arguments for URL and optional output file.

    Args:
        argv (list[str]): List of command-line arguments.

    Returns:
        tuple[str, Optional[str]]: URL and optional output file path.
    """
    if len(argv) < 2:
        print("Usage: python scrap.py <url> [output_file]", file=sys.stderr)
        sys.exit(1)
    url = argv[1]
    output_file_arg = argv[2] if len(argv) > 2 else None
    return url, output_file_arg


def get_output_path(url: str, output_file_arg: Optional[str]) -> Path:
    """
    Determine the output file path based on the URL and optional output file argument.

    Args:
        url (str): The URL being scraped.
        output_file_arg (Optional[str]): Optional output file path provided by user.

    Returns:
        Path: The resolved output file path.
    """
    from urllib.parse import urlparse

    if output_file_arg is not None:
        return Path(output_file_arg)
    parsed = urlparse(url)
    domain = parsed.netloc if parsed.netloc else "output"
    name = url.rstrip("/").split("/")[-1] or "index"
    output_dir = Path(domain)
    output_dir.mkdir(parents=True, exist_ok=True)
    return output_dir / f"{name}.md"


def save_markdown(markdown: str, output_path: Path) -> None:
    """
    Save Markdown content to a file.

    Args:
        markdown (str): Markdown content.
        output_path (Path): Path to the output file.
    """
    try:
        output_path.write_text(markdown, encoding="utf-8")
    except OSError as exc:
        print(f"Error writing to file '{output_path}': {exc}", file=sys.stderr)
        sys.exit(3)


def html_to_markdown(html: str) -> str:
    """
    Convert only the <article> tag from HTML content to Markdown format.

    Args:
        html (str): HTML content.

    Returns:
        str: Markdown representation of the <article> tag.
    """
    article_html = extract_article(html)
    return md(article_html, heading_style="ATX")


def fetch_html(url: str) -> str:
    """
    Fetch the HTML content of a given URL.

    Args:
        url (str): The URL to fetch.

    Returns:
        str: The HTML content as a string.

    Raises:
        requests.RequestException: If the request fails.
    """
    try:
        response = requests.get(url, timeout=15)
        response.raise_for_status()
        return response.text
    except requests.RequestException as exc:
        print(f"Error fetching URL '{url}': {exc}", file=sys.stderr)
        sys.exit(2)


def main() -> None:
    """
    Main function to orchestrate fetching, converting, and saving Markdown.
    """
    url, output_file_arg = parse_args(sys.argv)
    html = fetch_html(url)
    markdown = html_to_markdown(html)
    output_path = get_output_path(url, output_file_arg)
    save_markdown(markdown, output_path)
    print(f"Saved markdown to {output_path}")


if __name__ == "__main__":
    main()
