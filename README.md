# Resume Builder

Minimalist Flutter Web app that builds a **one-page, ATS-friendly resume PDF**.

## Why this exists

Most "build a resume" sites export an image-PDF — pretty for humans, unreadable
to applicant tracking systems (ATS). This app generates PDFs with real,
extractable text, using PDF-14 standard fonts and a single-column layout that
non-AI resume parsers handle reliably.

## Features

- Toggle sections on/off: bio, summary, experience, education, projects, skills.
- One-page layout with a loud overflow warning if content spills over.
- Font choice: Helvetica / Times / Courier (all PDF-standard, no embedding).
- Font size: 8–14 pt.
- Margin: 0.25" or 0.125".
- Auto-saves to browser `localStorage`. Import/export the resume as JSON.
- No backend, no analytics, strict Content Security Policy.

## Run

```bash
flutter pub get
flutter run -d chrome
```

## Test

```bash
flutter test          # JSON round-trip + PDF generation + page-count
flutter analyze       # static analysis, must be clean
```

## Build

```bash
flutter build web --release
# output: build/web/  -> deploy as static assets
```

## Verify ATS-extractability (optional, requires Python)

After exporting a PDF from the app:

```bash
pip install pdfminer.six
python scripts/verify_pdf_text.py path/to/resume.pdf
```

The script prints the extracted text and which standard section headings
(`Summary`, `Experience`, `Education`, `Projects`, `Skills`) were detected.
A real ATS sees what the script sees.

## Layout

```
lib/
├── models/      # Resume, Settings data classes (JSON serializable)
├── storage/     # localStorage + import/export JSON
├── pdf/         # ATS-safe PDF generator (the core)
├── state/       # ChangeNotifier store with debounced auto-save
├── ui/          # editor page, toolbar, form widgets, live preview
└── main.dart    # app entry point
```

## ATS rules enforced in the PDF generator

1. Single column.
2. PDF-14 standard fonts only.
3. Conventional section headings.
4. ASCII glyphs only (no smart quotes, no em-dashes, no `•`).
5. Bullets as literal `- ` prefixes so text-extractors keep them.
6. Hyperlinks via `pw.UrlLink` so emails/URLs are both clickable and
   extractable as plain text.
7. No tables, text boxes, page headers/footers, or background images.

Don't relax these without re-running an ATS check.
