import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:notes/firebase_options.dart';
import 'package:notes/screens/note_list_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await FlutterConfig.loadEnvVariables();
  }
  runApp(
    ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false), // Default to light theme
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ValueNotifier<bool>>(
      builder: (context, isDarkTheme, _) {
        return MaterialApp(
          title: 'Notes App',
          theme: isDarkTheme.value ? ThemeData.dark() : ThemeData.light(),
          debugShowCheckedModeBanner: false,
          home: const NoteListScreen(),
        );
      },
    );
  }
}
