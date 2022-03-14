import 'package:flutter/material.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:meloncloud_flutter_app/tools/on_hover.dart';
import 'package:routemaster/routemaster.dart';

class MelonIconButton extends StatelessWidget {
  MelonIconButton({Key? key, required this.icon,this.callback, this.brightness}) : super(key: key);

  VoidCallback? callback;
  IconData? icon;
  late MelonThemeData _theme;
  Brightness? brightness;

  @override
  Widget build(BuildContext context) {
    _theme = MelonTheme.of(context);
    return _container(context);
  }

  Widget _container(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: OnHover(
              x: 2.0,
              y: 3.0,
              z: 0.84,
              disableScale: false,
              builder: (isHovered) {
                return MelonBouncingButton(
                  callback: () {
                    callback?.call();
                  },
                  isBouncing: true,
                  child: Container(
                    width: 42,
                    height: 32,
                    padding: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                        color: _theme.onButtonColor(isHovered,
                            brightness: brightness),
                        //border: Border.all(color: _theme.textColor()),
                        borderRadius: BorderRadius.circular(60)),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon,
                                  color:
                                      _theme.textColor(brightness: brightness),
                                  size: 22),
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
