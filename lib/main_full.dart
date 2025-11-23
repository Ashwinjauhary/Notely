import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notely/core/theme/app_theme.dart';
import 'package:notely/screens/home/home_screen.dart';
import 'package:notely/screens/splash/splash_screen.dart';
import 'package:notely/providers/theme_provider.dart';
import 'package:notely/providers/notes_provider.dart';
import 'package:notely/data/notes_repository.dart';

void main() {
  runApp(const ProviderScope(child: NotelyApp()));
}

class NotelyApp extends ConsumerWidget {
  const NotelyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final notesRepository = ref.watch(notesRepositoryProvider);

    return MaterialApp(
      title: 'Notely',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: SplashScreen(
        onInitializationComplete: () {
          // Navigate to home screen
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
      ),
    );
  }
}
