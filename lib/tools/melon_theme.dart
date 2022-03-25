import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

@immutable
class MelonThemeData {

  late Brightness _brightness;
  late MediaQueryData _mediaQuery;
  late CupertinoAdaptiveThemeManager _adaptiveTheme;
  late BuildContext _context;

  //bool isDark({Brightness? brightness}) => (brightness ?? _brightness) == Brightness.dark;
  bool isDark({Brightness? brightness}) {
    return (brightness ?? _adaptiveTheme.brightness) == Brightness.dark;
  }

  Size size() => _mediaQuery.size;

  double width() => _mediaQuery.size.width;

  double height() => _mediaQuery.size.height;

  Orientation orientation() => _mediaQuery.orientation;

  Color backgroundColor({Brightness? brightness}) => isDark(brightness: brightness) ? Colors.black : Colors.white;

  Color onColor({Brightness? brightness}) => isDark(brightness: brightness) ? Colors.white : Colors.black;

  Color onButtonColor(bool? isHovered,{Brightness? brightness}) {
    if (isHovered == null) {
      return onColor(brightness: brightness).withOpacity(0.1);
    } else {
      return isHovered ? onColor(brightness: brightness).withOpacity(0.2) : onColor(brightness: brightness).withOpacity(0.1);
    }
  }

  Color onBackButtonColor(bool? isHovered,{Brightness? brightness}) {
    if (isHovered == null) {
      return Colors.transparent;
    } else {
      return isHovered ? onColor(brightness: brightness).withOpacity(0.2) : Colors.transparent;
    }
  }


  Color barColor() => backgroundColor().withOpacity(0.7);

  Color textColor({Brightness? brightness}) => isDark(brightness: brightness) ? Colors.white : Colors.black.withOpacity(0.8);
  Color onErrorColor({Brightness? brightness}) => isDark(brightness: brightness) ? const Color(
      0xffac3131) : const Color(0xfffc9191);


  Color popButtonColor({Brightness? brightness}) => isDark(brightness: brightness) ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(1.0);
  Color popButtonShadowColor({Brightness? brightness}) => isDark(brightness: brightness) ? Colors.white.withOpacity(0.0) : Colors.black.withOpacity(0.2);

  changingTheme({required Brightness brightness}) {
    if (brightness == Brightness.dark){
      _adaptiveTheme.setDark();
    }
    if (brightness == Brightness.light){
      _adaptiveTheme.setLight();
    }
  }

  changingToSystemTheme() {
    _adaptiveTheme.setSystem();
  }

  MelonThemeData of(BuildContext context) {
    _mediaQuery = MediaQuery.of(context);
    //_brightness = _mediaQuery.platformBrightness;
    _adaptiveTheme = CupertinoAdaptiveTheme.of(context);

    _context = context;

    return this;
  }

}

class MelonTheme {

  static MelonThemeData of(BuildContext context) {
    return MelonThemeData().of(context);
  }

}



