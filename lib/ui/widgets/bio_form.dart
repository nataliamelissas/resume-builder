/// Contact header form: name, headline, email, phone, location, links.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/resume.dart';
import '../../state/resume_store.dart';
import '_form_kit.dart';

class BioForm extends StatelessWidget {
  const BioForm({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ResumeStore>();
    final bio = store.resume.bio;

    void mutate(Bio Function(Bio) f) =>
        store.updateResume((r) => r.copyWith(bio: f(r.bio)));

    return FormCard(
      title: 'Bio',
      child: Column(
        children: [
          PlainField(
            label: 'Full name',
            initial: bio.name,
            onChanged: (v) => mutate((b) => b.copyWith(name: v)),
          ),
          const SizedBox(height: 8),
          PlainField(
            label: 'Headline (e.g. Senior Backend Engineer)',
            initial: bio.headline,
            onChanged: (v) => mutate((b) => b.copyWith(headline: v)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: PlainField(
                  label: 'Email',
                  initial: bio.email,
                  onChanged: (v) => mutate((b) => b.copyWith(email: v)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PlainField(
                  label: 'Phone',
                  initial: bio.phone,
                  onChanged: (v) => mutate((b) => b.copyWith(phone: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          PlainField(
            label: 'Location',
            initial: bio.location,
            onChanged: (v) => mutate((b) => b.copyWith(location: v)),
          ),
          const SizedBox(height: 12),
          _LinkList(
            links: bio.links,
            onChanged: (links) => mutate((b) => b.copyWith(links: links)),
          ),
        ],
      ),
    );
  }
}

class _LinkList extends StatelessWidget {
  const _LinkList({required this.links, required this.onChanged});
  final List<Link> links;
  final ValueChanged<List<Link>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Links', style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add link'),
              onPressed: () => onChanged([...links, const Link()]),
            ),
          ],
        ),
        for (var i = 0; i < links.length; i++) ...[
          Row(
            children: [
              Expanded(
                child: PlainField(
                  key: ValueKey('link-label-$i-${links.length}'),
                  label: 'Label',
                  initial: links[i].label,
                  onChanged: (v) {
                    final copy = [...links];
                    copy[i] = copy[i].copyWith(label: v);
                    onChanged(copy);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: PlainField(
                  key: ValueKey('link-url-$i-${links.length}'),
                  label: 'URL',
                  initial: links[i].url,
                  onChanged: (v) {
                    final copy = [...links];
                    copy[i] = copy[i].copyWith(url: v);
                    onChanged(copy);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onChanged([...links]..removeAt(i)),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }
}
