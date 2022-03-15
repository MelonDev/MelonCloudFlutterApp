import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:routemaster/routemaster.dart';

import '../main.dart';
import '../tools/melon_refresh_button.dart';
import '../tools/melon_theme.dart';

class ErrorPage extends StatelessWidget {
  ErrorPage({Key? key, required this.callback}) : super(key: key);
  VoidCallback callback;
  @override
  Widget build(BuildContext context) {
    MelonThemeData _theme = MelonTheme.of(context);
    return Container(
      color: _theme.onErrorColor(),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 150,
              height: 200,
              child: Column(
                children: [
                  Icon(
                    Ionicons.cloud_offline_outline,
                    size: 100,
                    color: _theme.textColor().withOpacity(0.9),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "เกิดข้อผิดพลาด",
                    style: GoogleFonts.itim(
                        fontSize: 24,
                        color: _theme.textColor().withOpacity(0.9)),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MelonRefreshButton(isLoading: false,callback: callback,)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
