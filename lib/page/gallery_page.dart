import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:meloncloud_flutter_app/cubit/main/main_cubit.dart';
import 'package:meloncloud_flutter_app/page/error_page.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meloncloud_flutter_app/tools/melon_activity_indicator.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_refresh_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_timeline.dart';
import 'package:routemaster/routemaster.dart';

import '../tools/melon_theme.dart';
import '../tools/on_hover.dart';

class GalleryPage extends StatefulWidget {
  GalleryPage({Key? key}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with AutomaticKeepAliveClientMixin<GalleryPage> {
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
  }

  @override
  void didChangeDependencies() {
    _theme = MelonTheme.of(context);
    super.didChangeDependencies();
  }

  void _handleOverScroll() {
    double pixels = _contentsScrollController!.position.pixels;
    if (pixels == _contentsScrollController!.position.maxScrollExtent) {
      var state = context.read<MainCubit>().state;
      //print(pixels >= _scrollController.position.maxScrollExtent);

      if (state is MainHomeState) {
        int step = (_calculateHeight(state.timeline) / 50).round();
        if (step > 0) {
          context
              .read<MainCubit>()
              .gallery(context: context, previousState: state, command: "NEXT");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(builder: (context, state) {
      String path = Routemaster.of(context).currentRoute.path;
      if (path == "/home" &&
          state is! MainHomeState &&
          state is! MainHomeLoadingState &&
          state is! MainHomeFailureState) {
        context.read<MainCubit>().gallery(context: context);
      }
      if (state is MainHomeFailureState) {
        return ErrorPage(callback: () {
          context.read<MainCubit>().gallery(context: context);
        });
      }
      return Stack(
        children: [
          _layout(state),
          //_loading(state)
        ],
      );
      return Container();
    });
  }

  Widget _layout(state) {
    Map<dynamic, List<dynamic>> data = {};

    if (state is MainHomeState) {
      data = state.timeline;
    }
    if (state is MainHomeLoadingState) {
      if (state.previousState != null) {
        data = state.previousState!.timeline;
      }
    }

    return MelonTimeline(
      scrollController: _contentsScrollController,
      title: "ไทม์ไลน์",
      data: data,
      type: TimelineType.grid,
      //leadingWidget: _leading(state),
      trailingWidget: _trailing(state),
      header: _header(state),
      headerHeight: 20,
      longActions: null,
      onItemTapping: (value) {
        MelonRouter.push(
            context: context, path: '/tweets/${value['tweet_id']}');
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
              if (position == 0) {
                return OnHover(
                  builder: (bool isHovered) {
                    return MelonBouncingButton(
                      callback: () {
                        MelonRouter.push(context: context, path: '/peoples');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: _theme?.textColor().withOpacity(0.1),
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
                                    color: _theme!.textColor().withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(70)),
                                child: Center(
                                  child: Icon(
                                    Ionicons.apps,
                                    size: 42,
                                    color: _theme!.textColor(),
                                  ),
                                )),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              "ทั้งหมด",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.itim(
                                  fontSize: 18, color: _theme!.textColor()),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                dynamic data = state.peoples[position - 1];
                dynamic profile = data['profile'];
                dynamic value = data['count'];

                return OnHover(
                  builder: (bool isHovered) {
                    return MelonBouncingButton(
                      callback: () {
                        MelonRouter.push(
                            context: context,
                            path: "/profile/${profile['id']}");
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
                                          image: _resizeImageProfile(
                                              profile['image'])!,
                                          imageErrorBuilder:
                                              (BuildContext context,
                                                  Object exception,
                                                  StackTrace? stackTrace) {
                                            //errorMap[position] = true;

                                            return Container(
                                              color: _theme!
                                                  .onColor()
                                                  .withOpacity(0.2),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    CupertinoIcons
                                                        .xmark_seal_fill,
                                                    color: _theme?.textColor(),
                                                    size: 50,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    "ไม่พบข้อมูล",
                                                    style: GoogleFonts.itim(
                                                        color: _theme
                                                            ?.textColor()),
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
                                          left: 10,
                                          right: 10,
                                          top: 4,
                                          bottom: 4),
                                      decoration: BoxDecoration(
                                          color: CupertinoColors.systemYellow
                                              .withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      child: Text(
                                        "$value",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.itim(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Colors.black.withOpacity(0.8)),
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
                  },
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
      if (state.previousState == null) {
        return _loadingContent();
      } else {
        return Container();
      }
    } else if (state is! MainHomeLoadingState && state is! MainHomeState) {
      return _loadingContent();
    } else {
      return Container();
    }
  }

  Widget _loadingContent() {
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
  }

  Widget _trailing(state) {
    return MelonRefreshButton(
        isLoading: state is MainHomeLoadingState,
        callback: () {
          if (state is MainHomeState) {
            _scrollToTop(state);
            context.read<MainCubit>().gallery(context: context);
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
                                context: context,
                                previousState:
                                    state is MainHomeState ? state : null);
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
        });
  }

  Widget _leading(state) {
    return OnHover(
      disableScale: true,
      builder: (isHovered) {
        return MelonBouncingButton(
          callback: () {
            if (state is MainHomeState) {
              MelonRouter.push(context: context, path: '/home');
            }
          },
          isBouncing: true,
          child: Container(
            width: 100,
            height: 32,
            decoration: BoxDecoration(
                color: _theme!.onButtonColor(isHovered),
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
        );
      },
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
    if (orig == null) {
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
