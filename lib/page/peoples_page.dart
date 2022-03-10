import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meloncloud_flutter_app/tools/melon_activity_indicator.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_loading_sliver_grid.dart';
import 'package:meloncloud_flutter_app/tools/melon_sliver_grid.dart';
import 'package:meloncloud_flutter_app/tools/melon_template.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:routemaster/routemaster.dart';

import '../cubit/peoples/peoples_cubit.dart';

class PeoplesPage extends StatefulWidget {
  const PeoplesPage({Key? key}) : super(key: key);

  @override
  _PeoplesPageState createState() => _PeoplesPageState();
}

class _PeoplesPageState extends State<PeoplesPage> {
  ScrollController? _scrollController;
  bool shouldLoadMore = true;

  bool forceState = false;

  MelonThemeData? _theme;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    context.read<PeoplesCubit>().load();

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
      var state = context.read<PeoplesCubit>().state;
      //print(pixels >= _scrollController.position.maxScrollExtent);

      if (state is PeoplesState) {
        int step = (state.timeline.length / 30).round();
        if (step > 0) {
          context
              .read<PeoplesCubit>()
              .load(previousState: state, command: "NEXT");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PeoplesCubit, PeoplesBaseState>(
        builder: (context, state) {
      return Container(
          color: _theme!.backgroundColor(),
          child: SafeArea(
              top: false,
              bottom: false,
              child: Stack(
                children: [
                  MelonTemplate(
                    title: "รายชื่อทั้งหมด",
                    titleOnTap: () {
                      _scrollController!.animateTo(-100,
                          duration: Duration(milliseconds: 500), curve: Curves.linear);
                    },
                    trailingWidget: Container(
                      child: MelonBouncingButton(
                        callback: () {
                          if (state is PeoplesState) {
                            context.read<PeoplesCubit>().load();
                          }
                        },
                        isBouncing: state is! PeoplesLoadingState,
                        child: Container(
                          width: state is PeoplesLoadingState ? 130 : 80,
                          height: 32,
                          decoration: BoxDecoration(
                              color: state is PeoplesLoadingState
                                  ? CupertinoTheme.of(context)
                                      .primaryColor
                                      .withOpacity(0.8)
                                  : _theme!.onColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30)),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    state is PeoplesLoadingState
                                        ? CupertinoTheme(
                                            data: CupertinoTheme.of(context)
                                                .copyWith(),
                                            child:
                                                const MelonActivityIndicator())
                                        : Container(),
                                    SizedBox(
                                      width:
                                          state is PeoplesLoadingState ? 6 : 0,
                                    ),
                                    Text(
                                      state is PeoplesLoadingState
                                          ? 'กำลังโหลด..'
                                          : 'รีเฟรช',
                                      style: GoogleFonts.itim(
                                          color: state is PeoplesLoadingState
                                              ? Colors.white
                                              : _theme!.onColor()),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    leadingWidget: MelonBouncingButton(
                      callback: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.back,
                              color: _theme!.textColor(),
                            ),
                            Text(
                              "กลับ",
                              style: GoogleFonts.itim(
                                  color: _theme!.textColor(), fontSize: 18),
                            )
                          ],
                        ),
                      ),
                    ),
                    scrollController: _scrollController,
                    sliverLayout: _sliverHub(state),
                  ),
                  _loading(state)
                ],
              )));
    });
  }

  Widget _loading(state) {
    if (state is PeoplesLoadingState) {
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
                  color: _theme!.textColor().withOpacity(0.9),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "กำลังโหลด..",
                  style: GoogleFonts.itim(
                      fontSize: 24,
                      color: _theme!.textColor().withOpacity(0.9)),
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

  Widget _sliverHub(state) {
    if (state is PeoplesState) {
      return _availableState(state.timeline);
    } else if (state is PeoplesLoadingState) {
      if (state.previousState != null) {
        List<dynamic> data = state.previousState!.timeline;
        return _availableState(data);

      } else {
        return MelonLoadingSliverGrid();
      }
    } else {
      return MelonLoadingSliverGrid();
    }
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

  String? _resizeImageBanner(String? orig) {
    if (orig == null) {
      return null;
    }
    return "$orig/300x100";
  }

  Widget _availableState(List<dynamic> timeline) {
    return MelonSliverGrid(
      timeline,
      fixWidth: 200,
      topPadding: 12,
      gridTapping: (data) {
        Routemaster.of(context).push("/peoples/${data['profile']['id']}");
      },
      children: (int position) {
        dynamic profile = timeline[position]['profile'];
        int count = timeline[position]['count'];
        return [
          _imageBackground(profile['profile_banner']),
          Container(
            color: _theme!
                .backgroundColor()
                .withOpacity(_theme!.isDark() ? 0.6 : 0.75),
          ),
          _profile(profile, count)
        ];
      },
    );
  }

  Widget _profile(data, int value) {
    String? profile_image = _resizeImageProfile(data['profile_image']);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        //color: Colors.red,
        padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),

        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: profile_image != null
                          ? FadeInImage.assetNetwork(
                              placeholder: 'assets/preview.png',
                              fadeInDuration: const Duration(milliseconds: 200),
                              image: profile_image,
                              imageErrorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return Container(
                                  color: _theme!.onColor().withOpacity(0.2),
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.xmark_seal_fill,
                                        color: _theme!.textColor(),
                                        size: 50,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "ไม่พบข้อมูล",
                                        style: GoogleFonts.itim(
                                            color: _theme!.textColor()),
                                      )
                                    ],
                                  ),
                                );
                              },
                              fit: BoxFit.cover,
                            )
                          : Container(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AutoSizeText(
                    data['name'] ?? "",
                    maxLines: 1,
                    maxFontSize: 18,
                    minFontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.itim(
                        color: _theme!.textColor().withOpacity(0.9)),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  AutoSizeText(
                    "@${data['screen_name']}",
                    maxLines: 1,
                    maxFontSize: 16,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.itim(
                        color: _theme!.textColor().withOpacity(0.9)),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  AutoSizeText(
                    "จำนวน $value ทวีต",
                    maxLines: 1,
                    maxFontSize: 18,
                    minFontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.itim(
                        fontWeight: FontWeight.normal,
                        color: _theme!.isDark()
                            ? CupertinoColors.systemYellow
                            : CupertinoColors.systemBlue),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _imageBackground(image) {
    String? profile_banner = _resizeImageBanner(image);

    return ColorFiltered(
      colorFilter: const ColorFilter.mode(
        Colors.grey,
        BlendMode.saturation,
      ),
      child: profile_banner != null
          ? FadeInImage.assetNetwork(
              placeholder: 'assets/preview.png',
              fadeInDuration: Duration(milliseconds: 200),
              image: profile_banner,
              imageErrorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                //errorMap[position] = true;
                return Container(
                  color: _theme!.onColor().withOpacity(0.2),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.xmark_seal_fill,
                        color: _theme!.textColor(),
                        size: 50,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "ไม่พบข้อมูล",
                        style: GoogleFonts.itim(color: _theme!.textColor()),
                      )
                    ],
                  ),
                );
              },
              fit: BoxFit.cover,
            )
          : Container(color: Colors.grey),
    );
  }

  Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  _calculateHeight(Map<dynamic, List<dynamic>>? map) {
    int count = 0;

    for (List<dynamic> value in map!.values) {
      count += value.length;
    }
    return count;
  }
}
