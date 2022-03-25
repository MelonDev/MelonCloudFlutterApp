import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloncloud_flutter_app/cubit/hashtags/hashtags_cubit.dart';
import 'package:meloncloud_flutter_app/page/error_page.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meloncloud_flutter_app/tools/melon_loading_widget.dart';
import 'package:meloncloud_flutter_app/tools/melon_refresh_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:meloncloud_flutter_app/tools/melon_timeline.dart';
import 'package:routemaster/routemaster.dart';

import '../tools/melon_back_button.dart';
import '../tools/melon_blury_navigation_bar.dart';

class HashtagPreviewPage extends StatefulWidget {
  HashtagPreviewPage({Key? key,required this.name}) : super(key: key);
  String name;
  @override
  _HashtagPreviewPageState createState() => _HashtagPreviewPageState();
}

class _HashtagPreviewPageState extends State<HashtagPreviewPage> {

  MelonThemeData? _theme;
  ScrollController? _contentsScrollController;
  late String name;

  @override
  void initState() {
    super.initState();
    name = Uri.decodeFull(widget.name);
    context.read<HashtagsCubit>().load(context:context, hashtagName: name);

    _contentsScrollController = ScrollController();
    _contentsScrollController?.addListener(_handleOverScroll);
  }

  @override
  void didChangeDependencies() {
    _theme = MelonTheme.of(context);

    super.didChangeDependencies();
  }

  void _handleOverScroll() {
    double pixels = _contentsScrollController!.position.pixels;
    if (pixels == _contentsScrollController!.position.maxScrollExtent) {
      var state = context.read<HashtagsCubit>().state;
      //print(pixels >= _scrollController.position.maxScrollExtent);

      if (state is HashtagsState) {
        int step = (_calculateHeight(state.timeline) / 150).round();
        if (step > 0) {
          context
              .read<HashtagsCubit>()
              .load(context:context,previousState: state, command: "NEXT", hashtagName: name);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HashtagsCubit, HashtagsBaseState>(builder: (context, state) {
      String path = Routemaster.of(context).currentRoute.path;
      if (path == "/hashtags/${widget.name}" && state is! HashtagsState && state is! HashtagsLoadingState && state is! HashtagsFailureState){
        context.read<HashtagsCubit>().load(context:context, hashtagName: name);
      }
      if (state is HashtagsFailureState){
        return ErrorPage(callback: (){
          context.read<HashtagsCubit>().load(context:context, hashtagName: name);
        });
      }
      return Container(
        color: _theme!.backgroundColor(),
        child: Stack(
          children: [_layout(state), _loading(state),MelonBluryNavigationBar.get(context)],
        )
      );
    });
  }


  Widget _layout(state) {
    Map<dynamic, List<dynamic>> data = {};

    if (state is HashtagsState) {
      data = state.timeline;
    }

    if (state is HashtagsLoadingState) {
      if (state.previousState != null) {
        data = state.previousState!.timeline;
      }
    }

    return MelonTimeline(
      scrollController: _contentsScrollController,
      title: name,
      data: data,
      type: TimelineType.grid,
      leadingWidget: MelonBackButton(),
      trailingWidget: _trailing(state),
      headerHeight: 0,
      longActions: null,
      onItemTapping: (value) {
        MelonRouter.push(context: context, path:'/tweets/${value['tweet_id']}');
      },
    );
  }

  Widget _loading(state) {
    if (state is HashtagsLoadingState) {
      if (state.previousState == null) {
        return const MelonLoadingWidget();
      } else {
        return Container();
      }
    } else if (state is! HashtagsLoadingState && state is! HashtagsState) {
      return const MelonLoadingWidget();
    }
    else {
      return Container();
    }
  }

  Widget _trailing(state) {
    return MelonRefreshButton(isLoading: state is HashtagsLoadingState, callback: (){
      if (state is HashtagsState) {
        _scrollToTop(state);
        context.read<HashtagsCubit>().load(context:context, hashtagName: name);
      } else if (state is! HashtagsLoadingState) {
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
                        context.read<HashtagsCubit>().load(
                            context:context,
                            previousState:
                            state is HashtagsState ? state : null, hashtagName: name);
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
    }

    );
  }

  _scrollToTop(state) {
    if (state is HashtagsState) {
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
