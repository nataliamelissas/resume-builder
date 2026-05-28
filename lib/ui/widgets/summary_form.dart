import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/resume_store.dart';
import '_form_kit.dart';

class SummaryForm extends StatelessWidget {
  const SummaryForm({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ResumeStore>();
    return FormCard(
      title: 'Summary',
      child: PlainField(
        label: 'Professional summary (2–4 lines)',
        initial: store.resume.summary,
        maxLines: 4,
        onChanged: (v) => store.updateResume((r) => r.copyWith(summary: v)),
      ),
    );
  }
}
