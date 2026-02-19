import 'package:flutter/material.dart';

import 'color_data.dart';
import 'theme_extensions/app_custom_color_scheme.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: ColorData.primary,
      extensions: const <ThemeExtension<dynamic>>[
        AppCustomColorScheme(primaryBrand: ColorData.primary),
      ],
    );
  }
}
