/// Two-pane editor: form on the left, live PDF preview on the right.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';
import '../state/resume_store.dart';
import 'preview_pane.dart';
import 'widgets/bio_form.dart';
import 'widgets/education_form.dart';
import 'widgets/experience_form.dart';
import 'widgets/projects_form.dart';
import 'widgets/section_toggles.dart';
import 'widgets/skills_form.dart';
import 'widgets/summary_form.dart';
import 'widgets/toolbar.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ResumeStore>();
    final s = store.settings;
    return Scaffold(
      appBar: const EditorToolbar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: editor form (scrollable).
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionToggles(),
                  const SizedBox(height: 16),
                  const BioForm(),
                  if (s.isOn(Section.summary)) ...[
                    const SizedBox(height: 16),
                    const SummaryForm(),
                  ],
                  if (s.isOn(Section.experience)) ...[
                    const SizedBox(height: 16),
                    const ExperienceForm(),
                  ],
                  if (s.isOn(Section.education)) ...[
                    const SizedBox(height: 16),
                    const EducationForm(),
                  ],
                  if (s.isOn(Section.projects)) ...[
                    const SizedBox(height: 16),
                    const ProjectsForm(),
                  ],
                  if (s.isOn(Section.skills)) ...[
                    const SizedBox(height: 16),
                    const SkillsForm(),
                  ],
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          // Right: PDF preview.
          const Expanded(child: PreviewPane()),
        ],
      ),
    );
  }
}
