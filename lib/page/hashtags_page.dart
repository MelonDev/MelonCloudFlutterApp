import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meloncloud_flutter_app/cubit/main/main_cubit.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meloncloud_flutter_app/tools/melon_activity_indicator.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_loading_sliver_grid.dart';
import 'package:meloncloud_flutter_app/tools/melon_loading_widget.dart';
import 'package:meloncloud_flutter_app/tools/melon_refresh_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_sliver_list.dart';
import 'package:meloncloud_flutter_app/tools/melon_template.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:routemaster/routemaster.dart';

import '../tools/melon_blury_navigation_bar.dart';
import '../tools/on_hover.dart';
import 'error_page.dart';

class HashtagsPage extends StatefulWidget {
  const HashtagsPage({Key? key}) : super(key: key);

  @override
  _HashtagsPageState createState() => _HashtagsPageState();
}

class _HashtagsPageState extends State<HashtagsPage> {
  ScrollController? _scrollController;
  MelonThemeData? _theme;
  int segmentedControlGroupValue = 0;
  Map<int, Widget> myTabs = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController!.addListener(_handleOverScroll);
  }

  @override
  void didChangeDependencies() {
    _theme = MelonTheme.of(context);

    super.didChangeDependencies();
  }

  void _handleOverScroll() {
    double pixels = _scrollController!.position.pixels;
    if (pixels == _scrollController!.position.maxScrollExtent) {
      var state = context.read<MainCubit>().state;
      //print(pixels >= _scrollController.position.maxScrollExtent);

      if (state is MainHashtagState) {
        int step = (state.timeline.length / 10).round();
        if (step > 0) {
          context.read<MainCubit>().hashtag(
              context: context,
              previousState: state,
              query: state.query,
              command: "NEXT");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _tabState();

    return BlocBuilder<MainCubit, MainState>(builder: (context, state) {
      String path = Routemaster.of(context).currentRoute.path;
      if (path == "/tags" &&
          state is! MainHashtagState &&
          state is! MainHashtagLoadingState &&
          state is! MainHashtagFailureState) {
        context.read<MainCubit>().hashtag(context: context);
      }
      if (state is MainHashtagFailureState) {
        return ErrorPage(callback: () {
          context.read<MainCubit>().hashtag(context: context);
        });
      }
      return Container(
        color: _theme!.backgroundColor(),
          child: Stack(
        fit: StackFit.loose,
        children: [_timeline(state), _loading(state)],
      ));
    });
  }

  void _tabState() {
    if (myTabs.isNotEmpty) {
      myTabs.clear();
    }
    myTabs = <int, Widget>{
      0: _tabItem("ทั้งหมด", isEnable: segmentedControlGroupValue == 0),
      1: _tabItem("สัปดาห์", isEnable: segmentedControlGroupValue == 1),
      2: _tabItem("เดือน", isEnable: segmentedControlGroupValue == 2),
      3: _tabItem("ไตรมาส", isEnable: segmentedControlGroupValue == 3)
    };
  }

  Widget _loading(state) {
    if (state is MainHashtagLoadingState) {
      if (state.previousState == null) {
        return const MelonLoadingWidget();
      } else {
        return Container();
      }
    } else if (state is! MainHashtagLoadingState &&
        state is! MainHashtagState) {
      return const MelonLoadingWidget();
    } else {
      return Container();
    }
  }

  Widget _area(state) {
    if (MediaQuery.of(context).size.width > 500) {
      return Stack(fit: StackFit.expand, children: [
        Align(
            alignment: Alignment.topCenter,
            child: Container(width: 500, child: _timeline(state)))
      ]);
    } else {
      return _timeline(state);
    }
  }

  Widget _timeline(state) {
    return SafeArea(
        top: false,
        bottom: false,
        child: MelonTemplate(
          title: "แท็ก",
          titleOnTap: () {
            _scrollController?.animateTo(-100,
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear);
          },
          header: MediaQuery.of(context).size.width > 500
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_segmentedControl(state)],
                )
              : _segmentedControl(state),
          trailingWidget: MelonRefreshButton(
              isLoading: state is MainHashtagLoadingState,
              callback: () {
                context.read<MainCubit>().hashtag(
                    context: context,
                    query: _getQueryCommand(segmentedControlGroupValue));
              }),
          scrollController: _scrollController,
          sliverLayout: _contentState(state),
        ));
  }

  Widget _segmentedControl(state) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width > 500
          ? 500
          : MediaQuery.of(context).size.width,
      child: CupertinoSlidingSegmentedControl(
          thumbColor: _theme!.textColor().withOpacity(0.7),
          //thumbColor: CupertinoColors.systemYellow,
          padding: const EdgeInsets.all(4),
          groupValue: segmentedControlGroupValue,
          children: myTabs,
          onValueChanged: (int? i) {
            if (state is MainHashtagState) {
              setState(() {
                segmentedControlGroupValue = i ?? 0;
              });
              context
                  .read<MainCubit>()
                  .hashtag(context: context, query: _getQueryCommand(i ?? 0));
            }
          }),
    );
  }

  Widget _contentState(state) {
    List<dynamic> data = [];
    if (state is MainHashtagState) {
      data = state.timeline;
    }
    if (state is MainHashtagLoadingState) {
      if (state.previousState != null) {
        data = state.previousState!.timeline;
      }
    }
    return MelonSliverList(
      data,
      limitWidth: 500,
      cardTapping: (value) {
        setState(() {});
        MelonRouter.push(
            context: context, path: "/hashtags/${data[value]['name']}");
      },
    );
  }

  Widget _tabItem(String title, {bool isEnable = true}) {
    return OnHover(
      x: 5,
      y: 2,
      builder: (bool isHovered) {
        return Container(
            height: 40,
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                style: GoogleFonts.itim(
                    fontSize: 17,
                    color: isEnable
                        ? _theme!.backgroundColor()
                        : _theme!.textColor()),
              ),
            ));
      },
    );
  }

  String? _getQueryCommand(int value) {
    if (value == 0) {
      return "ALL";
    } else if (value == 1) {
      return "WEEK";
    } else if (value == 2) {
      return "MONTH";
    } else if (value == 3) {
      return "QUARTER";
    } else {
      return null;
    }
  }
}
