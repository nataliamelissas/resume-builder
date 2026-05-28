/// ATS-safe PDF generator.
///
/// Rules enforced here (do not relax without re-running an ATS check):
///   * single column layout (no `pw.Row` for body content)
///   * PDF-14 standard fonts only — no embedded font subsets
///   * conventional section headings (Summary, Education, Experience, ...)
///   * bullets are literal "• " prefixes so text-extractors see them as text
///   * no tables / text-boxes / page headers-footers / background images
///   * hyperlinks via `pw.UrlLink` so emails and URLs are both clickable and
///     extractable as plain text
library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/resume.dart';
import '../models/settings.dart';

/// Build the PDF document for the given resume + settings.
pw.Document buildResumePdf(Resume r, Settings s) {
  final theme = _theme(s);
  final pageFormat = PdfPageFormat.letter.copyWith(
    marginLeft: s.margin.inches * PdfPageFormat.inch,
    marginRight: s.margin.inches * PdfPageFormat.inch,
    marginTop: s.margin.inches * PdfPageFormat.inch,
    marginBottom: s.margin.inches * PdfPageFormat.inch,
  );

  final doc = pw.Document(
    title: r.bio.name.isEmpty ? 'Resume' : '${r.bio.name} — Resume',
    author: r.bio.name,
    creator: 'resume-builder',
    theme: theme,
  );

  // MultiPage so content that overflows produces extra pages; the caller
  // detects pages > 1 and warns the user.
  doc.addPage(
    pw.MultiPage(
      pageFormat: pageFormat,
      build: (ctx) => _body(r, s),
    ),
  );

  return doc;
}

// ───────────────────── private helpers ─────────────────────

pw.ThemeData _theme(Settings s) {
  final size = s.fontSize.toDouble();
  final base = switch (s.font) {
    ResumeFont.helvetica => pw.Font.helvetica(),
    ResumeFont.times => pw.Font.times(),
    ResumeFont.courier => pw.Font.courier(),
  };
  final bold = switch (s.font) {
    ResumeFont.helvetica => pw.Font.helveticaBold(),
    ResumeFont.times => pw.Font.timesBold(),
    ResumeFont.courier => pw.Font.courierBold(),
  };
  final italic = switch (s.font) {
    ResumeFont.helvetica => pw.Font.helveticaOblique(),
    ResumeFont.times => pw.Font.timesItalic(),
    ResumeFont.courier => pw.Font.courierOblique(),
  };
  return pw.ThemeData.withFont(base: base, bold: bold, italic: italic).copyWith(
    defaultTextStyle: pw.TextStyle(font: base, fontSize: size),
  );
}

List<pw.Widget> _body(Resume r, Settings s) {
  final size = s.fontSize.toDouble();
  final out = <pw.Widget>[_bioHeader(r.bio, size)];

  // Iterate the user-defined order; skip disabled or empty sections.
  for (final section in s.order) {
    if (!s.isOn(section)) continue;
    final w = _renderSection(section, r, size);
    if (w != null) out.add(w);
  }
  return out;
}

pw.Widget? _renderSection(Section section, Resume r, double size) {
  switch (section) {
    case Section.summary:
      if (r.summary.trim().isEmpty) return null;
      return _section('Summary', size, [pw.Text(r.summary.trim())]);
    case Section.experience:
      if (r.experience.isEmpty) return null;
      return _section(
        'Experience',
        size,
        r.experience.map((e) => _experience(e, size)).toList(),
      );
    case Section.education:
      if (r.education.isEmpty) return null;
      return _section(
        'Education',
        size,
        r.education.map((e) => _education(e, size)).toList(),
      );
    case Section.projects:
      if (r.projects.isEmpty) return null;
      return _section(
        'Projects',
        size,
        r.projects.map((p) => _project(p, size)).toList(),
      );
    case Section.skills:
      final groups =
          r.skills.where((g) => g.items.isNotEmpty).toList();
      if (groups.isEmpty) return null;
      return _section(
        'Skills',
        size,
        groups.map((g) => _skillGroup(g)).toList(),
      );
  }
}

/// `Category: item1, item2, item3` with the category bolded. Renders as one
/// text block so wrapping is natural and ATS sees a single line per group.
pw.Widget _skillGroup(SkillGroup g) {
  final items = g.items.join(', ');
  if (g.name.isEmpty) return pw.Text(items);
  return pw.RichText(
    text: pw.TextSpan(
      children: [
        pw.TextSpan(
          text: '${g.name}: ',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.TextSpan(text: items),
      ],
    ),
  );
}

pw.Widget _bioHeader(Bio b, double size) {
  final contactBits = <String>[
    if (b.location.isNotEmpty) b.location,
    if (b.phone.isNotEmpty) b.phone,
  ];
  // pw.Container with full width + center alignment guarantees the inner
  // column spans the page and its children center horizontally.
  return pw.Container(
    width: double.infinity,
    alignment: pw.Alignment.center,
    child: pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        if (b.name.isNotEmpty)
          pw.Text(
            b.name,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: size + 6,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        if (b.headline.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text(
              b.headline,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: size),
            ),
          ),
        pw.SizedBox(height: 2),
        pw.Wrap(
          alignment: pw.WrapAlignment.center,
          spacing: 8,
          runSpacing: 2,
          children: [
            for (final bit in contactBits) pw.Text(bit),
            if (b.email.isNotEmpty)
              pw.UrlLink(
                destination: 'mailto:${b.email}',
                child: pw.Text(b.email),
              ),
            for (final link in b.links)
              if (link.url.isNotEmpty)
                pw.UrlLink(
                  destination: link.url,
                  child:
                      pw.Text(link.label.isEmpty ? link.url : link.label),
                ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _section(String title, double size, List<pw.Widget> children) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: size + 2,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Divider(height: 4, thickness: 0.5),
        ...children.map(
          (c) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: c,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _experience(ExperienceItem e, double size) {
  final dates = _dates(e.start, e.end);
  final headline = [e.title, e.company].where((s) => s.isNotEmpty).join(' - ');
  final meta = [e.location, dates].where((s) => s.isNotEmpty).join(' | ');
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (headline.isNotEmpty)
        pw.Text(
          headline,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      if (meta.isNotEmpty)
        pw.Text(meta, style: pw.TextStyle(fontSize: size - 1)),
      ..._bullets(e.bullets),
    ],
  );
}

pw.Widget _education(EducationItem e, double size) {
  final dates = _dates(e.start, e.end);
  final headline = [e.degree, e.school].where((s) => s.isNotEmpty).join(' - ');
  final meta = [e.location, dates].where((s) => s.isNotEmpty).join(' | ');
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (headline.isNotEmpty)
        pw.Text(
          headline,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      if (meta.isNotEmpty)
        pw.Text(meta, style: pw.TextStyle(fontSize: size - 1)),
      if (e.details.trim().isNotEmpty) pw.Text(e.details.trim()),
    ],
  );
}

pw.Widget _project(ProjectItem p, double size) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (p.name.isNotEmpty)
        p.url.isEmpty
            ? pw.Text(
                p.name,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              )
            : pw.UrlLink(
                destination: p.url,
                child: pw.Text(
                  p.name,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
      ..._bullets(p.bullets),
    ],
  );
}

List<pw.Widget> _bullets(List<String> items) => [
      for (final b in items)
        if (b.trim().isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 8, top: 1),
            // ASCII "- " keeps bullets in the extracted text stream and
            // avoids fonts that don't carry U+2022.
            child: pw.Text('- ${b.trim()}'),
          ),
    ];

String _dates(String start, String end) {
  if (start.isEmpty && end.isEmpty) return '';
  if (start.isEmpty) return end;
  if (end.isEmpty) return '$start - Present';
  return '$start - $end';
}
