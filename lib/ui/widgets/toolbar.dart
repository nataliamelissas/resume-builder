/// Top app bar: font choice, font size, margin, overflow warning, and
/// import/export/PDF actions.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/settings.dart';
import '../../state/resume_store.dart';
import '../../storage/local_storage.dart';

class EditorToolbar extends StatelessWidget implements PreferredSizeWidget {
  const EditorToolbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ResumeStore>();
    final s = store.settings;
    return AppBar(
      title: const Text('Resume Builder'),
      actions: [
        _OverflowBadge(visible: store.overflows),
        const SizedBox(width: 12),
        _FontDropdown(value: s.font, onChanged: (v) {
          store.updateSettings((x) => x.copyWith(font: v));
        }),
        const SizedBox(width: 12),
        _FontSizeStepper(
          value: s.fontSize,
          onChanged: (v) => store.updateSettings((x) => x.copyWith(fontSize: v)),
        ),
        const SizedBox(width: 12),
        _MarginToggle(
          value: s.margin,
          onChanged: (v) => store.updateSettings((x) => x.copyWith(margin: v)),
        ),
        const SizedBox(width: 16),
        IconButton(
          tooltip: 'Import JSON',
          icon: const Icon(Icons.file_upload),
          onPressed: () async {
            final picked = await importJson();
            if (picked != null) {
              store.replace(resume: picked.resume, settings: picked.settings);
            }
          },
        ),
        IconButton(
          tooltip: 'Export JSON',
          icon: const Icon(Icons.file_download),
          onPressed: () => exportJson(store.resume, store.settings),
        ),
        TextButton.icon(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          label: const Text('PDF', style: TextStyle(color: Colors.white)),
          onPressed: () async {
            final bytes = await renderPdf(store);
            final name = store.resume.bio.name.trim().isEmpty
                ? 'resume'
                : store.resume.bio.name.trim().replaceAll(RegExp(r'\s+'), '_');
            downloadBytes(bytes, '$name.pdf', 'application/pdf');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _OverflowBadge extends StatelessWidget {
  const _OverflowBadge({required this.visible});
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Tooltip(
      message: 'Content overflows one page. Reduce font size, margins, or content.',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber, size: 16, color: Colors.white),
            SizedBox(width: 4),
            Text('Overflow', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _FontDropdown extends StatelessWidget {
  const _FontDropdown({required this.value, required this.onChanged});
  final ResumeFont value;
  final ValueChanged<ResumeFont> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ResumeFont>(
      value: value,
      dropdownColor: Theme.of(context).colorScheme.surface,
      underline: const SizedBox.shrink(),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      items: const [
        DropdownMenuItem(value: ResumeFont.helvetica, child: Text('Helvetica')),
        DropdownMenuItem(value: ResumeFont.times, child: Text('Times')),
        DropdownMenuItem(value: ResumeFont.courier, child: Text('Courier')),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _FontSizeStepper extends StatelessWidget {
  const _FontSizeStepper({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Smaller',
          icon: const Icon(Icons.text_decrease, color: Colors.white),
          onPressed: value > 8 ? () => onChanged(value - 1) : null,
        ),
        Text('$value pt', style: const TextStyle(color: Colors.white)),
        IconButton(
          tooltip: 'Larger',
          icon: const Icon(Icons.text_increase, color: Colors.white),
          onPressed: value < 14 ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _MarginToggle extends StatelessWidget {
  const _MarginToggle({required this.value, required this.onChanged});
  final Margin value;
  final ValueChanged<Margin> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Margin>(
      style: SegmentedButton.styleFrom(foregroundColor: Colors.white),
      segments: const [
        ButtonSegment(value: Margin.quarter, label: Text('0.25"')),
        ButtonSegment(value: Margin.eighth, label: Text('0.125"')),
      ],
      selected: {value},
      onSelectionChanged: (set) => onChanged(set.first),
      showSelectedIcon: false,
    );
  }
}
