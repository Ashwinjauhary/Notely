import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notely/core/theme/app_theme.dart';
import 'package:notely/providers/theme_provider.dart';
import 'package:notely/screens/splash/splash_screen.dart';
import 'package:notely/data/hive_adapters/hive_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await HiveAdapter.initializeHive();
  
  runApp(
    const ProviderScope(
      child: NotelyApp(),
    ),
  );
}

class NotelyApp extends ConsumerWidget {
  const NotelyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = ref.watch(effectiveThemeProvider);
    final textScaleFactor = ref.watch(textScaleFactorProvider);

    return MaterialApp(
      title: 'Notely',
      debugShowCheckedModeBanner: false,
      theme: theme,
      themeMode: themeMode,
      home: const SplashScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: textScaleFactor,
          ),
          child: child!,
        );
      },
    );
  }
}
