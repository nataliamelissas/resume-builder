/// Shared form primitives: a section card and a debounced text field that
/// pushes updates into the store without rebuilding the whole tree on every
/// keystroke.
library;

import 'package:flutter/material.dart';

class FormCard extends StatelessWidget {
  const FormCard({super.key, required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

/// Uncontrolled text field that emits [onChanged] without making the parent
/// own the value. Use for free-text resume fields.
class PlainField extends StatefulWidget {
  const PlainField({
    super.key,
    required this.label,
    required this.initial,
    required this.onChanged,
    this.maxLines = 1,
  });

  final String label;
  final String initial;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  State<PlainField> createState() => _PlainFieldState();
}

class _PlainFieldState extends State<PlainField> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);

  @override
  void didUpdateWidget(covariant PlainField old) {
    super.didUpdateWidget(old);
    // Keep field in sync when an import wholesale-replaces the model.
    if (widget.initial != _c.text && !_c.selection.isValid) {
      _c.text = widget.initial;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      maxLines: widget.maxLines,
      minLines: 1,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: widget.onChanged,
    );
  }
}
