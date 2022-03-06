import 'package:flutter/material.dart';

@immutable
class MelonThemeData {

  late Brightness _brightness;
  late MediaQueryData _mediaQuery;

  bool isDark() => _brightness == Brightness.dark;

  Size size() => _mediaQuery.size;

  double width() => _mediaQuery.size.width;

  double height() => _mediaQuery.size.height;

  Orientation orientation() => _mediaQuery.orientation;

  Color backgroundColor() => isDark() ? Colors.black : Colors.white;

  Color onColor() => isDark() ? Colors.white : Colors.black;

  Color barColor() => backgroundColor().withOpacity(0.7);

  Color textColor() => isDark() ? Colors.white : Colors.black.withOpacity(0.8);

  MelonThemeData of(BuildContext context){
    _mediaQuery = MediaQuery.of(context);
    _brightness = _mediaQuery.platformBrightness;
    return this;
  }

}

class MelonTheme {

  static MelonThemeData of(BuildContext context) {
    return MelonThemeData().of(context);
  }

}



