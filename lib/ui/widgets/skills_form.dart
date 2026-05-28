/// Skills entered as a comma-separated list. Stored as a list so the PDF
/// renders them with consistent separators regardless of input punctuation.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/resume_store.dart';
import '_form_kit.dart';

class SkillsForm extends StatelessWidget {
  const SkillsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ResumeStore>();
    return FormCard(
      title: 'Skills',
      child: PlainField(
        label: 'Comma-separated (e.g. Python, Dart, AWS, SQL)',
        initial: store.resume.skills.join(', '),
        maxLines: 2,
        onChanged: (v) {
          final list = v
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
          store.updateResume((r) => r.copyWith(skills: list));
        },
      ),
    );
  }
}
