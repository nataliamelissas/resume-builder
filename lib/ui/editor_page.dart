/// Two-pane editor: form on the left, live PDF preview on the right.
///
/// The bio header is pinned at the top. The remaining sections live in a
/// ReorderableListView whose drag handle on each card lets the user choose
/// the section order that the PDF generator will follow.
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
    final enabledInOrder = s.order.where(s.isOn).toList();

    return Scaffold(
      appBar: const EditorToolbar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: editor form. Top-level scroll holds the static bits;
          // the reorderable list is non-scrolling and lives inside it.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionToggles(),
                  const SizedBox(height: 16),
                  const BioForm(),
                  const SizedBox(height: 16),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: enabledInOrder.length,
                    onReorder: (oldIndex, newIndex) {
                      // Translate visible-list indices to the moved section,
                      // then call store.reorder on the underlying full order.
                      var adjusted = newIndex;
                      if (newIndex > oldIndex) adjusted -= 1;
                      final moved = enabledInOrder[oldIndex];
                      // Compute the target absolute index in s.order by
                      // finding where the adjusted-position visible section
                      // sits, then inserting before/after it.
                      final fullOrder = [...s.order]..remove(moved);
                      final targetVisibleNeighbour = adjusted >= enabledInOrder.length - 1
                          ? null
                          : enabledInOrder
                              .where((x) => x != moved)
                              .elementAt(adjusted);
                      final insertAt = targetVisibleNeighbour == null
                          ? fullOrder.length
                          : fullOrder.indexOf(targetVisibleNeighbour);
                      fullOrder.insert(insertAt, moved);
                      store.updateSettings((x) => x.copyWith(order: fullOrder));
                    },
                    itemBuilder: (context, i) {
                      final section = enabledInOrder[i];
                      return _DraggableSectionCard(
                        key: ValueKey(section),
                        index: i,
                        section: section,
                      );
                    },
                  ),
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

/// Wraps a section's form with a drag handle on the left so the user can
/// reorder via ReorderableListView. Padding below separates cards.
class _DraggableSectionCard extends StatelessWidget {
  const _DraggableSectionCard({
    super.key,
    required this.index,
    required this.section,
  });

  final int index;
  final Section section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.only(top: 16, right: 4),
              child: Icon(Icons.drag_indicator, color: Colors.grey),
            ),
          ),
          Expanded(child: _formFor(section)),
        ],
      ),
    );
  }

  Widget _formFor(Section s) => switch (s) {
        Section.summary => const SummaryForm(),
        Section.experience => const ExperienceForm(),
        Section.education => const EducationForm(),
        Section.projects => const ProjectsForm(),
        Section.skills => const SkillsForm(),
      };
}
