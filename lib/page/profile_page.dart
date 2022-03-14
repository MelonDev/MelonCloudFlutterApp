import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meloncloud_flutter_app/tools/melon_activity_indicator.dart';
import 'package:meloncloud_flutter_app/tools/melon_back_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_refresh_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:meloncloud_flutter_app/tools/melon_timeline.dart';
import 'package:meloncloud_flutter_app/tools/on_hover.dart';
import 'package:routemaster/routemaster.dart';

import '../cubit/profile/profile_cubit.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key, required this.account}) : super(key: key);
  String account;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ScrollController? _scrollController;
  ScrollController? _hashtagsScrollController;

  MelonThemeData? _theme;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _hashtagsScrollController = ScrollController();

    context.read<ProfileCubit>().load(account: widget.account);
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
      var state = context
          .read<ProfileCubit>()
          .state;
      //print(pixels >= _scrollController.position.maxScrollExtent);

      if (state is ProfileState) {
        int step = (state.timeline.length / 30).round();
        if (step > 0) {
          context.read<ProfileCubit>().load(
              previousState: state, account: widget.account, command: "NEXT");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _theme = MelonTheme.of(context);

    return BlocBuilder<ProfileCubit, ProfileBaseState>(
        builder: (context, state) {
          if (state is ProfileState || state is ProfileLoadingState) {
            return Stack(
              children: [_timeline(state), _loading(state)],
            );
          } else {
            return Container();
          }
        });
  }

  Widget _loading(state) {
    if (state is ProfileLoadingState) {
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

  Widget _header(ProfileBaseState state) {
    dynamic profile = state is ProfileState
        ? state.profile
        : (state is ProfileLoadingState
        ? (state.previousState != null
        ? state.previousState!.profile
        : null)
        : null);
    dynamic hashtags = state is ProfileState
        ? state.hashtags
        : (state is ProfileLoadingState
        ? (state.previousState != null
        ? state.previousState!.hashtags
        : null)
        : null);
    return profile != null
        ? Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
                color: _theme!.onColor().withOpacity(0.06),
                borderRadius: const BorderRadius.all(Radius.circular(12))),
            padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
            child: Stack(
              fit: StackFit.expand,
              //crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: _imageBackground(profile['banner']),
                ),
                Container(
                  color: _theme!
                      .backgroundColor()
                      .withOpacity(_theme!.isDark() ? 0.6 : 0.75),
                ),
                _profile(profile)
              ],
            ),
            margin: const EdgeInsets.only(left: 0, right: 0, top: 10),
          ),
          _hashtags(hashtags)
        ]
    )
        : Container();
  }

  Widget _profile(profile) {
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
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/preview.png',
                        fadeInDuration: const Duration(milliseconds: 200),
                        image: profile['image'],
                        imageErrorBuilder: (BuildContext context,
                            Object exception, StackTrace? stackTrace) {
                          //errorMap[position] = true;

                          return Container(
                            color: _theme!.onColor().withOpacity(0.2),
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height,
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
                      ),
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
                        color: _theme!.textColor().withOpacity(0.9)),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  AutoSizeText(
                    "@${profile['screen_name']}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.itim(
                        fontSize: 16,
                        color: _theme!.textColor().withOpacity(0.9)),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  AutoSizeText(
                    "จำนวน ${profile['stats']['tweets'] +
                        profile['stats']['mentions']} ทวีต (ตนเอง: ${profile['stats']['tweets']}, ถูกกล่าวถึง: ${profile['stats']['mentions']})",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.itim(
                        fontSize: 24,
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
        fadeInDuration: const Duration(milliseconds: 300),
        image: profile_banner,
        imageErrorBuilder: (BuildContext context, Object exception,
            StackTrace? stackTrace) {
          //errorMap[position] = true;

          return Container(
            color: _theme!.onColor().withOpacity(0.2),
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height,
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

  Widget _timeline(state) {
    Map<dynamic, List<dynamic>> data = {};

    if (state is ProfileState) {
      data = state.timeline;
    }
    if (state is ProfileLoadingState) {
      if (state.previousState != null) {
        data = state.previousState!.timeline;
      }
    }

    return Container(
      color: _theme!.backgroundColor(),
      child: Stack(
        fit: StackFit.loose,
        children: [
          CupertinoPageScaffold(
            backgroundColor: _theme!.backgroundColor(),
            navigationBar: CupertinoNavigationBar(
              border:
              const Border(bottom: BorderSide(color: Colors.transparent)),
              backgroundColor: _theme!.barColor(),
              trailing: _trailing(state),
              middle: Text(
                //widget.hashtag['name'],
                "",
                style:
                GoogleFonts.itim(color: _theme!.textColor(), fontSize: 20),
              ),
              leading: MelonBackButton(),
            ),
            child: MelonTimeline(
              scrollController: _scrollController,
              type: TimelineType.grid,
              disableAppbar: true,
              data: data,
              onItemTapping: (value) {
                MelonRouter.push(context: context, path:"/tweets/${value['tweet_id']}");
              },
              header: _header(state),
              headerHeight: MediaQuery
                  .of(context)
                  .padding
                  .top +
                  CupertinoNavigationBar().preferredSize.height,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trailing(state) {
    return MelonRefreshButton(
        isLoading: state is ProfileLoadingState,
        callback: () {
          if (state is ProfileState) {
            context.read<ProfileCubit>().load(account: widget.account);
          }
        });
  }

  _scrollToTop(state) {
    if (state is ProfileState) {
      if (_calculateHeight(state.timeline) <= state.timeline.length) {
        if (_scrollController!.hasClients) {
          if (_scrollController!.offset > 10) {
            _scrollController!
                .animateTo(-100,
                duration: const Duration(seconds: 1), curve: Curves.linear)
                .whenComplete(() {});
          }
        }
      }
    }
  }

  Widget _hashtags(List<dynamic> hashtags) {
    return Container(
      height: 80,
      width: MediaQuery
          .of(context)
          .size
          .width,
      padding: const EdgeInsets.only(top: 16),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          controller: _hashtagsScrollController,
          padding: const EdgeInsets.only(left: 16, right: 6),
          itemBuilder: (context, position) {
            dynamic tags = hashtags[position];
            return _chipHashtagWidget(tags['name'], tags['value']);
          },
          scrollDirection: Axis.horizontal,
          itemCount: hashtags.length,
        ),
      ),
    );
  }

  Widget _chipHashtagWidget(String title, int count) {
    return OnHover(
      builder: (bool isHovered) {
        return MelonBouncingButton(
          callback: () {
            /*Navigator.push(
            context,
            CupertinoPageRoute<CupertinoPageScaffold>(
                builder: (_) => HashtagDetailPage(
                    fromTitle: "ทวีต", hashtag: {"name": title})));

         */
          },
          child: Container(
            decoration: BoxDecoration(
                color: _theme!.onColor().withOpacity(0.1),
                borderRadius: const BorderRadius.all(Radius.circular(16))),
            margin: const EdgeInsets.only(left: 0, bottom: 0, right: 6),
            padding:
            const EdgeInsets.only(left: 18, bottom: 6, right: 18, top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                     Icon(
                      CupertinoIcons.number,
                      color: _theme!.textColor(),
                      size: 20,
                    ),
                    Container(
                      width: 6,
                    ),
                    Text(
                      title,
                      style: GoogleFonts.itim(color: _theme!.textColor(), fontSize: 18),
                    )
                  ],
                ),
                Container(
                  width: 4,
                ),
                Text(
                  "จำนวน $count ทวีต",
                  style: GoogleFonts.itim(color: _theme!.textColor(), fontSize: 14),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  _calculateHeight(Map<dynamic, List<dynamic>> map) {
    int count = 0;

    for (List<dynamic> value in map.values) {
      count += value.length;
    }
    return count;
  }

  String? _resizeImageBanner(String? orig) {
    if (orig == null) {
      return null;
    }
    return "$orig/600x200";
  }
}
