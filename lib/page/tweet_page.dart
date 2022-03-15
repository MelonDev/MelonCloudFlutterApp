import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meloncloud_flutter_app/cubit/tweet/tweet_cubit.dart';
import 'package:meloncloud_flutter_app/page/error_page.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meloncloud_flutter_app/tools/melon_back_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_popup_menu_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:meloncloud_flutter_app/tools/on_hover.dart';
import 'package:routemaster/routemaster.dart';

import '../tools/melon_activity_indicator.dart';
import '../tools/melon_refresh_button.dart';

class TweetPage extends StatefulWidget {
  const TweetPage({Key? key, required this.tweetid}) : super(key: key);
  final String tweetid;

  @override
  _TweetPageState createState() => _TweetPageState();
}

class _TweetPageState extends State<TweetPage> {
  late MelonThemeData _theme;
  late double _width;
  bool disable = false;

  @override
  void initState() {
    super.initState();
    context.read<TweetCubit>().load(widget.tweetid);
  }

  @override
  Widget build(BuildContext context) {
    _theme = MelonTheme.of(context);

    if (MediaQuery.of(context).size.width >= 900) {
      _width = 390.0;
    } else if (MediaQuery.of(context).size.width >= 600) {
      _width = 600.0;
    } else {
      _width = MediaQuery.of(context).size.width;
    }

    return BlocBuilder<TweetCubit, TweetState>(builder: (context, state) {
      bool isActiveBlurNavigationBar = false;
      if (state is TweetFailureState) {
        return ErrorPage(callback: () {
          context.read<TweetCubit>().load(widget.tweetid);
        });
      }
      return Container(
        color: _theme.backgroundColor(),
        child: Stack(
          fit: StackFit.loose,
          children: [
            CupertinoPageScaffold(
              backgroundColor: _theme.backgroundColor(),
              navigationBar: CupertinoNavigationBar(
                //brightness: disable ? Brightness.dark :null,
                border:
                    const Border(bottom: BorderSide(color: Colors.transparent)),
                backgroundColor: _theme.barColor(),
                trailing: _trailing(state),
                leading: MelonBackButton(),
              ),
              child: Container(
                  color: _theme.backgroundColor(), child: _area(state)),
            ),
          ],
        ),
      );
    });
  }

  Widget _trailing(state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MelonRefreshButton(
            isLoading: state is LoadingTweetState,
            callback: () {
              if (state is LoadedTweetState) {
                context.read<TweetCubit>().load(widget.tweetid);
              }
            }),
        disable
            ? Container()
            : const SizedBox(
                width: 10,
              ),
        disable
            ? Container()
            : IgnorePointer(
                ignoring: (state is LoadingTweetState),
                child: _melonMenu(state),
              )
      ],
    );
  }

  Widget _melonMenu(state) {
    bool memories = false;

    if (state is LoadedTweetState) {
      if (state.data != null) {
        memories = state.data['memories'] ?? false;
      }
    }

    return Container(
        child: MelonPopupMenuButton(
      actions: disable
          ? []
          : [
              MelonPopupMenuButtonAction(
                trailingIcon: CupertinoIcons.person,
                title: "เปิดโปรไฟล์",
                onPressed: () {
                  //context
                  //    .read<TweetCubit>()
                  //    .openTwitterProfile(state.data['profile']['id']);
                },
              ),
              MelonPopupMenuButtonAction(
                  trailingIcon: CupertinoIcons.search,
                  title: "ค้นหาในทวิตเตอร์",
                  onPressed: () {
                    //context.read<TweetCubit>().openSearchTwitterProfile(
                    //    state.data['profile']['screen_name']);
                  }),
              MelonPopupMenuButtonAction(
                trailingIcon: CupertinoIcons.calendar_today,
                title: "ทวีตย้อนหลัง",
              ),
              MelonPopupMenuButtonAction(
                trailingIcon: CupertinoIcons.number,
                title: "แท็กที่เคยใช้",
              ),
              memories ? MelonPopupMenuSpacingAction() : null,
              memories
                  ? MelonPopupMenuButtonAction(
                      trailingIcon: CupertinoIcons.heart_slash,
                      isDestructiveAction: true,
                      title: "เลิกชื่นชอบ",
                    )
                  : null,
            ],
    ));
    //return Container();
  }

  Widget _area(state) {
    if (state is LoadedTweetState) {
      return _dataArea(state);
    } else if (state is LoadingTweetState) {
      if (state.previousState != null) {
        return _dataArea(state.previousState!);
      } else {
        return disable
            ? _error()
            : Container(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 150,
                        height: 150,
                        child: Column(
                          children: [
                            Icon(
                              CupertinoIcons.cloud,
                              size: 100,
                              color: _theme.textColor().withOpacity(0.9),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "กำลังโหลด..",
                              style: GoogleFonts.itim(
                                  fontSize: 24,
                                  color: _theme.textColor().withOpacity(0.9)),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
      }
    } else {
      return Container();
    }
  }

  Widget _dataArea(LoadedTweetState state) {
    Size appbarSize = const CupertinoNavigationBar().preferredSize;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double navigationBarHeight = MediaQuery.of(context).padding.bottom;

    if (state.data != null) {
      return SafeArea(
          left: false,
          right: false,
          bottom: false,
          top: false,
          child: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(
                  top: 16.0 + statusBarHeight + appbarSize.height,
                  bottom: (navigationBarHeight).toDouble(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [_layout(state)],
                )),
          ));
    } else {
      return _error();
    }
  }

  Widget _error() {
    return Container(
      color: _theme.backgroundColor(),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  //color: CupertinoColors.systemRed,
                  borderRadius: BorderRadius.circular(50)),
              margin: const EdgeInsets.only(bottom: 0),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.wifi_slash,
                    size: 100,
                    color: _theme.textColor(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "ไม่พบข้อมูล",
                    style: GoogleFonts.itim(
                        fontSize: 24, color: _theme.textColor()),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _layout(LoadedTweetState state) {
    if (MediaQuery.of(context).size.width > 900) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: _width + 32,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileWidget(state),
                    SizedBox(
                      height: (10).toDouble(),
                    ),
                    _currentStatusWidget(state, 600),
                    SizedBox(
                      height: (26).toDouble(),
                    ),
                    _tagGroupWidget(state),
                    _isEnableMessage(state)
                        ? _titleWidget("ข้อความ", marginTop: 0)
                        : Container(),
                    _isEnableMessage(state)
                        ? _langGroupWidget(state)
                        : Container(),
                  ],
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titleWidget("รูปภาพ"),
                      _photoWidget(state),
                    ],
                  )),
            ],
          ),
          SizedBox(
            height: (40).toDouble(),
          ),
        ],
      );
    } else if (MediaQuery.of(context).size.width > 600) {
      return Container(
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profileWidget(state),
                SizedBox(
                  height: (10).toDouble(),
                ),
                _currentStatusWidget(state, 600),
                _titleWidget("รูปภาพ"),
                _photoWidget(state),

                SizedBox(
                  height: (26).toDouble(),
                ),
                _tagGroupWidget(state),

                _isEnableMessage(state)
                    ? _titleWidget("ข้อความ", marginTop: 0)
                    : Container(),


                _isEnableMessage(state) ? _langGroupWidget(state) : Container(),
                SizedBox(
                  height: (40).toDouble(),
                ),


              ],
            )
          ]));
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileWidget(state),
          SizedBox(
            height: (10).toDouble(),
          ),
          _currentStatusWidget(state, MediaQuery.of(context).size.width),
          _titleWidget("รูปภาพ"),
          _photoWidget(state),
          SizedBox(
            height: (26).toDouble(),
          ),
          _tagGroupWidget(state),
          _isEnableMessage(state)
              ? _titleWidget("ข้อความ", marginTop: 0)
              : Container(),
          _isEnableMessage(state) ? _langGroupWidget(state) : Container(),
          SizedBox(
            height: (40).toDouble(),
          ),
        ],
      );
    }
  }

  bool _isEnableMessage(LoadedTweetState state) {
    if (state.data['message'] != null) {
      return _removeTrashInText(state.data['message'].toString()).length > 0;
    } else {
      return false;
    }
  }

  Widget _photoWidget(LoadedTweetState state) {
    List<dynamic>? photos = state.data['media']['photos'] as List<dynamic>?;
    dynamic? videos = state.data['media']['videos'];
    dynamic? thumbnail = state.data['media']['thumbnail'];

    List<dynamic>? items = photos ?? (videos != null ? [thumbnail] : []);
    int len = items.length;

    return len > 0
        ? Container(
            padding: const EdgeInsets.only(bottom: 10),
            margin: const EdgeInsets.only(top: 20),
            width: MediaQuery.of(context).size.width >= 900
                ? MediaQuery.of(context).size.width - _width - 40
                : (MediaQuery.of(context).size.width >= 600
                    ? 600
                    : _width),
            height: MediaQuery.of(context).size.width > 900
                ? _width * 1.1
                : _width * 0.6,
            child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 0),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (sContext, sPosition) {
                    return OnHover(
                      x: 5,
                      y: 10,
                      builder: (bool isHovered) {
                        return MelonBouncingButton(
                          callback: () {
                            if (photos != null) {
                              String photosString = photos.join('@');
                              String positionString = sPosition.toString();
                              Map<String, String> queryParameters = {
                                "photos": photosString,
                                "position": positionString
                              };
                              MelonRouter.push(
                                  context: context,
                                  path: "/preview",
                                  queryParameters: queryParameters);
                            }
                          },
                          child: Hero(
                              tag: items[sPosition],
                              child: Container(
                                margin: EdgeInsets.only(right: 8),
                                width: MediaQuery.of(context).size.width > 900
                                    ? _width * 0.7
                                    : _width * 0.45,
                                height: MediaQuery.of(context).size.width > 900
                                    ? _width * 1.1
                                    : _width * 0.6,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        FadeInImage.assetNetwork(
                                          placeholder: _theme.isDark()
                                              ? 'assets/white_loading.gif'
                                              : 'assets/black_loading.gif',
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          image:
                                              "${items[sPosition]}${photos != null ? ':small' : ''}",
                                          imageErrorBuilder:
                                              (BuildContext context,
                                                  Object exception,
                                                  StackTrace? stackTrace) {
                                            return Container(
                                              color: _theme
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
                                                    color: _theme.textColor(),
                                                    size: 50,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    "ไม่พบข้อมูล",
                                                    style: GoogleFonts.itim(
                                                        color:
                                                            _theme.textColor()),
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                          fit: BoxFit.cover,
                                        ),
                                        videos != null
                                            ? Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 8, bottom: 8),
                                                  child: const Icon(
                                                    CupertinoIcons
                                                        .videocam_circle_fill,
                                                    color: Colors.white,
                                                    size: 48,
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    )),
                              )),
                        );
                      },
                    );
                  },
                  itemCount: len,
                  scrollDirection: Axis.horizontal,
                )),
          )
        : Container();
  }

  Widget _langGroupWidget(LoadedTweetState state) {
    List<Widget> _listWidget = [];

    if (state.data["translate"] != null) {
      String _originalText = state.data['language'].contains("zh")
          ? state.data['message'].toString()
          : state.data["translate"]["${state.data['language']}"].toString();

      String _zuText = state.data["translate"]["zu"].toString();

      //print(state.data['tweet']['lang']);
      //print(state.data["translate"]);

      if (_originalText != "null") {
        _listWidget.add(_langWidget(_originalText, state.data['language']));
      } else {
        _listWidget
            .add(_langWidget(state.data['message'], state.data['language']));
      }

      if (_zuText != null) {
        String _englishText = state.data["translate"]["en"].toString();
        String _thaiText = state.data["translate"]["th"].toString();
        _listWidget.add(_langWidget(_englishText, "en"));
        _listWidget.add(_langWidget(_thaiText, "th"));
      }
    } else {
      //String _originalText = state.data['tweet']['message'].toString();
      _listWidget
          .add(_langWidget(state.data['message'], state.data['language']));
    }
    double w = MediaQuery.of(context).size.width;
    return Container(
      margin: w < 600 || w >= 900 ? const EdgeInsets.only(left: 16, right: 16, top: 10) : EdgeInsets.only(left: 0, right: 0, top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _listWidget,
      ),
    );
  }

  Widget _profileWidget(LoadedTweetState state) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
      width: _width - 32,
      child: OnHover(
        builder: (bool isHovered) {
          return Container(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 10, bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isHovered
                    ? _theme.textColor().withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: MelonBouncingButton(
                callback: () {
                  //Routemaster.of(context)
                  //    .push("/profile/${state.data['account']['id']}");
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      margin: EdgeInsets.all(0),
                      height: 56,
                      width: 56,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(70.0),
                          child: Image.network(
                            state.data['account']['image'].toString(),
                            fit: BoxFit.cover,
                          )),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.data['account']['name'],
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.itim(
                                fontSize: 20,
                                color: _theme.textColor(),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "@${state.data['account']['screen_name']}${state.data['account']['location'].length != 0 ? '\n' : ''}${state.data['account']['location']}",
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.itim(
                                fontSize: 16,
                                color: _theme.textColor().withOpacity(0.8),
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ));
        },
      ),
    );
  }

  Widget _currentStatusWidget(LoadedTweetState state, double width) {
    bool memories = state.data['memories'] ?? false;

    double w = MediaQuery.of(context).size.width;

    return Container(
      height: 70,
      margin: w < 600 || w >= 900 ? EdgeInsets.only(left: w < 600 ? 26 : 20, right: memories ? 6 : 20) : EdgeInsets.only(left: memories ? 6 : 0, right:0),
      //margin: EdgeInsets.only(top: 30, left: 20, right: memories ? 6 : 20),
      //width: width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          OnHover(
            x: 5,
            y: 3,
            builder: (bool isHovered) {
              return _statusWidget(
                (state.data['current']['favorite_count'] ?? "").toString(),
                "ชื่นชอบ",
                memories,
                isHovered: isHovered,
                callback: () {
                  if (memories) {
                    //UNLIKE
                    /*context
                    .read<TweetDetailCubit>()
                    .unlikeTweet(state, state.data['tweet']['id']);

                 */
                  } else {
                    //context
                    //    .read<TweetCubit>()
                    //    .likeTweet(state, state.data['tweet']['id']);
                  }
                },
                isEnable: memories,
                colorWhenEnable: isHovered
                    ? const Color.fromARGB(255, 228, 46, 80)
                    : const Color.fromARGB(255, 255, 46, 85),
              );
            },
          ),
          !memories ? _wallWidget() : Container(),
          OnHover(
            x: 5,
            y: 3,
            builder: (isHovered) {
              return _statusWidget(
                  (state.data['current']['retweet_count'] ?? "").toString(),
                  "รีทวีต",
                  memories,
                  isHovered: isHovered,
                  callback: () {});
            },
          ),
          _wallWidget(),
          !memories
              ? OnHover(
                  x: 5,
                  y: 3,
                  builder: (bool isHovered) {
                    return _statusWidget(
                      null,
                      "บันทึก",
                      memories,
                      overrideIcon: CupertinoIcons.tray_arrow_down,
                      isHovered: isHovered,
                      callback: () {
                        //context
                        //    .read<TweetCubit>()
                        //    .secretLikeTweet(state, state.data['tweet']['id']);
                      },
                    );
                  },
                )
              : Container(),
          !memories ? _wallWidget() : Container(),

          //_statusWidget((state.data['current']['source'] ?? "").toString(),"tweet from",overrideFontSize: 24)
          OnHover(
            x: 5,
            y: 3,
            builder: (bool isHovered) {
              return _statusWidget(
                null,
                "เปิดในแอป",
                memories,
                overrideIcon: CupertinoIcons.rocket,
                isHovered: isHovered,
                callback: () {
                  //context
                  //    .read<TweetCubit>()
                  //    .openTweet(state.data['tweet']['id']);
                },
              );
            },
          )
        ],
      ),
    );
  }

  Widget _wallWidget() {
    return Container(
      width: 2,
      height: 64,
      color: _theme.onColor().withOpacity(0.1),
    );
  }

  Widget _statusWidget(
      String? labelTop, String labelBottom, bool forceMarginRight,
      {double? overrideFontSize,
      IconData? overrideIcon,
      VoidCallback? callback,
      Color? colorWhenEnable,
      bool isHovered = false,
      bool isEnable = false}) {
    return MelonBouncingButton(
      callback: callback,
      isBouncing: callback != null,
      child: Container(
        width: _statusWidgetWidth(forceMarginRight,
                enableFour: !forceMarginRight) -
            3,
        height: 76,
        decoration: BoxDecoration(
            color: isEnable
                ? colorWhenEnable
                : (isHovered
                    ? _theme.textColor().withOpacity(0.1)
                    : _theme.backgroundColor()),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            overrideIcon != null
                ? Icon(
                    overrideIcon,
                    size: 28,
                    color: _theme.textColor(),
                  )
                : Text(
                    labelTop ?? "",
                    style: GoogleFonts.itim(
                        fontSize: overrideFontSize ?? 32,
                        color: isEnable ? Colors.white : _theme.textColor(),
                        fontWeight: FontWeight.bold),
                  ),
            Container(
              margin: EdgeInsets.only(bottom: overrideIcon != null ? 11 : 2),
            ),
            labelBottom != null
                ? Text(
                    labelBottom,
                    style: GoogleFonts.itim(
                        fontSize: 16,
                        color: isEnable
                            ? Colors.white.withOpacity(0.8)
                            : _theme.textColor().withOpacity(0.8),
                        fontWeight: FontWeight.bold),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  double _statusWidgetWidth(bool forceMarginRight, {bool enableFour = false}) {
    double width = _width;

    if (MediaQuery.of(context).size.width < 600) {
      width -= (20 + (forceMarginRight ? 6 : 20));
    }

    int count = enableFour ? 4 : 3;

    width -= ((count - 1) * 2);
    width /= count;
    return width;
  }

  Widget _langWidget(String text, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 6, top: 10),
          child: Text(
            _getLangName(lang),
            style: GoogleFonts.itim(
                fontSize: 22,
                color: _theme.textColor(),
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Container(
          width: _width,
          padding: EdgeInsets.all(18),
          margin: EdgeInsets.only(right: 0),
          decoration: BoxDecoration(
              color: _theme.textColor().withOpacity(0.1),
              //border: Border.all(color: (_darkModeOn ? Colors.white : Colors.black).withOpacity(0.3)),
              borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Text(
            _removeTrashInText(text),
            style: GoogleFonts.itim(
                fontSize: 18, color: _theme.textColor(), height: 1.3),
          ),
        )
      ],
    );
  }

  String _removeTrashInText(String text) {
    text = text.replaceAll(
        RegExp(
            r"(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?"),
        "");
    text = text.replaceAll(
        RegExp(
            r"(http|ftp|https): ([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?"),
        "");
    return text.replaceFirst(RegExp(r"\#[^]*"), "");
  }

  Widget _chipTagWidget(String title, Color color, IconData iconData) {
    return OnHover(
      builder: (bool isHovered) {
        return MelonBouncingButton(
          callback: () {
            MelonRouter.push(context: context, path: "/hashtags/$title");
          },
          child: Container(
            decoration: BoxDecoration(
                color: _theme.isDark()
                    ? const Color(0x5c487be3)
                    : const Color(0xffe0e5ec),
                borderRadius: const BorderRadius.all(Radius.circular(40))),
            margin: const EdgeInsets.only(left: 0, bottom: 0, right: 6),
            padding:
                const EdgeInsets.only(left: 18, bottom: 6, right: 18, top: 6),
            child: Row(
              children: [
                Icon(
                  iconData,
                  color: _theme.isDark()
                      ? const Color(0xffdde2ec)
                      : const Color(0xff4e6179),
                  size: 20,
                ),
                Container(
                  width: 6,
                ),
                Text(
                  title,
                  style: GoogleFonts.itim(
                      color: _theme.isDark()
                          ? const Color(0xffdde2ec)
                          : const Color(0xff4e6179),
                      fontSize: 18),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _titleWidget(String text, {double marginTop = 26.0}) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: marginTop,
          ),
          Text(
            text,
            style: GoogleFonts.itim(
                fontSize: 28,
                color: _theme.textColor(),
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget _tagGroupWidget(LoadedTweetState state) {
    bool memories = state.data['memories'] ?? false;
    List<Widget> widgets = [];

    if (state.data['hashtags'] != null) {
      for (dynamic i in state.data['hashtags']) {
        widgets.add(_chipTagWidget(
            i.toString(),
            CupertinoColors.systemBlue.withOpacity(0.1),
            CupertinoIcons.number));
      }
    }
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
          child: Row(children: widgets),
        ));
  }

  String _getLangName(String name) {
    switch (name) {
      case "th":
        return "ภาษาไทย";
        break;
      case "en":
        return "ภาษาอังกฤษ";
        break;
      case "ko":
        return "ภาษาเกาหลี";
        break;
      case "zh":
        return "ภาษาจีน";
        break;
      case "ja":
        return "ภาษาญี่ปุ่น";
        break;
      default:
        return "ไม่ระบุภาษา";
        break;
    }
  }
}
