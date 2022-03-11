import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:meloncloud_flutter_app/tools/melon_activity_indicator.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/on_hover.dart';
import 'package:routemaster/routemaster.dart';

import 'melon_theme.dart';

class MelonBackButton extends StatelessWidget {
  MelonBackButton({
    Key? key,
    this.callback,
  }) : super(key: key);

  VoidCallback? callback;
  late MelonThemeData _theme;

  @override
  Widget build(BuildContext context) {
    _theme = MelonTheme.of(context);
    return _melonStyle(context);
  }

  Widget _melonStyle(BuildContext context){
    return Container(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: OnHover(
              disableScale: true,
              builder: (isHovered) {
                return MelonBouncingButton(
                  callback: () {
                    Routemaster.of(context).pop();
                  },
                  isBouncing: true,
                  child: Container(
                    width: 42,
                    height: 32,
                    padding: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                        color: _theme.onButtonColor(isHovered),
                        //border: Border.all(color: _theme.textColor()),
                        borderRadius: BorderRadius.circular(60)),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Ionicons.chevron_back,
                                  color: _theme.textColor(), size: 22),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _iosStyle(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: OnHover(
              disableScale: true,
              builder: (isHovered) {
                return MelonBouncingButton(
                  callback: () {
                    Routemaster.of(context).pop();
                  },
                  isBouncing: true,
                  child: Container(
                    width: 80,
                    height: 32,
                    padding: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                        color: _theme.onBackButtonColor(isHovered),
                        //border: Border.all(color: _theme.textColor()),
                        borderRadius: BorderRadius.circular(30)),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Ionicons.chevron_back,
                                  color: _theme.textColor(), size: 22),
                              Text(
                                "กลับ",
                                style: GoogleFonts.itim(
                                    color: _theme.textColor(),
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
