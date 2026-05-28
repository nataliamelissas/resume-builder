/// Holds the editable [Resume] and [Settings], notifies listeners on change,
/// debounces writes to localStorage, and tracks whether the rendered PDF
/// overflows one page so the UI can warn the user.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/resume.dart';
import '../models/settings.dart';
import '../pdf/resume_pdf.dart';
import '../storage/local_storage.dart';

class ResumeStore extends ChangeNotifier {
  ResumeStore(this._storage)
      : _resume = _storage.loadResume(),
        _settings = _storage.loadSettings();

  final LocalStorage _storage;
  Resume _resume;
  Settings _settings;
  bool _overflows = false;
  Timer? _saveTimer;

  Resume get resume => _resume;
  Settings get settings => _settings;
  bool get overflows => _overflows;

  void updateResume(Resume Function(Resume) f) {
    _resume = f(_resume);
    _afterChange();
  }

  void updateSettings(Settings Function(Settings) f) {
    _settings = f(_settings);
    _afterChange();
  }

  /// Replace both values wholesale (used by JSON import).
  void replace({required Resume resume, required Settings settings}) {
    _resume = resume;
    _settings = settings;
    _afterChange();
  }

  void setOverflows(bool value) {
    if (_overflows == value) return;
    _overflows = value;
    notifyListeners();
  }

  void _afterChange() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      _storage.saveResume(_resume);
      _storage.saveSettings(_settings);
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}

/// Render the current state to PDF bytes. Side-effect: updates the store's
/// overflow flag so the UI badge stays in sync with what was just rendered.
Future<Uint8List> renderPdf(ResumeStore store) async {
  final doc = buildResumePdf(store.resume, store.settings);
  final bytes = await doc.save();
  // `pw.Document` lays out lazily during save(); after save() the page list
  // is final.
  final pages = doc.document.pdfPageList.pages.length;
  store.setOverflows(pages > 1);
  return bytes;
}
