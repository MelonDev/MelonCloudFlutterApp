import 'dart:io';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';

class MelonBluryNavigationBar {
  static Widget get(BuildContext context, {Brightness? brightness}) {

    MelonThemeData theme = MelonTheme.of(context);

    bool isActiveBlurNavigationBar = false;
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        isActiveBlurNavigationBar = true;
      }
    }

    return isActiveBlurNavigationBar
        ? Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).padding.bottom,
              width: MediaQuery.of(context).size.width,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(
                    color: theme.isDark(brightness: brightness) ? Colors.black.withOpacity(0.5) :Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          )
        : Container();
  }
}
