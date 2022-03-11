import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meloncloud_flutter_app/tools/melon_activity_indicator.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:meloncloud_flutter_app/tools/on_hover.dart';

class MelonRefreshButton extends StatelessWidget {
  MelonRefreshButton({Key? key, required this.isLoading, this.callback})
      : super(key: key);

  late MelonThemeData _theme;
  bool isLoading;
  VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    _theme = MelonTheme.of(context);
    return OnHover(
      disableScale: true,
      builder: (isHovered) {
        return MelonBouncingButton(
          callback: callback,
          isBouncing: !isLoading,
          child: Container(
            width: isLoading ? 130 : 80,
            height: 32,
            decoration: BoxDecoration(
                color: isLoading
                    ? CupertinoTheme.of(context).primaryColor.withOpacity(0.8)
                    : _theme.onButtonColor(isHovered),
                borderRadius: BorderRadius.circular(30)),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isLoading
                          ? CupertinoTheme(
                              data: CupertinoTheme.of(context).copyWith(),
                              child: const MelonActivityIndicator())
                          : Container(),
                      SizedBox(
                        width: isLoading ? 6 : 0,
                      ),
                      Text(
                        isLoading ? 'กำลังโหลด..' : 'รีเฟรช',
                        style: GoogleFonts.itim(
                            color:
                                isLoading ? Colors.white : _theme.onColor()),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
