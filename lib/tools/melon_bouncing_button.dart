import 'package:flutter/material.dart';
import 'package:meloncloud_flutter_app/tools/on_hover.dart';

import 'melon_bounce_widget.dart';

class MelonBouncingButton extends StatelessWidget {
  MelonBouncingButton(
      {this.child,
      this.callback,
      this.active,
      this.isBouncing,
        this.borderRadius,
      this.fakeLongEnable = true});

  Widget? child;

  VoidCallback? callback;
  bool? active;
  bool? isBouncing;
  bool fakeLongEnable;
  double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return MelonBounceWidget(
        borderRadius: borderRadius,
        duration: Duration(
            milliseconds: active != null ? (active! ? 96 : 0) : 96),
        fakeLongEnable: fakeLongEnable,
        onPressed: () {
          if (callback != null) {
            callback?.call();
          }
        },
        scaleFactor: isBouncing != null ? (isBouncing! ? 1.5 : 0) : 1.5,
        child: child);
  }
}
