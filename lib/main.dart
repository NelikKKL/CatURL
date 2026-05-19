import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UrlOpenerApp());
}

class UrlOpenerApp extends StatelessWidget {
  const UrlOpenerApp({super.key});

  static const _fallbackPrimary = Color(0xFF006874);
  static const _fallbackSecondary = Color(0xFF4A6267);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightScheme = lightDynamic.harmonized();
          darkScheme = darkDynamic.harmonized();
        } else {
          lightScheme = ColorScheme.fromSeed(
            seedColor: _fallbackPrimary,
            secondary: _fallbackSecondary,
            brightness: Brightness.light,
          );
          darkScheme = ColorScheme.fromSeed(
            seedColor: _fallbackPrimary,
            secondary: _fallbackSecondary,
            brightness: Brightness.dark,
          );
        }

        final textTheme = GoogleFonts.nunitoTextTheme();

        return MaterialApp(
          title: 'CatURL',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            textTheme: textTheme,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            textTheme: textTheme,
            brightness: Brightness.dark,
          ),
          themeMode: ThemeMode.system,
          home: const HomeScreen(),
        );
      },
    );
  }
}
