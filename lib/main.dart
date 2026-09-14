import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:productcatalog/presentation/viewmodels/product_view_model.dart';
import 'package:productcatalog/presentation/views/product_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Editorial premium palette
  static const _primary = Color(0xFF1A1A1A);
  static const _primaryContainer = Color(0xFFF0EBE1);
  static const _onPrimaryContainer = Color(0xFF3D3423);
  static const _secondary = Color(0xFFB8956A);
  static const _secondaryContainer = Color(0xFFF5EED9);
  static const _onSecondaryContainer = Color(0xFF4E3E1F);
  static const _scaffoldBg = Color(0xFFFAF7F2);

  @override
  Widget build(BuildContext context) {
    final base = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
    );

    final scheme = base.copyWith(
      primary: _primary,
      onPrimary: Colors.white,
      primaryContainer: _primaryContainer,
      onPrimaryContainer: _onPrimaryContainer,
      secondary: _secondary,
      onSecondary: const Color(0xFF1F1F1F),
      secondaryContainer: _secondaryContainer,
      onSecondaryContainer: _onSecondaryContainer,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ChangeNotifierProvider(
      create: (_) => ProductViewModel(),
      child: MaterialApp(
        title: 'Product Catalog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: scheme,
          useMaterial3: true,
          scaffoldBackgroundColor: _scaffoldBg,
          textTheme: textTheme,
          appBarTheme: AppBarTheme(
            backgroundColor: _scaffoldBg,
            surfaceTintColor: _scaffoldBg,
            foregroundColor: scheme.onSurface,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              fontSize: 22,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            margin: const EdgeInsets.symmetric(vertical: 6),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Colors.white,
            selectedColor: const Color.fromARGB(255, 216, 164, 108),
            labelStyle: textTheme.labelLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            secondaryLabelStyle: textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(color: scheme.outlineVariant),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            showCheckmark: false,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            prefixIconColor: scheme.onSurfaceVariant,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: scheme.primary, width: 1.5),
            ),
          ),
        ),
        home: const ProductListScreen(),
      ),
    );
  }
}
