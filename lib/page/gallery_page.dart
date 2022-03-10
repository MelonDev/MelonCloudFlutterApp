import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:meloncloud_flutter_app/cubit/main/main_cubit.dart';
import 'package:meloncloud_flutter_app/tools/melon_activity_indicator.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_timeline.dart';
import 'package:routemaster/routemaster.dart';

import '../tools/melon_theme.dart';

class GalleryPage extends StatefulWidget {
  GalleryPage({Key? key}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> with
AutomaticKeepAliveClientMixin<GalleryPage> {
  MelonThemeData? _theme;
  ScrollController? _contentsScrollController;
  ScrollController? _peoplesScrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _contentsScrollController = ScrollController();
    _peoplesScrollController = ScrollController();
    _contentsScrollController?.addListener(_handleOverScroll);
    var state = context.read<MainCubit>().state;
  }

  @override
  void didChangeDependencies() {
    _theme = MelonTheme.of(context);

    var state = context.read<MainCubit>().state;
    if(!(state is MainHomeLoadingState || state is MainHomeState)){
      context.read<MainCubit>().gallery();
    }
    super.didChangeDependencies();
  }


  @override
  void deactivate() {
    super.deactivate();
  }


  @override
  void dispose() {
    super.dispose();

  }

  void _handleOverScroll() {
    double pixels = _contentsScrollController!.position.pixels;
    if (pixels == _contentsScrollController!.position.maxScrollExtent) {
      var state = context.read<MainCubit>().state;
      //print(pixels >= _scrollController.position.maxScrollExtent);

      if (state is MainHomeState) {
        int step =
        (_calculateHeight(state.timeline) /
            50)
            .round();
        if (step > 0) {
          context.read<MainCubit>().gallery(previousState:state,command: "NEXT");
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
      return Container();
    });
  }

  Widget _layout(state) {
    Map<dynamic, List<dynamic>> data = {};

    if (state is MainHomeState) {
      data = state.timeline;
    }
    if (state is MainHomeLoadingState){
      if (state.previousState != null){
        data = state.previousState!.timeline;
      }
    }

    return MelonTimeline(
      scrollController: _contentsScrollController,
      title: "ไทม์ไลน์",
      data: data,
      type: TimelineType.grid,
      leadingWidget: _leading(state),
      trailingWidget: _trailing(state),
      header: _header(state),
      headerHeight: 20,
      longActions: null,
      onItemTapping: (value) {
        Routemaster.of(context).push('/tweets/${value['tweet_id']}');
      },
    );
  }

  Widget? _header(state) {
    return _peoplesWidget(state);
  }

  Widget _peoplesWidget(state) {
    return Container(
      height: 160,
      width: MediaQuery.of(context).size.width,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          controller: _peoplesScrollController,
          padding: const EdgeInsets.only(left: 16, right: 6),
          itemBuilder: (context, position) {
            if (state is MainHomeLoadingState) {
              return Container(
                decoration: BoxDecoration(
                    color: _theme?.textColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16)),
                width: 120,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.0),
                          borderRadius: BorderRadius.circular(70)),
                      child: Center(
                        child: MelonActivityIndicator(
                          radius: 20,
                          color: _theme?.textColor().withOpacity(0.9),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      "กำลังโหลด..",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.itim(
                          fontSize: 18,
                          color: _theme?.textColor().withOpacity(0.9)),
                    ),
                  ],
                ),
              );
            } else if (state is MainHomeState) {
              if (position == state.peoples.length) {
                return MelonBouncingButton(
                  callback: () {
                    Routemaster.of(context).push('/peoples');

                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: _theme?.textColor().withOpacity(0.4),
                        borderRadius: BorderRadius.circular(24)),
                    width: 120,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(70)),
                            child: Center(
                              child: Icon(
                                CupertinoIcons.arrow_right,
                                size: 36,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            )),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          "เพิ่มเติม",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.itim(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                dynamic data = state.peoples[position];
                dynamic profile = data['profile'];
                dynamic value = data['count'];

                return MelonBouncingButton(
                  callback: () {
                    Routemaster.of(context).push("/peoples/${profile['id']}");

                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: _theme?.textColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24)),
                    width: 120,
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 70,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/preview.png',
                                      fadeInDuration:
                                          Duration(milliseconds: 300),
                                      image: _resizeImageProfile(profile['profile_image'])!,
                                      imageErrorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        //errorMap[position] = true;

                                        return Container(
                                          color: _theme!
                                              .onColor()
                                              .withOpacity(0.2),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                CupertinoIcons.xmark_seal_fill,
                                                color: _theme?.textColor(),
                                                size: 50,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                "ไม่พบข้อมูล",
                                                style: GoogleFonts.itim(
                                                    color: _theme?.textColor()),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 4, bottom: 4),
                                  decoration: BoxDecoration(
                                      color: CupertinoColors.systemYellow
                                          .withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Text(
                                    "$value",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.itim(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black.withOpacity(0.8)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          profile['name'] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.itim(
                              fontSize: 18,
                              color: _theme?.textColor().withOpacity(0.9)),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          "@${profile['screen_name']}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.itim(
                              fontSize: 16,
                              color: _theme?.textColor().withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                );
              }
            } else {
              return Container();
            }
          },
          scrollDirection: Axis.horizontal,
          itemCount: (state is MainHomeState
                  ? (state.peoples != null ? state.peoples.length : 0)
                  : 0) +
              1,
        ),
      ),
    );
  }

  Widget _loading(state) {
    if (state is MainHomeLoadingState) {
      if (state.previousState == null){
        return Align(
          alignment: Alignment.center,
          child: SizedBox(
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
                      fontSize: 24, color: _theme?.textColor().withOpacity(0.9)),
                )
              ],
            ),
          ),
        );
      }else {
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

          if (state is MainHomeState) {
            _scrollToTop(state);
            context.read<MainCubit>().gallery();
          } else if (state is! MainHomeLoadingState) {
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
                            context.read<MainCubit>().gallery(
                                previousState: state is MainHomeState ? state : null);
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
        isBouncing: state is! MainHomeLoadingState,
        child: Container(
          width: state is MainHomeLoadingState ? 130 : 80,
          height: 32,
          decoration: BoxDecoration(
              color: state is MainHomeLoadingState
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
                    state is MainHomeLoadingState
                        ? CupertinoTheme(
                            data: CupertinoTheme.of(context).copyWith(),
                            child: const MelonActivityIndicator())
                        : Container(),
                    SizedBox(
                      width: state is MainHomeLoadingState ? 6 : 0,
                    ),
                    Text(
                      state is MainHomeLoadingState ? 'กำลังโหลด..' : 'รีเฟรช',
                      style: GoogleFonts.itim(
                          color: state is MainHomeLoadingState
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

  Widget _leading(state) {
    return Container(
      child: MelonBouncingButton(
        callback: () {
          if (state is MainHomeState) {
            Routemaster.of(context).push('/home');
          }
        },
        isBouncing: true,
        child: Container(
          width: 100,
          height: 32,
          decoration: BoxDecoration(
              color: _theme?.onColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(30)),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      child: Icon(
                        Ionicons.images_outline,
                        size: 18,
                        color: _theme?.onColor(),
                      ),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      'อัลบั้ม',
                      style: GoogleFonts.itim(color: _theme?.onColor()),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
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
    if (state is MainHomeState) {
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

  String? _resizeImageProfile(String? orig) {
    if (orig == null){
      return null;
    }
    int index = orig.lastIndexOf('.');
    if (index != -1) {
      String a = orig.substring(0, index);
      String b = orig.substring(index, orig.length);
      return "${a}_x96$b";
    } else {
      return orig;
    }
  }
}
