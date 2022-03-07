import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MelonLoadingSliverGrid extends StatefulWidget {
  MelonLoadingSliverGrid( {Key? key}) : super(key: key);

  @override
  _MelonLoadingSliverGridState createState() => _MelonLoadingSliverGridState();
}

class _MelonLoadingSliverGridState extends State<MelonLoadingSliverGrid> {
  @override
  Widget build(BuildContext context) {
    Brightness _brightness = MediaQuery.of(context).platformBrightness;
    bool _darkModeOn = _brightness == Brightness.dark;

    return SliverPadding(
      padding: EdgeInsets.all(0),
    );
  }
}
