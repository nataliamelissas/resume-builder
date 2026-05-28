/// Skills entered as one or more named groups. Each group renders in the PDF
/// as `Category: item1, item2, ...` so ATS parsers see clear, scannable
/// categories. Items are entered as a comma-separated string per group.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/resume.dart';
import '../../state/resume_store.dart';
import '_form_kit.dart';

class SkillsForm extends StatelessWidget {
  const SkillsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ResumeStore>();
    final groups = store.resume.skills;

    void set(List<SkillGroup> next) =>
        store.updateResume((r) => r.copyWith(skills: next));

    return FormCard(
      title: 'Skills',
      trailing: TextButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add category'),
        onPressed: () => set([...groups, const SkillGroup()]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < groups.length; i++) ...[
            _GroupEditor(
              key: ValueKey('skillgroup-$i-${groups.length}'),
              group: groups[i],
              onChanged: (g) {
                final copy = [...groups];
                copy[i] = g;
                set(copy);
              },
              onDelete: () => set([...groups]..removeAt(i)),
            ),
            const SizedBox(height: 8),
          ],
          if (groups.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Add a category (e.g. "Backend", "AI") and list skills below it.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupEditor extends StatelessWidget {
  const _GroupEditor({
    super.key,
    required this.group,
    required this.onChanged,
    required this.onDelete,
  });

  final SkillGroup group;
  final ValueChanged<SkillGroup> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: PlainField(
                  label: 'Category (e.g. AI, Backend, Frontend)',
                  initial: group.name,
                  onChanged: (v) => onChanged(group.copyWith(name: v)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 8),
          PlainField(
            label: 'Skills (comma-separated)',
            initial: group.items.join(', '),
            maxLines: 2,
            onChanged: (v) {
              final list = v
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              onChanged(group.copyWith(items: list));
            },
          ),
        ],
      ),
    );
  }
}
