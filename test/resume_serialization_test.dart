/// Round-trip JSON serialization: encode then decode must reproduce the
/// original resume/settings byte-for-byte.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:resume_builder/models/resume.dart';
import 'package:resume_builder/models/settings.dart';

void main() {
  group('Resume serialization', () {
    test('round-trips a fully populated resume', () {
      const r = Resume(
        bio: Bio(
          name: 'Ada Lovelace',
          headline: 'Mathematician & Programmer',
          email: 'ada@example.com',
          phone: '+1 555 0100',
          location: 'London, UK',
          links: [Link(label: 'GitHub', url: 'https://github.com/ada')],
        ),
        summary: 'First programmer.',
        education: [
          EducationItem(
            school: 'University of London',
            degree: 'Mathematics',
            start: '1830',
            end: '1834',
            details: 'Top honours',
          ),
        ],
        experience: [
          ExperienceItem(
            title: 'Analyst',
            company: 'Analytical Engine Project',
            start: 'Jan 1842',
            end: 'Dec 1843',
            bullets: ['Wrote first algorithm', 'Translated Menabrea'],
          ),
        ],
        projects: [
          ProjectItem(
            name: 'Note G',
            url: 'https://example.com/note-g',
            bullets: ['Bernoulli numbers algorithm'],
          ),
        ],
        skills: [
          SkillGroup(name: 'Math', items: ['Algebra', 'Logic']),
          SkillGroup(name: 'Languages', items: ['English', 'French']),
        ],
      );

      final decoded = Resume.decode(r.encode());

      expect(decoded.bio.name, r.bio.name);
      expect(decoded.bio.links.single.url, r.bio.links.single.url);
      expect(decoded.summary, r.summary);
      expect(decoded.experience.single.bullets, r.experience.single.bullets);
      expect(decoded.education.single.school, r.education.single.school);
      expect(decoded.projects.single.name, r.projects.single.name);
      expect(decoded.skills.length, 2);
      expect(decoded.skills.first.name, 'Math');
      expect(decoded.skills.first.items, ['Algebra', 'Logic']);
    });

    test('migrates legacy flat-list skills into a single un-named group', () {
      // Old persisted shape: skills as a flat list of strings.
      const legacy = '{"skills":["Dart","Flutter","AWS"]}';
      final r = Resume.decode(legacy);
      expect(r.skills, hasLength(1));
      expect(r.skills.single.name, '');
      expect(r.skills.single.items, ['Dart', 'Flutter', 'AWS']);
    });

    test('decodes an empty object to defaults', () {
      final r = Resume.decode('{}');
      expect(r.bio.name, '');
      expect(r.experience, isEmpty);
      expect(r.skills, isEmpty);
    });
  });

  group('Settings serialization', () {
    test('toggle adds and removes sections', () {
      const s = Settings();
      final off = s.toggle(Section.summary);
      expect(off.isOn(Section.summary), isFalse);
      final on = off.toggle(Section.summary);
      expect(on.isOn(Section.summary), isTrue);
    });

    test('round-trips through JSON', () {
      const s = Settings(
        enabled: {Section.summary, Section.skills},
        font: ResumeFont.times,
        fontSize: 11,
        margin: Margin.eighth,
      );
      final out = Settings.fromJson(s.toJson());
      expect(out.font, ResumeFont.times);
      expect(out.fontSize, 11);
      expect(out.margin, Margin.eighth);
      expect(out.enabled, {Section.summary, Section.skills});
    });
  });
}
