import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:meloncloud_flutter_app/tools/on_hover.dart';

class MelonBooksGrid extends StatefulWidget {
  MelonBooksGrid(
      {Key? key,
      required this.timeline,
      this.callback,
      this.topPadding = 12.0,
      this.bottomPadding = 104.0,
      this.children})
      : super(key: key);

  List<dynamic> timeline;
  double topPadding;
  double bottomPadding;
  ValueChanged<dynamic>? callback;
  MelonBooksGridChildren? children;

  @override
  _MelonBooksGridState createState() => _MelonBooksGridState();
}

class _MelonBooksGridState extends State<MelonBooksGrid> {
  late MelonThemeData _theme;
  Map<int, bool> errorMap = {};

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int radio = (width / 300).round();

    _theme = MelonTheme.of(context);

    int total = widget.timeline.length;
    int sub = total % radio;

    return SliverPadding(
      padding: EdgeInsets.only(
          top: widget.topPadding,
          bottom: widget.bottomPadding,
          left: 8.0,
          right: 8.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, position) {
            String url = widget.timeline[position]['cover'];
            return _content(position, total, sub, radio);
          },
          childCount: widget.timeline.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: radio,
          childAspectRatio: 1.6,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _content(position, total, sub, radio) {
    List<Widget> children =
        widget.children != null ? widget.children!.call(position, radio) : [];

    String url = "assets/preview.png";
    url = widget.timeline[position]['cover'];
    //print(sub);

    return OnHover(
      builder: (bool isHovered) {
        return MelonBouncingButton(
          callback: () {
            if (errorMap[position] == null) {
              if (widget.callback != null) {
                widget.callback?.call(widget.timeline[position]);
              }
            }
          },
          //fakeLongEnable: widget.fakeLongEnable,
          active: errorMap[position] == null,
          isBouncing: errorMap[position] == null,
          child: Container(
            margin: const EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
              decoration: BoxDecoration(
                //color: Colors.red,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _theme.onColor().withOpacity(_theme.isDark() ? 0.0 :0.1),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: widget.children != null
                        ? children
                        : [
                            FadeInImage.assetNetwork(
                              placeholder: _theme.isDark()
                                  ? 'assets/white_loading.gif'
                                  : 'assets/black_loading.gif',
                              fadeInDuration: const Duration(milliseconds: 200),
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
                          ],
                  ))),
        );
      },
    );
  }
}

typedef MelonBooksGridChildren = List<Widget> Function(int position, int radio);
