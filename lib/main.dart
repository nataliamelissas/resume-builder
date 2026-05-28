/// App entry point. Provides the [ResumeStore] to the widget tree and mounts
/// the editor page.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/resume_store.dart';
import 'storage/local_storage.dart';
import 'ui/editor_page.dart';

void main() => runApp(const ResumeBuilderApp());

class ResumeBuilderApp extends StatelessWidget {
  const ResumeBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResumeStore(LocalStorage()),
      child: MaterialApp(
        title: 'Resume Builder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1F2937),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        home: const EditorPage(),
      ),
    );
  }
}
