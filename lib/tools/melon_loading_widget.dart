import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import 'melon_theme.dart';

class MelonLoadingWidget extends StatelessWidget {
  const MelonLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MelonThemeData _theme = MelonTheme.of(context);
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 150,
        height: 150,
        child: Column(
          children: [
            Icon(
              Ionicons.cloud_download_outline,
              size: 100,
              color: _theme.textColor().withOpacity(0.9),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "กำลังโหลด..",
              style: GoogleFonts.itim(
                  fontSize: 24, color: _theme.textColor().withOpacity(0.9)),
            )
          ],
        ),
      ),
    );
  }
}
