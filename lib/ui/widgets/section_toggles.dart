/// Chips that toggle optional resume sections on/off.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/settings.dart';
import '../../state/resume_store.dart';

class SectionToggles extends StatelessWidget {
  const SectionToggles({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ResumeStore>();
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final s in Section.values)
          FilterChip(
            label: Text(_label(s)),
            selected: store.settings.isOn(s),
            onSelected: (_) => store.updateSettings((x) => x.toggle(s)),
          ),
      ],
    );
  }

  String _label(Section s) => switch (s) {
        Section.summary => 'Summary',
        Section.education => 'Education',
        Section.experience => 'Experience',
        Section.projects => 'Projects',
        Section.skills => 'Skills',
      };
}
