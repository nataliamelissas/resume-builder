# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter run -d chrome          # dev server
flutter test                   # all tests
flutter analyze                # must be clean before committing
flutter build web --release --base-href "/resume-builder/"
```

## Architecture

Flutter Web SPA — no backend. State via `provider` (`ResumeStore`), PDF via `pdf` package.

```
lib/
  models/      # Resume, Settings — immutable, JSON-serializable, copyWith pattern
  state/       # ResumeStore (ChangeNotifier) — debounced localStorage auto-save, overflow flag
  storage/     # LocalStorage — read/write JSON to browser localStorage + import/export
  pdf/         # resume_pdf.dart — builds pw.Document; ATS rules enforced here
  ui/          # editor_page.dart (layout), toolbar.dart, preview_pane.dart, widgets/*_form.dart
```

Data flow: UI calls `store.updateResume(f)` → store debounces save → `renderPdf(store)` re-renders PDF bytes → `PreviewPane` displays via `Printing`.

## ATS rules — do not relax without re-running ATS check

- Single column, PDF-14 standard fonts only (Helvetica/Times/Courier)
- ASCII glyphs only — NO smart quotes, em-dashes, bullet `•`; use `- ` prefix for bullets
- No tables, text boxes, headers/footers, background images
- Hyperlinks via `pw.UrlLink`

## Linter

Strict mode (`strict-casts`, `strict-inference`, `strict-raw-types`). Rules enforced: `prefer_single_quotes`, `prefer_const_constructors`, `require_trailing_commas`.
