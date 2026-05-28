#!/usr/bin/env python3
"""Verify that a resume PDF is ATS-extractable.

Reads the PDF with pdfminer.six (a regex-based, non-AI parser similar to what
many ATS use) and prints:
  * the page count (must be 1),
  * the raw extracted text,
  * which standard section headings were found.

Usage:
    pip install pdfminer.six
    python scripts/verify_pdf_text.py path/to/resume.pdf
"""

from __future__ import annotations

import sys
from pathlib import Path

try:
    from pdfminer.high_level import extract_text
    from pdfminer.pdfpage import PDFPage
except ImportError:
    sys.exit("pdfminer.six is required. Install with: pip install pdfminer.six")

EXPECTED_HEADINGS = ("Summary", "Experience", "Education", "Projects", "Skills")


def main(path: Path) -> int:
    if not path.exists():
        print(f"File not found: {path}", file=sys.stderr)
        return 2

    with path.open("rb") as f:
        pages = sum(1 for _ in PDFPage.get_pages(f))

    text = extract_text(str(path))
    found = [h for h in EXPECTED_HEADINGS if h in text]
    missing = [h for h in EXPECTED_HEADINGS if h not in text]

    print(f"Pages: {pages}  (one-page resume requires 1)")
    print(f"Characters extracted: {len(text)}")
    print(f"Headings found: {found or '(none)'}")
    if missing:
        print(f"Headings missing: {missing}")
    print("\n--- extracted text ---\n")
    print(text)

    return 0 if pages == 1 and len(text) > 0 else 1


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("Usage: verify_pdf_text.py <pdf>")
    sys.exit(main(Path(sys.argv[1])))
