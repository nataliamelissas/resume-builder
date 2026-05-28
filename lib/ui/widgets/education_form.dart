import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/resume.dart';
import '../../state/resume_store.dart';
import '_form_kit.dart';

class EducationForm extends StatelessWidget {
  const EducationForm({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ResumeStore>();
    final items = store.resume.education;

    void set(List<EducationItem> next) =>
        store.updateResume((r) => r.copyWith(education: next));

    return FormCard(
      title: 'Education',
      trailing: TextButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add school'),
        onPressed: () => set([...items, const EducationItem()]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _Editor(
              key: ValueKey('edu-$i-${items.length}'),
              item: items[i],
              onChanged: (v) {
                final copy = [...items];
                copy[i] = v;
                set(copy);
              },
              onDelete: () => set([...items]..removeAt(i)),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });

  final EducationItem item;
  final ValueChanged<EducationItem> onChanged;
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
                  label: 'Degree',
                  initial: item.degree,
                  onChanged: (v) => onChanged(item.copyWith(degree: v)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PlainField(
                  label: 'School',
                  initial: item.school,
                  onChanged: (v) => onChanged(item.copyWith(school: v)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: PlainField(
                  label: 'Location',
                  initial: item.location,
                  onChanged: (v) => onChanged(item.copyWith(location: v)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PlainField(
                  label: 'Start',
                  initial: item.start,
                  onChanged: (v) => onChanged(item.copyWith(start: v)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PlainField(
                  label: 'End',
                  initial: item.end,
                  onChanged: (v) => onChanged(item.copyWith(end: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          PlainField(
            label: 'Details (GPA, honors, coursework)',
            initial: item.details,
            maxLines: 2,
            onChanged: (v) => onChanged(item.copyWith(details: v)),
          ),
        ],
      ),
    );
  }
}
