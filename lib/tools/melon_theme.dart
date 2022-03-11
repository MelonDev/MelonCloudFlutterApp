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

  Color onButtonColor(bool? isHovered) {
    if (isHovered == null) {
      return onColor().withOpacity(0.1);
    } else {
      return isHovered ? onColor().withOpacity(0.3) : onColor().withOpacity(0.1);
    }
  }

  Color onBackButtonColor(bool? isHovered) {
    if (isHovered == null) {
      return Colors.transparent;
    } else {
      return isHovered ? onColor().withOpacity(0.2) : Colors.transparent;
    }
  }


  Color barColor() => backgroundColor().withOpacity(0.7);

  Color textColor() => isDark() ? Colors.white : Colors.black.withOpacity(0.8);

  MelonThemeData of(BuildContext context) {
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



