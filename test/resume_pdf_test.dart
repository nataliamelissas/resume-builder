/// Verifies the PDF generator produces a valid PDF and that small resumes
/// fit on a single page. Page count is the one invariant that must hold for
/// the "one-page-only" requirement.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:resume_builder/models/resume.dart';
import 'package:resume_builder/models/settings.dart';
import 'package:resume_builder/pdf/resume_pdf.dart';

void main() {
  test('minimal resume produces a valid PDF starting with %PDF', () async {
    const r = Resume(
      bio: Bio(name: 'Test User', email: 't@example.com'),
      summary: 'Short summary.',
    );
    final doc = buildResumePdf(r, const Settings());
    final bytes = await doc.save();
    expect(bytes.length, greaterThan(100));
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
  });

  test('a small resume fits on one page', () async {
    const r = Resume(
      bio: Bio(name: 'Test User', email: 't@example.com'),
      summary: 'Concise summary.',
      experience: [
        ExperienceItem(
          title: 'Engineer',
          company: 'Acme',
          start: 'Jan 2024',
          end: 'Present',
          bullets: ['Shipped X', 'Improved Y'],
        ),
      ],
      skills: ['Dart', 'Flutter'],
    );
    final doc = buildResumePdf(r, const Settings());
    await doc.save();
    expect(doc.document.pdfPageList.pages.length, 1);
  });

  test('a huge resume overflows past one page', () async {
    final bullets = List<String>.generate(
      40,
      (i) => 'Bullet $i: a fairly long sentence about responsibility $i.',
    );
    final r = Resume(
      bio: const Bio(name: 'Test User'),
      experience: List.generate(
        8,
        (i) => ExperienceItem(
          title: 'Role $i',
          company: 'Company $i',
          start: 'Jan 2020',
          end: 'Dec 2023',
          bullets: bullets,
        ),
      ),
    );
    final doc = buildResumePdf(r, const Settings());
    await doc.save();
    expect(doc.document.pdfPageList.pages.length, greaterThan(1));
  });
}
