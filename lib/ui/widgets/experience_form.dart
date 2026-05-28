import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/resume.dart';
import '../../state/resume_store.dart';
import '_form_kit.dart';

class ExperienceForm extends StatelessWidget {
  const ExperienceForm({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ResumeStore>();
    final items = store.resume.experience;

    void set(List<ExperienceItem> next) =>
        store.updateResume((r) => r.copyWith(experience: next));

    return FormCard(
      title: 'Experience',
      trailing: TextButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add role'),
        onPressed: () => set([...items, const ExperienceItem()]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _RoleEditor(
              key: ValueKey('exp-$i-${items.length}'),
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

class _RoleEditor extends StatelessWidget {
  const _RoleEditor({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });

  final ExperienceItem item;
  final ValueChanged<ExperienceItem> onChanged;
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
                  label: 'Title',
                  initial: item.title,
                  onChanged: (v) => onChanged(item.copyWith(title: v)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PlainField(
                  label: 'Company',
                  initial: item.company,
                  onChanged: (v) => onChanged(item.copyWith(company: v)),
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
                  label: 'Start (e.g. Jan 2023)',
                  initial: item.start,
                  onChanged: (v) => onChanged(item.copyWith(start: v)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PlainField(
                  label: 'End (blank = Present)',
                  initial: item.end,
                  onChanged: (v) => onChanged(item.copyWith(end: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _BulletList(
            bullets: item.bullets,
            onChanged: (b) => onChanged(item.copyWith(bullets: b)),
          ),
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.bullets, required this.onChanged});
  final List<String> bullets;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Bullets', style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add bullet'),
              onPressed: () => onChanged([...bullets, '']),
            ),
          ],
        ),
        for (var i = 0; i < bullets.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: PlainField(
                    key: ValueKey('bullet-$i-${bullets.length}'),
                    label: 'Achievement / impact',
                    initial: bullets[i],
                    onChanged: (v) {
                      final copy = [...bullets];
                      copy[i] = v;
                      onChanged(copy);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => onChanged([...bullets]..removeAt(i)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
