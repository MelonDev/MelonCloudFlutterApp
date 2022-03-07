import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meloncloud_flutter_app/cubit/home/home_cubit.dart';

import '../tools/melon_activity_indicator.dart';
import '../tools/melon_bouncing_button.dart';
import '../tools/melon_theme.dart';
import '../tools/melon_timeline.dart';
import 'package:meloncloud_flutter_app/page/tweet_page.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key, @required this.title}) : super(key: key);

  final String? title;

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  ScrollController? _contentsScrollController;
  ScrollController? _peoplesScrollController;

  MelonThemeData? _theme;
  bool atEvent = false;

  @override
  void initState() {
    super.initState();
    _contentsScrollController = ScrollController();
    _peoplesScrollController = ScrollController();
    //_contentsScrollController.addListener(_handleOverScroll);
  }

  @override
  Widget build(BuildContext context) {
    _theme = MelonTheme.of(context);

    return BlocBuilder<HomeCubit, HomeBaseState>(builder: (context, state) {
      return Stack(
        children: [_layout(state), _loading(state)],
      );
    });
  }

  Widget _layout(state) {
    Map<dynamic, List<dynamic>> data = {};

    if (state.childrenState != null) {
      if (state.childrenState.galleryChildState != null) {
        data = state.childrenState.galleryChildState.timeline;
        atEvent = state.childrenState.galleryChildState.peoples == null && state.childrenState.galleryChildState.timeline != null && state.childrenState.galleryChildState.data != null;
        //atEvent = state.childrenState.galleryChildState.isFriday;
      }
    }

    return MelonTimeline(
      scrollController: _contentsScrollController,
      title: widget.title,
      data: data,
      //navigationBarColor: Colors.red.withOpacity(0.5),
      type: TimelineType.grid,
      leadingWidget: _leading(state),
      trailingWidget: _trailing(state),
      header: _header(state),
      headerHeight: atEvent ? 0 :20,
      longActions: null,
      onItemTapping: (value) {
        Navigator.push(context,
            CupertinoPageRoute<CupertinoPageScaffold>(builder: (_) {
          return TweetPage();
        }));

         
      },
    );
  }

  Widget? _header(state) {
    return atEvent ? null : _childHeader(state);
  }

  Widget _childHeader(state) {
    if (state.childrenState != null) {
      return Container(
        height: 160,
        width: MediaQuery.of(context).size.width,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            controller: _peoplesScrollController,
            padding: const EdgeInsets.only(left: 16, right: 6),
            itemBuilder: (context, position) {
              if (state.childrenState.galleryChildState == null) {
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
                      SizedBox(
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
              } else {
                if (position ==
                    state.childrenState.galleryChildState.peoples.length) {
                  return MelonBouncingButton(
                    callback: () {
                      /*context
                          .read<PeopleCubit>()
                          .people(null, forceState: true);
                      Navigator.push(
                          context,
                          CupertinoPageRoute<CupertinoPageScaffold>(
                              builder: (_) => MorePeoplePage(
                                title: "บุคคล",
                                fromTitle: widget.title,
                              )));

                       */
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
                  dynamic data =
                      state.childrenState.galleryChildState.peoples[position];
                  dynamic profile = data['profile'];
                  dynamic value = data['count'];

                  return MelonBouncingButton(
                    callback: () {

                      /*Navigator.push(
                          context,
                          CupertinoPageRoute<CupertinoPageScaffold>(
                              builder: (_) => PeopleDetailPage(
                                fromTitle: widget.title,
                                data: state.stackState.gallerySectionState
                                    .listData[position],
                              )));

                       */
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
                                        image: profile['profile_image'],
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
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  "ไม่พบข้อมูล",
                                                  style: GoogleFonts.itim(
                                                      color:
                                                          _theme?.textColor()),
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
                                    padding: EdgeInsets.only(
                                        left: 10, right: 10, top: 4, bottom: 4),
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
                          SizedBox(
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
              }
            },
            scrollDirection: Axis.horizontal,
            itemCount: (state.childrenState.galleryChildState != null
                    ? (state.childrenState.galleryChildState.peoples != null
                        ? state.childrenState.galleryChildState.peoples.length
                        : 0)
                    : 0) +
                1,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _loading(outState) {
    if (outState is HomeLoadingState) {
      if (outState.childrenState == null) {
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
                      fontSize: 24, color: _theme?.textColor().withOpacity(0.9)),
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
          if (state is HomeLoadedState) {
            _scrollToTop(state);
            context.read<HomeCubit>().gallery(previousState: state);
          }
        },
        isBouncing: state is! HomeLoadingState,
        child: Container(
          width: state is HomeLoadingState ? 130 : 80,
          height: 32,
          decoration: BoxDecoration(
              color: state is HomeLoadingState
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
                    state is HomeLoadingState
                        ? CupertinoTheme(
                            data: CupertinoTheme.of(context).copyWith(),
                            child: MelonActivityIndicator())
                        : Container(),
                    SizedBox(
                      width: state is HomeLoadingState ? 6 : 0,
                    ),
                    Text(
                      state is HomeLoadingState ? 'กำลังโหลด..' : 'รีเฟรช',
                      style: GoogleFonts.itim(
                          color: state is HomeLoadingState
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
          if (state is HomeLoadedState) {
            if (atEvent) {
              context.read<HomeCubit>().gallery(previousState: state);
            } else {
              context.read<HomeCubit>().event(previousState: state);
            }
          }

        },
        isBouncing: true,
        child: Container(
          width: 100,
          height: 32,
          decoration: BoxDecoration(
              color: atEvent
                  ? _theme?.textColor()
                  : _theme?.onColor().withOpacity(0.1),
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
                      //color: Colors.blue,
                      width: 30,
                      child: Icon(
                        atEvent
                            ? CupertinoIcons.tickets_fill
                            : CupertinoIcons.tickets,
                        size: 18,
                        color: atEvent ? _theme?.barColor() : _theme?.onColor(),
                      ),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      'เทศกาล',
                      style: GoogleFonts.itim(
                          color:
                              atEvent ? _theme?.barColor() : _theme?.onColor()),
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
    if (state is HomeLoadedState) {
      if (!state.isRestoreState) {
        if (_calculateHeight(state.childrenState.galleryChildState?.timeline) <=
            120) {
          if (_contentsScrollController!.hasClients) {
            if (_contentsScrollController!.offset > 10) {
              _contentsScrollController!
                  .animateTo(-100,
                      duration: const Duration(seconds: 1),
                      curve: Curves.linear)
                  .whenComplete(() {
              });
            }
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
