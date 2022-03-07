import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'melon_bouncing_button.dart';
import 'melon_theme.dart';

class MelonSliverList extends StatefulWidget {
  MelonSliverList(this.listData,
      {Key? key,
      this.floatingWidget,
      this.cardTapping,
      this.bottomPadding = 104.0})
      : super(key: key);

  ValueChanged<dynamic>? cardTapping;
  List<dynamic> listData;
  Widget? floatingWidget;
  double bottomPadding;

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
            return Container(
              margin: EdgeInsets.only(top: 16, left: 12, right: 12),
              child: MelonBouncingButton(
                active: widget.cardTapping != null,
                callback: (){
                  widget.cardTapping?.call(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _theme.onColor().withOpacity(0.06),
                  ),
                  padding:
                  EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 16),
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
                                  color: _theme.textColor(), fontSize: 26,fontWeight: FontWeight.normal),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "จำนวน  ${NumberFormat.decimalPattern().format(widget.listData[index]['value'])}  แท็ก",
                              style: GoogleFonts.itim(
                                  color: _theme.textColor().withOpacity(0.7), fontSize: 20,fontWeight: FontWeight.normal),
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
          childCount: total, // 1000 list items
        ),
      ),
    );
  }
}
