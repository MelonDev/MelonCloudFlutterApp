import 'package:auto_size_text/auto_size_text.dart';
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
    this.headerPadding,
    this.middle
  }) : super(key: key);

  ScrollController? scrollController;
  Widget? leadingWidget;
  Widget? trailingWidget;
  VoidCallback? titleOnTap;
  String? title;
  Widget? sliverLayout;
  Widget? header;
  String? middle;
  EdgeInsetsGeometry? headerPadding;

  @override
  _MelonTemplateState createState() => _MelonTemplateState();
}

class _MelonTemplateState extends State<MelonTemplate> {
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
          automaticallyImplyTitle: true,
          middle: widget.middle != null ? Text(
            widget.middle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.itim(
                color: _theme.isDark()
                    ? Colors.white.withOpacity(1)
                    : Colors.black.withOpacity(1)),
          ) : null,
          largeTitle: MelonBouncingButton(
            isBouncing: widget.titleOnTap != null,
            callback: widget.titleOnTap,
            child: AutoSizeText(
              widget.title ?? "",
              maxFontSize: 36,
              minFontSize: 30,
              maxLines: 1,
              style: GoogleFonts.itim(
                  color: _theme.isDark()
                      ? Colors.white.withOpacity(1)
                      : Colors.black.withOpacity(1)),
            ),
          ),
        ),
        widget.header != null
            ? SliverPadding(
                padding: widget.headerPadding ?? const EdgeInsets.only(left: 16, right: 16, top: 10),
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
