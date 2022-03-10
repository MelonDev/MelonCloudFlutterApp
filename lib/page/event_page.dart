import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meloncloud_flutter_app/tools/melon_activity_indicator.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_timeline.dart';
import 'package:routemaster/routemaster.dart';

import '../cubit/main/main_cubit.dart';
import '../tools/melon_theme.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  MelonThemeData? _theme;

  ScrollController? _contentsScrollController;

  @override
  void initState() {
    super.initState();
    _contentsScrollController = ScrollController();
    _contentsScrollController?.addListener(_handleOverScroll);
  }

  @override
  void didChangeDependencies() {
    _theme = MelonTheme.of(context);
    var state = context.read<MainCubit>().state;
    if (!(state is MainEventLoadingState || state is MainEventState)) {
      context.read<MainCubit>().event();
    }
    super.didChangeDependencies();
  }

  void _handleOverScroll() {
    double pixels = _contentsScrollController!.position.pixels;
    if (pixels == _contentsScrollController!.position.maxScrollExtent) {
      var state = context.read<MainCubit>().state;
      //print(pixels >= _scrollController.position.maxScrollExtent);

      if (state is MainEventState) {
        int step = (_calculateHeight(state.timeline) / 150).round();
        if (step > 0) {
          context
              .read<MainCubit>()
              .event(previousState: state, command: "NEXT");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(builder: (context, state) {
      return Stack(
        children: [_layout(state), _loading(state)],
      );
    });
  }

  Widget _layout(state) {
    Map<dynamic, List<dynamic>> data = {};

    if (state is MainEventState) {
      data = state.timeline;
    }

    if (state is MainEventLoadingState) {
      if (state.previousState != null) {
        data = state.previousState!.timeline;
      }
    }

    return MelonTimeline(
      scrollController: _contentsScrollController,
      title: "อีเวนท์",
      data: data,
      type: TimelineType.grid,
      trailingWidget: _trailing(state),
      headerHeight: 0,
      longActions: null,
      onItemTapping: (value) {
        Routemaster.of(context).push('/tweets/${value['tweet_id']}');
      },
    );
  }

  Widget _loading(state) {
    if (state is MainEventLoadingState) {
      if (state.previousState == null) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            width: 150,
            height: 150,
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.cloud,
                  size: 100,
                  color: _theme?.textColor().withOpacity(0.9),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "กำลังโหลด..",
                  style: GoogleFonts.itim(
                      fontSize: 24,
                      color: _theme?.textColor().withOpacity(0.9)),
                )
              ],
            ),
          ),
        );
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  Widget _trailing(state) {
    return Container(
      child: MelonBouncingButton(
        callback: () {
          if (state is MainEventState) {
            _scrollToTop(state);
            context.read<MainCubit>().event();
          } else if (state is! MainEventLoadingState) {
            showCupertinoDialog(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoAlertDialog(
                    title: const Text("ยืนยันการรีเฟรช"),
                    content: const Text(
                        "พบการโหลดข้อมูลหน้าอื่นอยู่เบื้องหลังหรือไม่ก็่หน้าต่างปัจจุบันอยู่ในตำแหน่งไม่ตรง คุณต้องการยืนยันหรือไม่?"),
                    actions: [
                      CupertinoDialogAction(
                          child: const Text("ยืนยัน"),
                          isDefaultAction: true,
                          isDestructiveAction: true,
                          onPressed: () {
                            context.read<MainCubit>().event(
                                previousState:
                                    state is MainEventState ? state : null);
                            Navigator.of(context).pop();
                          }),
                      CupertinoDialogAction(
                          child: const Text("ยกเลิก"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          })
                    ],
                  );
                },
                barrierDismissible: false);
          }
        },
        isBouncing: state is! MainEventLoadingState,
        child: Container(
          width: state is MainEventLoadingState ? 130 : 80,
          height: 32,
          decoration: BoxDecoration(
              color: state is MainEventLoadingState
                  ? CupertinoTheme.of(context).primaryColor.withOpacity(0.8)
                  : _theme?.onColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(30)),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    state is MainEventLoadingState
                        ? CupertinoTheme(
                            data: CupertinoTheme.of(context).copyWith(),
                            child: MelonActivityIndicator())
                        : Container(),
                    SizedBox(
                      width: state is MainEventLoadingState ? 6 : 0,
                    ),
                    Text(
                      state is MainEventLoadingState ? 'กำลังโหลด..' : 'รีเฟรช',
                      style: GoogleFonts.itim(
                          color: state is MainEventLoadingState
                              ? Colors.white
                              : _theme?.onColor()),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _scrollToTop(state) {
    if (state is MainEventState) {
      if (_calculateHeight(state.timeline) <= state.timeline.length) {
        if (_contentsScrollController!.hasClients) {
          if (_contentsScrollController!.offset > 10) {
            _contentsScrollController!
                .animateTo(-100,
                    duration: const Duration(seconds: 1), curve: Curves.linear)
                .whenComplete(() {});
          }
        }
      }
    }
  }

  _calculateHeight(Map<dynamic, List<dynamic>>? map) {
    int count = 0;

    for (List<dynamic> value in map!.values) {
      count += value.length;
    }
    return count;
  }
}
