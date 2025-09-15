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
    if article:
        return str(article)
    return html


import sys
from pathlib import Path

import requests
from bs4 import BeautifulSoup
from markdownify import markdownify as md


def fetch_html(url: str) -> str:
    """
    Fetch the HTML content of a given URL.

    Args:
            url (str): The URL to fetch.

    Returns:
            str: The HTML content as a string.
    """
    response = requests.get(url, timeout=15)
    response.raise_for_status()
    return response.text


def remove_footer(html: str) -> str:
    """
    Remove the footer section from the HTML, if present.

    Args:
        html (str): HTML content.

    Returns:
        str: HTML content without the footer.
    """
    soup = BeautifulSoup(html, "html.parser")
    # Remove <footer> tags
    for footer in soup.find_all("footer"):
        footer.decompose()
    # Remove common footer classes/ids
    for selector in [
        '[id*="footer"]',
        '[class*="footer"]',
        '[id*="Footer"]',
        '[class*="Footer"]',
        '[id*="site-footer"]',
        '[class*="site-footer"]',
        '[id*="page-footer"]',
        '[class*="page-footer"]',
    ]:
        for tag in soup.select(selector):
            tag.decompose()
    return str(soup)


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


def save_markdown(markdown: str, output_path: Path) -> None:
    """
    Save Markdown content to a file.

    Args:
            markdown (str): Markdown content.
            output_path (Path): Path to the output file.
    """
    output_path.write_text(markdown, encoding="utf-8")


def main():
    """
    Main function to fetch a website, convert to Markdown, and save to file.
    Usage: python scrap.py <url> [output_file]
    """
    if len(sys.argv) < 2:
        print("Usage: python scrap.py <url> [output_file]")
        sys.exit(1)
    url = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    html = fetch_html(url)
    markdown = html_to_markdown(html)
    from urllib.parse import urlparse

    parsed = urlparse(url)
    domain = parsed.netloc
    if not output_file:
        # Default: use last part of URL as filename
        name = url.rstrip("/").split("/")[-1] or "index"
        output_dir = Path(domain)
        output_dir.mkdir(parents=True, exist_ok=True)
        output_file = output_dir / f"{name}.md"
    else:
        output_file = Path(output_file)
    save_markdown(markdown, output_file)
    print(f"Saved markdown to {output_file}")


if __name__ == "__main__":
    main()
