import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'melon_bouncing_button.dart';
import 'melon_theme.dart';
import 'on_hover.dart';

class MelonSliverList extends StatefulWidget {
  MelonSliverList(this.listData,
      {Key? key,
      this.floatingWidget,
      this.cardTapping,
      this.limitWidth,
      this.bottomPadding = 104.0})
      : super(key: key);

  ValueChanged<dynamic>? cardTapping;
  List<dynamic> listData;
  Widget? floatingWidget;
  double bottomPadding;
  int? limitWidth;

  @override
  _MelonSliverListState createState() => _MelonSliverListState();
}

class _MelonSliverListState extends State<MelonSliverList> {
  late MelonThemeData _theme;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Map<int, bool> errorMap = {};

    _theme = MelonTheme.of(context);
    int total = widget.listData.length;

    return SliverPadding(
      padding: EdgeInsets.only(
          top: 4.0, bottom: widget.bottomPadding, left: 4.0, right: 4.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (MediaQuery.of(context).size.width > 500) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Container(width: 500, child: _content(index))],
              );
            } else {
              return _content(index);
            }
          },
          childCount: total, // 1000 list items
        ),
      ),
    );
  }

  Widget _content(int index) {
    return OnHover(
      x: 16,
      y: 2,
      builder: (bool isHovered) {
        return Container(
          margin: const EdgeInsets.only(top: 16, left: 12, right: 12),
          child: MelonBouncingButton(
            active: widget.cardTapping != null,
            callback: () {
              widget.cardTapping?.call(index);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isHovered
                    ? _theme.onColor().withOpacity(0.15)
                    : _theme.onColor().withOpacity(0.06),
              ),
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 16, bottom: 16),
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "#${widget.listData[index]['name']}",
                          style: GoogleFonts.itim(
                              color: _theme.textColor(),
                              fontSize: 26,
                              fontWeight: FontWeight.normal),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "จำนวน  ${NumberFormat.decimalPattern().format(widget.listData[index]['value'])}  แท็ก",
                          style: GoogleFonts.itim(
                              color: _theme.textColor().withOpacity(0.7),
                              fontSize: 20,
                              fontWeight: FontWeight.normal),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
