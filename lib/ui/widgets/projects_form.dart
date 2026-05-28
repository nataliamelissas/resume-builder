import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/resume.dart';
import '../../state/resume_store.dart';
import '_form_kit.dart';

class ProjectsForm extends StatelessWidget {
  const ProjectsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ResumeStore>();
    final items = store.resume.projects;

    void set(List<ProjectItem> next) =>
        store.updateResume((r) => r.copyWith(projects: next));

    return FormCard(
      title: 'Projects',
      trailing: TextButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add project'),
        onPressed: () => set([...items, const ProjectItem()]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _Editor(
              key: ValueKey('proj-$i-${items.length}'),
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

  final ProjectItem item;
  final ValueChanged<ProjectItem> onChanged;
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
                  label: 'Project name',
                  initial: item.name,
                  onChanged: (v) => onChanged(item.copyWith(name: v)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PlainField(
                  label: 'URL',
                  initial: item.url,
                  onChanged: (v) => onChanged(item.copyWith(url: v)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
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
                    key: ValueKey('pbullet-$i-${bullets.length}'),
                    label: 'Detail',
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
