/// Browser-only persistence: localStorage for auto-save, file picker / Blob
/// download for portable JSON import/export. No network, no third parties.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../models/resume.dart';
import '../models/settings.dart';

const _kResumeKey = 'resume';
const _kSettingsKey = 'settings';

class LocalStorage {
  /// Read the persisted resume, or [Resume()] if nothing is stored yet.
  Resume loadResume() {
    final raw = web.window.localStorage.getItem(_kResumeKey);
    if (raw == null || raw.isEmpty) return const Resume();
    try {
      return Resume.decode(raw);
    } catch (_) {
      return const Resume();
    }
  }

  Settings loadSettings() {
    final raw = web.window.localStorage.getItem(_kSettingsKey);
    if (raw == null || raw.isEmpty) return const Settings();
    try {
      return Settings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const Settings();
    }
  }

  void saveResume(Resume r) =>
      web.window.localStorage.setItem(_kResumeKey, r.encode());

  void saveSettings(Settings s) =>
      web.window.localStorage.setItem(_kSettingsKey, jsonEncode(s.toJson()));
}

/// Trigger a browser download of [bytes] as [filename].
void downloadBytes(Uint8List bytes, String filename, String mime) {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: mime),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

/// Convenience: serialize resume + settings to a single JSON file.
void exportJson(Resume r, Settings s) {
  final payload = jsonEncode({'resume': r.toJson(), 'settings': s.toJson()});
  downloadBytes(
    Uint8List.fromList(utf8.encode(payload)),
    'resume.json',
    'application/json',
  );
}

/// Prompt for a .json file and parse it. Returns null on cancel or bad input.
Future<({Resume resume, Settings settings})?> importJson() async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = '.json,application/json';
  final completer = Completer<({Resume resume, Settings settings})?>();

  input.onChange.listen((_) async {
    final files = input.files;
    if (files == null || files.length == 0) {
      completer.complete(null);
      return;
    }
    final text = (await files.item(0)!.text().toDart).toDart;
    try {
      final parsed = jsonDecode(text) as Map<String, dynamic>;
      completer.complete((
        resume: Resume.fromJson(parsed['resume'] as Map<String, dynamic>),
        settings: Settings.fromJson(parsed['settings'] as Map<String, dynamic>),
      ));
    } catch (_) {
      completer.complete(null);
    }
  });

  input.click();
  return completer.future;
}
