//
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey =
      'theme_mode'; // Key for storing the theme mode in SharedPreferences
  static const String _colorKey =
      'accent_color'; // Key for storing the accent color(primary/brand color) in SharedPreferences(In Material 3, it's called "seed color" and it generates the entire color scheme from it)
  static const String _fontSizeKey =
      'font_size'; // Key for storing the font size in SharedPreferences

  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = Colors.blue; // Default accent color
  double _fontSize = 1.0; // 1.0 = medium, 0.85 = small, 1.15 = large

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  double get fontSize => _fontSize;

  // load saved preferences on app start
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    //load theme mode
    final savedMode = prefs.getString(_themeModeKey);
    if (savedMode == "light")
      _themeMode = ThemeMode.light;
    else if (savedMode == "dark")
      _themeMode = ThemeMode.dark;
    else
      _themeMode = ThemeMode.system;

    //load accent color
    final savedColor = prefs.getInt(_colorKey);
    if (savedColor != null) _accentColor = Color(savedColor);

    //load font size
    _fontSize = prefs.getDouble(_fontSizeKey) ?? 1.0;
    notifyListeners();
  }

  // change theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners(); // notify listeners to rebuild UI with new theme mode
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      await prefs.setString(_themeModeKey, "light");
    } else if (mode == ThemeMode.dark) {
      await prefs.setString(_themeModeKey, "dark");
    } else {
      await prefs.setString(_themeModeKey, "system");
    }
    notifyListeners();
  }

  // change accent color
  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    notifyListeners(); // notify listeners to rebuild UI with new accent color
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _colorKey,
      color.toARGB32(),
    ); // cause color.value got depreciated so we use toARGB32() instead
  }

  // change font size
  Future<void> setFontSize(double size) async {
    _fontSize = size;
    notifyListeners(); // notify listeners to rebuild UI with new font size
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }

  //generate light theme data
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _accentColor,
      brightness: Brightness.light,
    ),
    fontFamily: 'Poppins',
    textTheme: _textTheme,
  );

  //generate dark theme data
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _accentColor,
      brightness: Brightness.dark,
    ),
    fontFamily: 'Poppins',
    textTheme: _textTheme,
  );

  // Scale text theme based on the selected font size
  TextTheme get _textTheme => TextTheme(
    bodyLarge: TextStyle(fontSize: 16 * _fontSize),
    bodyMedium: TextStyle(fontSize: 14 * _fontSize),
    bodySmall: TextStyle(fontSize: 12 * _fontSize),
    titleLarge: TextStyle(fontSize: 22 * _fontSize),
    titleMedium: TextStyle(fontSize: 16 * _fontSize),
    titleSmall: TextStyle(fontSize: 14 * _fontSize),
  );
}
