/// Live PDF preview. Wraps `printing.PdfPreview` and rebuilds whenever the
/// store changes, with a 2-second debounce so rapid edits batch into one
/// render. The preview uses the same `buildResumePdf` function as export.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../state/resume_store.dart';

class PreviewPane extends StatefulWidget {
  const PreviewPane({super.key});

  @override
  State<PreviewPane> createState() => _PreviewPaneState();
}

class _PreviewPaneState extends State<PreviewPane> {
  ResumeStore? _store;
  Timer? _debounce;
  Object? _renderKey;

  Object _computeKey() => Object.hash(
        _store!.resume.encode(),
        _store!.settings.toJson().toString(),
      );

  void _onStoreChange() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _renderKey = _computeKey();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = Provider.of<ResumeStore>(context, listen: false);
    if (_store != store) {
      _store?.removeListener(_onStoreChange);
      _store = store;
      _store!.addListener(_onStoreChange);
      _renderKey = _computeKey();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _store?.removeListener(_onStoreChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<ResumeStore>(context, listen: false);
    return PdfPreview(
      key: ValueKey(_renderKey),
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
