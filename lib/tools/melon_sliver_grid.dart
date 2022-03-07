import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meloncloud_flutter_app/tools/melon_context_menu_action.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';

import 'melon_bouncing_button.dart';
import 'melon_theme.dart';

class MelonSliverGrid extends StatefulWidget {
  MelonSliverGrid(this.listData,
      {Key? key,
      this.floatingWidget,
      this.gridTapping,
      this.longActions,
      this.fakeLongEnable = true,
      this.fixWidth = 130,
      this.child,
      this.children,
      this.topPadding = 4.0,
      this.bottomPadding = 104.0})
      : super(key: key);

  ValueChanged<dynamic>? gridTapping;
  List<dynamic> listData;
  Widget? floatingWidget;
  double topPadding;

  double bottomPadding;
  double fixWidth;
  MelonContextMenuActionListFunction? longActions;
  bool fakeLongEnable;
  Widget? child;
  MelonSliverGridChildren? children;

  @override
  _MelonSliverGridState createState() => _MelonSliverGridState();
}

class _MelonSliverGridState extends State<MelonSliverGrid> {
  late MelonThemeData _theme;

  Map<int, bool> errorMap = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int radio = (width / widget.fixWidth).round();

    _theme = MelonTheme.of(context);

    int total = widget.listData.length;
    int sub = total % radio;

    return SliverPadding(
      padding: EdgeInsets.only(
          top: widget.topPadding,
          bottom: widget.bottomPadding,
          left: 4.0,
          right: 4.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, position) {
            if (widget.longActions != null) {
              return CupertinoContextMenu(
                actions: widget.longActions!.call(widget.listData[position]),
                previewBuilder: (context, animation, child) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: _theme.width(),
                        height: _theme.width() * 0.7,
                        color: _theme.backgroundColor().withOpacity(0.8),
                        child: FadeInImage.assetNetwork(
                          placeholder: _theme.isDark() ? 'assets/white_loading.gif' : 'assets/black_loading.gif',
                          fadeInDuration: const Duration(milliseconds: 300),
                          image: widget.listData[position]['url']
                              .toString()
                              .replaceAll(":thumb", ":small"),
                          imageErrorBuilder: (BuildContext context,
                              Object exception, StackTrace? stackTrace) {
                            errorMap[position] = true;

                            return Container(
                              color: _theme.onColor().withOpacity(0.2),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.xmark_seal_fill,
                                    color: _theme.textColor(),
                                    size: 50,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "ไม่พบข้อมูล",
                                    style: GoogleFonts.itim(
                                        color: _theme.textColor()),
                                  )
                                ],
                              ),
                            );
                          },
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                  return Container(
                    width: _theme.width(),
                    height: _theme.width() * 0.8,
                    color: Colors.red,
                  );
                  //return child;
                },
                child: _button(position, total, sub, radio),
              );
            } else {
              return _button(position, total, sub, radio);
            }
          },
          childCount: widget.listData.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: radio,
          childAspectRatio: 1.0,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _button(position, total, sub, radio) {
    List<Widget> children =
        widget.children != null ? widget.children!.call(position) : [];

    String url = "assets/preview.png";

    if (widget.listData[position]['type'] == "PHOTO") {
      url = widget.listData[position]['url'];
    }
    if (widget.listData[position]['type'] == "VIDEO") {
      url = widget.listData[position]['thumbnail'];
    }

    //print(sub);

    return MelonBouncingButton(
      callback: () {
        if (errorMap[position] == null) {
          if (widget.gridTapping != null) {
            widget.gridTapping?.call(widget.listData[position]);
          }
        }
      },
      fakeLongEnable: widget.fakeLongEnable,
      active: errorMap[position] == null,
      isBouncing: errorMap[position] == null,
      child: widget.child ??
          ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(position == 0 ? 24 : 6),
                topRight: Radius.circular(position ==
                        (widget.listData.length > 1
                            ? (widget.listData.length >= radio
                                ? (radio - 1)
                                : (radio - (radio - 1)))
                            : 0)
                    ? 24
                    : 6),
                bottomLeft: Radius.circular(
                    position == (total - (sub != 0 ? sub : radio)) ? 24 : 6),
                bottomRight: Radius.circular(
                    position == (total - sub - 1) || position == total - 1
                        ? 24
                        : 6),
              ),

              //borderRadius: BorderRadius.circular(0),
              child: Stack(
                fit: StackFit.expand,
                children: widget.children != null
                    ? children
                    : [
                        FadeInImage.assetNetwork(
                          placeholder: _theme.isDark() ? 'assets/white_loading.gif' : 'assets/black_loading.gif',
                          fadeInDuration: Duration(milliseconds: 300),
                          image: url,
                          imageErrorBuilder: (BuildContext context,
                              Object exception, StackTrace? stackTrace) {
                            errorMap[position] = true;

                            return Container(
                              color: _theme.onColor().withOpacity(0.2),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.xmark_seal_fill,
                                    color: _theme.textColor(),
                                    size: 50,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "ไม่พบข้อมูล",
                                    style: GoogleFonts.itim(
                                        color: _theme.textColor()),
                                  )
                                ],
                              ),
                            );
                          },
                          fit: BoxFit.cover,
                        ),
                        widget.listData[position]['type'] == "VIDEO"
                            ? Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  margin: EdgeInsets.only(left: 6, bottom: 6),
                                  child: Icon(
                                    CupertinoIcons.videocam_circle_fill,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              )
                            : Container()
                      ],
              )),
    );
  }
}

typedef MelonSliverGridChildren = List<Widget> Function(int position);

typedef MelonContextMenuActionListFunction = List<Widget> Function(
    dynamic data);
