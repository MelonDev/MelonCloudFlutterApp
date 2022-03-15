import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';

import 'melon_bouncing_button.dart';

class MelonTemplate extends StatefulWidget {
  MelonTemplate({
    Key? key,
    this.scrollController,
    this.leadingWidget,
    this.trailingWidget,
    this.title,
    this.titleOnTap,
    this.sliverLayout,
    this.header,
  }) : super(key: key);

  ScrollController? scrollController;
  Widget? leadingWidget;
  Widget? trailingWidget;
  VoidCallback? titleOnTap;
  String? title;
  Widget? sliverLayout;
  Widget? header;

  @override
  _MelonTemplateState createState() => _MelonTemplateState();
}

class _MelonTemplateState extends State<MelonTemplate> {
  late Brightness _brightness;
  late bool _darkModeOn;

  late Color _borderColor;
  late Color _barColor;

  bool shouldLoadMore = true;

  @override
  void initState() {
    super.initState();

    _borderColor = Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    _brightness = MediaQuery.of(context).platformBrightness;
    _darkModeOn = _brightness == Brightness.dark;
    MelonThemeData _theme = MelonTheme.of(context);
    _barColor = (_theme.isDark() ? const Color.fromARGB(0, 25, 25, 25) : const Color.fromARGB(0, 240, 240, 240)).withOpacity(0.7);

    return CustomScrollView(
      controller: widget.scrollController ?? ScrollController(),
      physics: BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverNavigationBar(
          border: Border(bottom: BorderSide(color: _borderColor)),
          backgroundColor: _barColor,
          leading: widget.leadingWidget,
          trailing: widget.trailingWidget,
          largeTitle: MelonBouncingButton(
            isBouncing: widget.titleOnTap != null,
            callback: widget.titleOnTap,
            child: Text(
              widget.title ?? "",
              style: GoogleFonts.itim(
                  color: _darkModeOn
                      ? Colors.white.withOpacity(1)
                      : Colors.black.withOpacity(1)),
            ),
          ),
        ),
        widget.header != null
            ? SliverPadding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                  return widget.header;
                }, childCount: 1)),
              )
            : SliverPadding(padding: EdgeInsets.all(0)),
        _silverContainer()
      ],
    );
  }

  Widget _silverContainer() {
    return widget.sliverLayout ??
        const SliverPadding(padding: EdgeInsets.all(0));
  }
}
