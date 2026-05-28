/// Live PDF preview. Wraps `printing.PdfPreview` and rebuilds whenever the
/// store changes. The preview itself runs the same `buildResumePdf`
/// function used for export, so what the user sees is what gets downloaded.
library;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../state/resume_store.dart';

class PreviewPane extends StatelessWidget {
  const PreviewPane({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ResumeStore>();
    return PdfPreview(
      // Key forces a rebuild whenever the resume/settings change.
      key: ValueKey(
        Object.hash(store.resume.encode(), store.settings.toJson().toString()),
      ),
      build: (_) => renderPdf(store),
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      allowPrinting: false,
      allowSharing: false,
      useActions: false,
      padding: const EdgeInsets.all(12),
    );
  }
}
