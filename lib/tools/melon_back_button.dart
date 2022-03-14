import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meloncloud_flutter_app/tools/melon_activity_indicator.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_icon_button.dart';
import 'package:meloncloud_flutter_app/tools/on_hover.dart';
import 'package:routemaster/routemaster.dart';

import 'melon_theme.dart';

class MelonBackButton extends StatelessWidget {
  MelonBackButton({
    Key? key,
    this.callback,
    this.brightness

  }) : super(key: key);

  VoidCallback? callback;
  late MelonThemeData _theme;
  Brightness? brightness;

  @override
  Widget build(BuildContext context) {
    _theme = MelonTheme.of(context);
    return MelonIconButton(icon: Ionicons.chevron_back,callback: (){
      MelonRouter.pop(context: context);
    });
  }

}
