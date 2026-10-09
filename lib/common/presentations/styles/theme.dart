// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:estimator/common/extensions/color_extension.dart';

import 'package:estimator/constants.dart';

class AppColors {
  const AppColors._();

  static const primaryColor = Color(0xFFFF7900);
  static const background = Color(0xFFF7F2E1);
  static const panel = Color(0xFFF8F3E4);
  static const mainSurface = Color(0xFFFFFDF5);
  static const border = Color(0xFFDED7C5);
  static const text = Color(0xFF687985);
  static const textDark = Color(0xFF566A77);
  static const icon = Color(0xFF87949D);
  static const subtle = Color(0xFFEFE9D8);
  static const accent = Color(0xFFAA4C89);
  static const connectionDot = Color(0xFFB996ED);
}

@immutable
class AppStyle {
  // Singleton pattern
  const AppStyle._();
  static final instance = AppStyle._();

  // data for theme
  static const _primaryFont = 'Inter';
  // static const _headerFont = 'Maragsa';

  static const lightColorScheme = ColorScheme.light(primary: AppColors.primaryColor, outline: AppColors.border);

  ThemeData getTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      // scaffoldBackgroundColor: colorScheme.surface,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: colorScheme.secondaryContainer,
      cardColor: colorScheme.secondaryContainer,
      // fontFamily: GoogleFonts.inter().fontFamily,
      fontFamily: _primaryFont,
      dividerColor: colorScheme.outline,
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600), // appbar title
        titleMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600), //
        bodyLarge: TextStyle(fontSize: 14.0), // textfield, chip, ListTile title,
        bodyMedium: TextStyle(fontSize: 12.0), // body
        bodySmall: TextStyle(fontSize: 14.0), // textfield helper
        labelLarge: TextStyle(fontSize: 18.0, height: 1.4, fontWeight: FontWeight.w600), // button, *-chip
        labelMedium: TextStyle(fontSize: 16.0, height: 1.4), // bottomNavBar
        labelSmall: TextStyle(fontSize: 13.0),
      ),
      iconTheme: IconThemeData(size: 18.0, color: colorScheme.onSurface),
      chipTheme: ChipThemeData(
        color: WidgetStateColor.resolveWith((state) {
          if (state.contains(WidgetState.error)) {
            return colorScheme.errorContainer;
          }
          if (state.contains(WidgetState.disabled)) {
            return Colors.black12;
          }
          if (state.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.secondaryContainer.lighten(50);
        }),
        // selectedColor: colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: iCardBorderRadius),
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return BorderSide(color: colorScheme.primary);
          return BorderSide(color: colorScheme.secondaryContainer);
        }),
        // side: const WidgetStateBorderSide.fromMap(<WidgetStatesConstraint, BorderSide?>{
        //   WidgetState.selected: BorderSide(color: Colors.red),
        //   // Resolves to null if no keys match, deferring to the default value
        //   // of the theme or widget.
        // }),
        padding: const EdgeInsets.all(4.0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        scrolledUnderElevation: 1.0,
        elevation: 0.5,
        shadowColor: colorScheme.outline,
        surfaceTintColor: colorScheme.surface,
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: colorScheme.surface,
          systemNavigationBarIconBrightness: colorScheme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        // shadowColor: Colors.black38,
        // iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),
      inputDecorationTheme: InputDecorationTheme(
        // filled: true,
        // fillColor: WidgetStateColor.resolveWith((state) {
        //   if (state.contains(WidgetState.disabled)) {
        //     return Colors.black12;
        //   }
        //   if (state.contains(WidgetState.error)) {
        //     return colorScheme.errorContainer;
        //   }
        //   return colorScheme.secondaryContainer.lighten(50);
        // }),
        contentPadding: iFormFieldContentPadding,
        isCollapsed: true,
        // isDense: true,
        hintStyle: const TextStyle(color: Colors.black38),
        border: WidgetStateInputBorder.resolveWith((states) {
          late final Color color;
          if (states.contains(WidgetState.disabled)) {
            color = Colors.black38;
          } else if (states.contains(WidgetState.error)) {
            color = colorScheme.error;
          } else if (states.contains(WidgetState.focused)) {
            color = colorScheme.primary;
          } else {
            color = colorScheme.outline;
          }

          return OutlineInputBorder(
            borderRadius: iTextFieldBorderRadius,
            borderSide: BorderSide(color: color),
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll<double>(2.0),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(iButtonPadding),
          minimumSize: const WidgetStatePropertyAll<Size>(iButtonSize),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((state) {
            if (state.contains(WidgetState.disabled)) return colorScheme.primary.withAlpha(100);
            if (state.contains(WidgetState.error)) return colorScheme.error;
            return colorScheme.primary;
          }),
          foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.onPrimary),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: iButtonBorderRadius),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(iButtonPadding),
          minimumSize: const WidgetStatePropertyAll<Size>(iButtonSize),
          // backgroundColor: WidgetStateProperty.resolveWith<Color>((state) {
          //   if (state.contains(WidgetState.disabled)) return colorScheme.primary.withAlpha(100);
          //   if (state.contains(WidgetState.error)) return colorScheme.error;
          //   return colorScheme.primary;
          // }),
          // foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.onPrimary),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: iButtonBorderRadius),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(iButtonPadding),
          minimumSize: const WidgetStatePropertyAll<Size>(iButtonSize),
          // backgroundColor: WidgetStateProperty.resolveWith<Color>((state) {
          //   if (state.contains(WidgetState.disabled)) return colorScheme.primaryContainer.withAlpha(30);
          //   if (state.contains(WidgetState.error)) return colorScheme.errorContainer;
          //   return colorScheme.primaryContainer;
          // }),
          // foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.onPrimaryContainer),
          shape: WidgetStateProperty.resolveWith<OutlinedBorder>((state) {
            // Color borderColor = colorScheme.primary;
            // if (state.contains(WidgetState.disabled)) {
            //   borderColor = colorScheme.primaryContainer;
            // } else if (state.contains(WidgetState.error)) {
            //   borderColor = colorScheme.error;
            // }

            return RoundedRectangleBorder(borderRadius: iButtonBorderRadius);
          }),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(iButtonPadding),
          minimumSize: const WidgetStatePropertyAll<Size>(iButtonSize),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: iButtonBorderRadius),
          ),
          side: WidgetStatePropertyAll(BorderSide(width: 1.0, color: colorScheme.outlineVariant)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2.0,
        shape: const RoundedRectangleBorder(borderRadius: iButtonBorderRadius),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          // padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(iButtonPadding.vertical)),
          minimumSize: WidgetStatePropertyAll<Size>(Size.square(iButtonSize.shortestSide)),
          // backgroundColor: WidgetStateProperty.resolveWith<Color>((state) {
          //   if (state.contains(WidgetState.disabled)) return colorScheme.primary.withAlpha(100);
          //   if (state.contains(WidgetState.error)) return colorScheme.error;
          //   return colorScheme.primary;
          // }),
          // foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.onPrimary),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: iButtonBorderRadius),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 10.0,
        dragHandleSize: const Size(25.0, 4.0),
        // modalBackgroundColor: colorScheme.surface,
        dragHandleColor: colorScheme.onSurface,
        clipBehavior: Clip.hardEdge,
        showDragHandle: true,
      ),
      listTileTheme: ListTileThemeData(minVerticalPadding: 8.0, minTileHeight: 56.0),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: colorScheme.surface),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: iCardBorderRadius),
        elevation: 1.0,
        color: colorScheme.secondaryContainer,
      ),
    );
  }
}
