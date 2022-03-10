import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meloncloud_flutter_app/extensions/buddhist_datetime_dateformat.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';

import 'melon_bouncing_button.dart';
import 'melon_sliver_grid.dart';
import 'melon_sticky_list_view.dart';

import 'melon_theme.dart';

enum TimelineType { list, grid }

class MelonTimeline extends StatefulWidget {
  MelonTimeline(
      {Key? key,
      this.scrollController,
      this.leadingWidget,
      this.trailingWidget,
      this.title,
      this.titleOnTap,
      this.data,
      this.onItemTapping,
      this.disableAppbar = false,
      this.headerHeight,
      this.headerItemHeight,
      this.longActions,
      this.header,
      this.navigationBarColor,
      this.fakeLongEnable = true,
      @required this.type})
      : super(key: key);

  ScrollController? scrollController;
  Widget? leadingWidget;
  Widget? trailingWidget;
  ValueChanged<double>? titleOnTap;
  String? title;
  bool? disableAppbar;
  Color? navigationBarColor;
  Map<dynamic, List<dynamic>>? data;
  ValueChanged<dynamic>? onItemTapping;
  TimelineType? type;
  MelonContextMenuActionListFunction? longActions;
  bool? fakeLongEnable;

  double? headerHeight;
  double? headerItemHeight;
  Widget? header;

  @override
  _MelonTimelineState createState() => _MelonTimelineState();
}

class _MelonTimelineState extends State<MelonTimeline> {
  late MelonThemeData _theme;

  @override
  Widget build(BuildContext context) {
    _theme = MelonTheme.of(context);

    Widget Function(BuildContext context, List<dynamic> items)? body;

    if (widget.type == TimelineType.grid) {
      body = (context, items) => MelonSliverGrid(
            items,
            bottomPadding: 4.0,
            fakeLongEnable: widget.fakeLongEnable!,
            gridTapping: widget.onItemTapping,
            longActions: widget.longActions,
          );
    }

    return SafeArea(
        top: false,
        bottom: false,
        child: MelonStickyListView(
          controller: widget.scrollController,
          physics: const BouncingScrollPhysics(),
          data: widget.data ?? {},
          appBar: widget.disableAppbar! ? null : _appbar(),
          bodyHeaderMinHeight: 72.0,
          bodyHeaderMaxHeight: 96.0,
          bodyHeaderPinned: false,
          bodyHeaderFloating: false,
          bodyHeaderBuilder: (_, value) =>
              body != null ? _head(value) : Container(),
          bodyBuilder:
              body ?? (_, item) => const SliverPadding(padding: EdgeInsets.all(0)),
          footer: _footer(),
          header: _header(),
        ));
  }

  Widget _head(value) {
    DateTime tempDate = DateFormat("yyyy-MM-dd").parse(value);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    var formatterFull = DateFormat("d MMMM yyyy");
    String dateInBuddhistCalendarFormat =
        formatterFull.formatInBuddhistCalendarThai(tempDate);
    var formatterDay = DateFormat("EEEE");
    String dayInBuddhistCalendarFormat = formatterDay
        .formatInBuddhistCalendarThai(tempDate)
        .replaceAll("วัน", "");

    if (tempDate == today) {
      dayInBuddhistCalendarFormat = "วันนี้";
    }
    if (tempDate == yesterday) {
      dayInBuddhistCalendarFormat = "เมื่อวาน";
    }

    return Container(
      padding: const EdgeInsets.only(left: 20, bottom: 0),
      //margin: EdgeInsets.only(bottom: 6),
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:200,
            child: Text(
              dayInBuddhistCalendarFormat,
              style: GoogleFonts.itim(color: _theme.textColor(), fontSize: 32),
            )
          ),
          Text(
            dateInBuddhistCalendarFormat,
            style: GoogleFonts.itim(
                color: _theme.textColor().withOpacity(0.65), fontSize: 18),
          ),
          const SizedBox(
            height: 8,
          )
        ],
      ),
      color: Colors.transparent,
    );
  }

  Widget _appbar() {
    bool isMacOS = false;

    if (!kIsWeb) {
      isMacOS = Platform.isMacOS;
    }

    return CupertinoSliverNavigationBar(
      //padding: EdgeInsetsDirectional.only(top: isMacOS ? 0 :0,start: 20,end: 20),
      border: Border(bottom: BorderSide(color: _theme.isDark() ? Color.fromARGB(80, 50, 50, 50) : Color.fromARGB(80, 200, 200, 200))),
      backgroundColor: widget.navigationBarColor ??
          (_theme.isDark() ? const Color.fromARGB(0, 25, 25, 25) : const Color.fromARGB(0, 240, 240, 240)).withOpacity(0.7),
      //backgroundColor: Colors.white.withOpacity(0.07),
      brightness: _theme.isDark() ? Brightness.dark : Brightness.light,
      //backgroundColor: CupertinoDynamicColor.withBrightness(color: Colors.red, darkColor: Colors.green),
      leading: _leading(),
      trailing: widget.trailingWidget,
      largeTitle: MelonBouncingButton(
        isBouncing: true,
        callback: () {
          if (widget.titleOnTap != null){
            widget.titleOnTap?.call(widget.scrollController!.offset);
          }else {
            widget.scrollController?.animateTo(-100,
                duration: Duration(milliseconds: 500), curve: Curves.linear);
          }
        },
        child: Text(
          widget.title ?? "",
          style: GoogleFonts.itim(color: _theme.textColor()),
        ),
      ),
    );
  }

  Widget _leading() {
    return Container(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: widget.leadingWidget,
          )
        ],
      ),
    );
  }

  Widget _footer() {
    return SliverFixedExtentList(
      itemExtent: 106,
      delegate: SliverChildListDelegate(
        [
          Container(),
        ],
      ),
    );
  }

  Widget _header() {
    //print(widget.headerHeight);
    //print(widget.headerItemHeight ?? 0);
    //print(widget.headerHeight != null ? (widget.headerHeight + (widget.headerItemHeight ?? 0)) : 0);
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      if (index == 0) {
        return Container(
          height: widget.headerHeight ?? 0,
        );
      } else if (index == 1) {
        return widget.header;
      } else {
        return Container();
      }
    }, childCount: 1 + (widget.header != null ? 1 : 0)));
  }
}
