import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeBox = "themeBox";
  static const String _themeKey = "isDarkMode";

  late bool _isDarkMode;

  ThemeProvider() {
    _isDarkMode = Hive.box(_themeBox).get(_themeKey, defaultValue: false);
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // **Light Mode Theme**
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Color(0xff191026),
  // scaffoldBackgroundColor: Color(0xff191026),
  colorScheme: const ColorScheme.light(
    background: Color(0xff191026),
    // background: Color(0xff191026),
    primary: Color(0xff191026),
    onPrimary: Colors.white,
    error: Colors.red,
    onSurface: Color(0xff333333),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xff191026),
    // backgroundColor: Color(0xff191026),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xff191026),
    selectedItemColor: Color(0xff65385C),
    unselectedItemColor: Colors.grey,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xff191026),
    foregroundColor: Color(0xff65385C),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xff65385C),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xffffffff)),
    bodyMedium: TextStyle(color: Color(0xffffffff)),
    bodySmall: TextStyle(color: Color(0xffffffff)),
    displayLarge: TextStyle(color: Color(0xff333333)),
    displayMedium: TextStyle(color: Color(0xff333333)),
    displaySmall: TextStyle(color: Color(0xff333333)),
    headlineLarge: TextStyle(color: Color(0xff65385C), fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: Color(0xff65385C), fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(color: Color(0xff65385C), fontWeight: FontWeight.bold),
    titleLarge: TextStyle(color: Color(0xff333333)),
    titleMedium: TextStyle(color: Color(0xff333333)),
    titleSmall: TextStyle(color: Color(0xff333333)),
    labelLarge: TextStyle(color: Color(0xff333333)),
    labelMedium: TextStyle(color: Color(0xff333333)),
    labelSmall: TextStyle(color: Color(0xff333333)),
  ),

  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(Color(0xff65385C)),  // لون النص
      textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Color(0xff65385C)),  // لون الزر
      foregroundColor: MaterialStateProperty.all(Colors.white),  // لون النص
      textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      side: MaterialStateProperty.all(BorderSide(color: Color(0xff65385C))),
      foregroundColor: MaterialStateProperty.all(Color(0xff65385C)),  // لون النص
      textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
    ),
  ),
);




  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        background: Color(0xFF2E2545),
        primary: Color(0xFFD3A97F),
        onPrimary: Colors.white,
        error: Colors.redAccent,
        onSurface: Colors.white,
          ),
    scaffoldBackgroundColor: Color(0xFF2E2545), // لون الخلفية الداكنة
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF2E2545), // لون الخلفية في الوضع الداكن
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2E2545), // لون الخلفية
      selectedItemColor: Color(0xFFD3A97F), // اللون الذهبي للأيقونات المختارة
      unselectedItemColor: Colors.grey, // اللون الرمادي للأيقونات غير المختارة
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E2545), // نفس لون الخلفية
      foregroundColor: Color(0xFFD3A97F), // اللون الذهبي للنصوص والأيقونات
      // elevation: 0, // إزالة الظل ليكون التصميم أنظف
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFD3A97F), // اللون الذهبي للأيقونات
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white), // اللون الأبيض للنصوص
    ),
  );



  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    Hive.box(_themeBox).put(_themeKey, _isDarkMode);
    notifyListeners();
  }
}
