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
          // M3 defaults the AppBar to a light surface, which hides white
          // text/icons. Force a dark bar so the toolbar reads cleanly.
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1F2937),
            foregroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.white),
            actionsIconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            // Kill M3's surface-tint overlay and scroll-under recolor so the
            // bar stays the exact slate we set above.
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            elevation: 0,
          ),
        ),
        home: const EditorPage(),
      ),
    );
  }
}
