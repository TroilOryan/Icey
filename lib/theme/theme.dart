import 'package:IceyPlayer/helpers/dominant_color.dart';
import 'package:flutter/material.dart';
import 'package:go_transitions/go_transitions.dart';

class AppTheme {
  static Color primaryColor = const Color(0xff007aff);

  static const Duration defaultDuration = Duration(milliseconds: 100);

  static const Duration defaultDurationMid = Duration(milliseconds: 300);

  static const Duration defaultDurationLong = Duration(milliseconds: 600);

  static const int defaultAlpha = 200;

  static const int defaultAlphaMid = 88;

  static const int defaultAlphaLight = 33;

  static Radius borderRadiusXxs = Radius.circular(12);

  static Radius borderRadiusXs = Radius.circular(16);

  static Radius borderRadiusSm = Radius.circular(20);

  static Radius borderRadiusMd = Radius.circular(24);

  static Radius borderRadiusLg = Radius.circular(28);

  static const Color bgColor = Color(0xfff1f3f5);

  static const Color bgColorDisabled = Color(0xffcecece);

  static const Color bgColorDark = Colors.black;

  static const Color bgColorDarkDisabled = Color(0xff424242);

  static TextStyle titleLarge = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
  );

  static TextStyle titleMedium = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );

  static TextStyle titleSmall = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );

  static TextStyle bodyLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
  );

  static ThemeData theme({
    required ColorScheme colorScheme,
    required bool isLightCover,
    required bool artCover,
  }) {
    final TextTheme textTheme = TextTheme(
      titleLarge: titleLarge.copyWith(color: colorScheme.onSurface),
      titleMedium: titleMedium.copyWith(color: colorScheme.onSurface),
      titleSmall: titleSmall.copyWith(color: colorScheme.onSurface),
      bodyLarge: bodyLarge.copyWith(
        color: colorScheme.onSurface.withAlpha(defaultAlpha),
      ),
      bodyMedium: bodyMedium.copyWith(
        color: colorScheme.onSurface.withAlpha(defaultAlpha),
      ),
      bodySmall: bodySmall.copyWith(
        color: colorScheme.onSurface.withAlpha(defaultAlpha),
      ),
    );

    final isDark = colorScheme.brightness == Brightness.dark;

    late Color primary;

    late Color secondary,
        primaryContainer = colorScheme.primaryContainer,
        primaryFixed = colorScheme.primaryFixed;

    if (artCover) {
      if (isLightCover) {
        primary = Colors.black;

        secondary = Colors.black45;

        primaryContainer = Colors.black.withAlpha(AppTheme.defaultAlphaMid);

        primaryFixed = Colors.black.withAlpha(AppTheme.defaultAlpha);
      } else {
        primary = Colors.white;

        secondary = Colors.white54;

        primaryContainer = Colors.white.withAlpha(AppTheme.defaultAlphaMid);

        primaryFixed = Colors.white.withAlpha(AppTheme.defaultAlpha);
      }
    } else {
      if (isLightCover) {
        if (isDark) {
          primary = Colors.white;

          secondary = Colors.white54;
        } else {
          primary = colorScheme.primary;

          secondary = colorScheme.secondary;

          primaryContainer = colorScheme.primaryContainer;

          primaryFixed = colorScheme.primaryFixed;
        }

        primaryContainer = Colors.black.withAlpha(AppTheme.defaultAlphaMid);

        primaryFixed = Colors.black.withAlpha(AppTheme.defaultAlpha);
      } else {
        if (isDark) {
          primary = Colors.white;

          secondary = Colors.white54;
        } else {
          primary = colorScheme.primary;

          secondary = colorScheme.secondary;

          primaryContainer = Colors.white.withAlpha(AppTheme.defaultAlphaMid);

          primaryFixed = Colors.white.withAlpha(AppTheme.defaultAlpha);
        }

        primaryContainer = Colors.white.withAlpha(AppTheme.defaultAlphaMid);

        primaryFixed = Colors.white.withAlpha(AppTheme.defaultAlpha);
      }
    }

    return ThemeData(
      fontFamily: "Arial",
      appBarTheme: AppBarThemeData(
        titleTextStyle: titleMedium.copyWith(color: colorScheme.onSurface),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          // Set the predictive back transitions for Android.
          TargetPlatform.iOS: GoTransitions.cupertino,
          TargetPlatform.macOS: GoTransitions.cupertino,
          // TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.android: GoTransitions.cupertino,
        },
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(borderRadiusLg),
        ),
      ),
      cardColor: colorScheme.secondaryContainer,
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xff212121) : Colors.white,
      ),
      colorScheme: colorScheme.copyWith(
        surfaceDim: colorScheme.surface.withAlpha(AppTheme.defaultAlphaMid),
      ),
      // dialogTheme: DialogTheme(
      //   backgroundColor: colorScheme.surface,
      // ),
      dividerColor: colorScheme.onSurface.withAlpha(30),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark
            ? const Color(0xff212121)
            : const Color(0xfff2f3f4),
      ),
      iconTheme: IconThemeData(size: 16, color: colorScheme.onSurface),
      inputDecorationTheme: InputDecorationTheme(
        constraints: BoxConstraints(maxHeight: 66),
        fillColor: (isDark ? const Color(0xff212121) : Colors.white),
        filled: true,
        hintStyle: bodySmall,
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(borderRadiusLg),
          borderSide: BorderSide(
            color: colorScheme.outline.withAlpha(10),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(borderRadiusLg),
          borderSide: BorderSide(
            color: colorScheme.outline.withAlpha(10),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(borderRadiusLg),
          borderSide: BorderSide(color: primaryColor.withAlpha(50), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(borderRadiusLg),
          borderSide: BorderSide(width: 1),
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: titleSmall.copyWith(color: colorScheme.onSurface),
        subtitleTextStyle: bodyMedium.copyWith(
          color: colorScheme.onSurface.withAlpha(defaultAlpha),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: Colors.transparent,
        backgroundColor: (isDark ? const Color(0xff212121) : Colors.white),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        tileHeight: 48,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(size: 16.0, color: colorScheme.onSurface);
        }),
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 6,
        color: isDark ? const Color(0xff212121) : Colors.white,
        shadowColor: isDark ? Colors.white12 : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppTheme.borderRadiusMd),
        ),
        position: PopupMenuPosition.under,
      ),
      primaryColor: colorScheme.primary,
      secondaryHeaderColor: isDark
          ? const Color(0xff1a1a1a)
          : const Color(0xffe7e8ea),
      scaffoldBackgroundColor: isDark ? Colors.black : const Color(0xfff2f3f5),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      textTheme: textTheme,
      tabBarTheme: TabBarThemeData(
        splashBorderRadius: BorderRadius.circular(50),
        dividerHeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: titleSmall,
        labelColor: Colors.white,
        unselectedLabelStyle: titleSmall,
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      useMaterial3: true,
    ).copyWith(
      extensions: [
        AppThemeExtension(
          primary: primary,
          primaryContainer: primaryContainer,
          primaryFixed: primaryFixed,
          secondary: secondary,
          secondaryContainer: primaryContainer.withAlpha(
            AppTheme.defaultAlphaLight,
          ),
          secondaryFixed: primaryFixed.withAlpha(AppTheme.defaultAlpha),
          secondaryFixedDim: primaryFixed.withAlpha(AppTheme.defaultAlpha),
        ),
      ],
    );
  }
}

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color primary;
  final Color primaryContainer;
  final Color primaryFixed;
  final Color secondary;
  final Color secondaryContainer;
  final Color secondaryFixed;
  final Color secondaryFixedDim;

  const AppThemeExtension({
    required this.primary,
    required this.primaryContainer,
    required this.primaryFixed,
    required this.secondary,
    required this.secondaryContainer,
    required this.secondaryFixed,
    required this.secondaryFixedDim,
  });

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) => this;

  static AppThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<AppThemeExtension>()!;
  }

  @override
  ThemeExtension<AppThemeExtension> copyWith() {
    // TODO: implement copyWith
    throw UnimplementedError();
  }
}
