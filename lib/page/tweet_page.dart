import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meloncloud_flutter_app/cubit/tweet/tweet_cubit.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_popup_menu_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:routemaster/routemaster.dart';

import '../tools/melon_activity_indicator.dart';

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
  Widget build(BuildContext context) {
    _theme = MelonTheme.of(context);

    if (MediaQuery.of(context).size.width >= 900) {
      _width = 390.0;
    } else if (MediaQuery.of(context).size.width >= 500) {
      _width = 560.0;
    } else {
      _width = MediaQuery.of(context).size.width;
    }

    context.read<TweetCubit>().load(widget.tweetid);

    return BlocBuilder<TweetCubit, TweetState>(builder: (context, state) {
      bool isActiveBlurNavigationBar = false;

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
                trailing: _loadingChip(state),
                leading: MelonBouncingButton(
                  callback: () {
                    Routemaster.of(context).pop();
                  },
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.back,
                          color: disable ? Colors.white : _theme.textColor(),
                        ),
                        Text(
                          "กลับ",
                          style: GoogleFonts.itim(
                              color:
                                  disable ? Colors.white : _theme.textColor(),
                              fontSize: 18),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              child: Container(
                  color: _theme.backgroundColor(), child: _area(state)),
            ),
            isActiveBlurNavigationBar
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.of(context).padding.bottom,
                      width: MediaQuery.of(context).size.width,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                          child: Container(
                            color: Colors.black.withOpacity(0.0),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      );
    });
  }

  Widget _loadingChip(state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          child: MelonBouncingButton(
            callback: () {
              if (state is LoadedTweetState) {
                context.read<TweetCubit>().load(widget.tweetid);
              }
            },
            isBouncing: !(state is LoadingTweetState),
            child: Container(
              width: state is LoadingTweetState ? 130 : (disable ? 110 : 80),
              height: 32,
              decoration: BoxDecoration(
                  color: (state is LoadingTweetState
                      ? (CupertinoTheme.of(context)
                          .primaryColor
                          .withOpacity(0.8))
                      : (disable
                          ? CupertinoColors.systemRed.withOpacity(0.8)
                          : _theme.textColor().withOpacity(0.1))),
                  borderRadius: BorderRadius.circular(30)),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        state is LoadingTweetState
                            ? CupertinoTheme(
                                data: CupertinoTheme.of(context).copyWith(),
                                child: const MelonActivityIndicator())
                            : Container(),
                        SizedBox(
                          width: state is LoadingTweetState ? 6 : 0,
                        ),
                        Text(
                          state is LoadingTweetState
                              ? 'กำลังโหลด..'
                              : (disable ? "ไม่พบข้อมูล" : 'รีเฟรช'),
                          style: GoogleFonts.itim(
                              color: state is LoadingTweetState
                                  ? Colors.white
                                  : _theme.textColor()),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        disable
            ? Container()
            : SizedBox(
                width: 10,
              ),
        //_cupertinoMenu(),
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
        return _dataArea(state.previousState!, isFakeLoaded: true);
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

  Widget _dataArea(LoadedTweetState state, {bool isFakeLoaded = false}) {
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
                  children: [_layout(state, isFakeLoaded: isFakeLoaded)],
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

  Widget _layout(LoadedTweetState state, {bool isFakeLoaded = false}) {
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileWidget(state, isFakeLoaded: isFakeLoaded),
                    _currentStatusWidget(state, isFakeLoaded: isFakeLoaded),
                    _isEnableMessage(state)
                        ? _titleWidget("ข้อความ")
                        : Container(),
                    _isEnableMessage(state)
                        ? _langGroupWidget(state)
                        : Container(),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titleWidget("รูปภาพ"),
                  _langPhotoWidget(state, isFakeLoaded: isFakeLoaded),
                ],
              ),
            ],
          ),
          SizedBox(
            height: (40).toDouble(),
          ),
          _tagGroupWidget(state),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileWidget(state, isFakeLoaded: isFakeLoaded),
          _currentStatusWidget(state, isFakeLoaded: isFakeLoaded),
          _titleWidget("รูปภาพ"),
          _langPhotoWidget(state, isFakeLoaded: isFakeLoaded),
          _isEnableMessage(state) ? _titleWidget("ข้อความ") : Container(),
          _isEnableMessage(state) ? _langGroupWidget(state) : Container(),
          SizedBox(
            height: (40).toDouble(),
          ),
          _tagGroupWidget(state),
        ],
      );
    }
  }

  bool _isEnableMessage(LoadedTweetState state) {
    if (state.data['message'] != null) {
      return _removeTrashInText(state.data['message'].toString())
              .length >
          0;
    } else {
      return false;
    }
  }

  Widget _langPhotoWidget(LoadedTweetState state, {bool isFakeLoaded = false}) {
    List<dynamic>? photo =
        state.data['media']['photos'] as List<dynamic>?;
    List<dynamic>? video =
        state.data['media']['videos'] as List<dynamic>?;

    int len = photo != null ? photo.length : (video != null ? 1 : 0);

    return len > 0
        ? Container(
            padding: EdgeInsets.only(bottom: 10),
            margin: EdgeInsets.only(top: 20),
            width: MediaQuery.of(context).size.width >= 900
                ? MediaQuery.of(context).size.width - _width - 40
                : _width,
            height: MediaQuery.of(context).size.width > 900
                ? _width * 1.1
                : _width * 0.6,
            child: ListView.builder(
              padding: EdgeInsets.only(left: 16, right: 16),
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (sContext, sPosition) {
                return MelonBouncingButton(
                  callback: () {
                    if (!isFakeLoaded) {}

                    if (state.data['media']['videos'] == null) {
                      /*Navigator.push(
                    context,
                    CupertinoPageRoute<CupertinoPageScaffold>(
                        builder: (_) => PicturePreviewPage(
                          "ทวีต",
                          photos: photo,
                          initialPage: sPosition,
                        )));

                 */
                    }

                    //"thumb, small, medium, large, orig"

/*
              Navigator.of(context, rootNavigator: true)
                  .push(_createRoute(PicturePreview(
                galleryItems: _convertToListString(photo),
                initialPage: sPosition,
              )));

               */
                  },
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
                            Image.network(
                              "${photo != null ? photo[sPosition] : state.data['media']['thumbnail']}:small",
                              fit: BoxFit.cover,
                            ),
                            video != null
                                ? Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Container(
                                      margin:
                                          const EdgeInsets.only(left: 8, bottom: 8),
                                      child: const Icon(
                                        CupertinoIcons.videocam_circle_fill,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        )),
                  ),
                );
              },
              itemCount: len,
              scrollDirection: Axis.horizontal,
            ),
          )
        : Container();
  }

  Widget _langGroupWidget(LoadedTweetState state) {
    List<Widget> _listWidget = [];

    if (state.data["translate"] != null) {
      String _originalText = state.data['language'].contains("zh")
          ? state.data['message'].toString()
          : state.data["translate"]["${state.data['language']}"]
              .toString();

      String _zuText = state.data["translate"]["zu"].toString();

      //print(state.data['tweet']['lang']);
      //print(state.data["translate"]);

      if (_originalText != "null") {
        _listWidget
            .add(_langWidget(_originalText, state.data['language']));
      } else {
        _listWidget.add(_langWidget(
            state.data['message'], state.data['language']));
      }

      if (_zuText != null) {
        String _englishText = state.data["translate"]["en"].toString();
        String _thaiText = state.data["translate"]["th"].toString();
        _listWidget.add(_langWidget(_englishText, "en"));
        _listWidget.add(_langWidget(_thaiText, "th"));
      }
    } else {
      //String _originalText = state.data['tweet']['message'].toString();
      _listWidget.add(_langWidget(
          state.data['message'], state.data['language']));
    }

    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _listWidget,
      ),
    );
  }

  Widget _profileWidget(LoadedTweetState state, {bool isFakeLoaded = false}) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16),
      width: _width - 32,
      child: MelonBouncingButton(
        callback: () {
          Routemaster.of(context).push("/profile/${state.data['account']['id']}");
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(
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
                    state.data['account']['location'],
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
      ),
    );
  }

  Widget _currentStatusWidget(LoadedTweetState state,
      {bool isFakeLoaded = false}) {
    bool memories = state.data['memories'] ?? false;

    return Container(
      height: 70,
      margin: EdgeInsets.only(top: 30, left: 20, right: memories ? 6 : 20),
      width: _width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _statusWidget(
              (state.data['current']['favorite_count'] ?? "").toString(),
              "ชื่นชอบ",
              memories, callback: () {
            if (!isFakeLoaded) {
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
            }
          }, isEnable: memories, colorWhenEnable: CupertinoColors.systemPink),
          !memories ? _wallWidget() : Container(),
          _statusWidget(
              (state.data['current']['retweet_count'] ?? "").toString(),
              "รีทวีต",
              memories,
              callback: () {}),
          _wallWidget(),
          !memories
              ? _statusWidget(null, "บันทึก", memories,
                  overrideIcon: CupertinoIcons.tray_arrow_down, callback: () {
                  if (!isFakeLoaded) {
                    //context
                    //    .read<TweetCubit>()
                    //    .secretLikeTweet(state, state.data['tweet']['id']);
                  }
                })
              : Container(),
          !memories ? _wallWidget() : Container(),

          //_statusWidget((state.data['current']['source'] ?? "").toString(),"tweet from",overrideFontSize: 24)
          _statusWidget(null, "เปิดในแอป", memories,
              overrideIcon: CupertinoIcons.rocket, callback: () {
            if (!isFakeLoaded) {
              //context
              //    .read<TweetCubit>()
              //    .openTweet(state.data['tweet']['id']);
            }
          })
        ],
      ),
    );
  }

  Widget _wallWidget() {
    return Container(
      width: 2,
      height: 64,
      color: _theme.onColor().withOpacity(0.2),
    );
  }

  Widget _statusWidget(
      String? labelTop, String labelBottom, bool forceMarginRight,
      {double? overrideFontSize,
      IconData? overrideIcon,
      VoidCallback? callback,
      Color? colorWhenEnable,
      bool isEnable = false}) {
    return MelonBouncingButton(
      callback: callback,
      isBouncing: callback != null,
      child: Container(
        width:
            _statusWidgetWidth(forceMarginRight, enableFour: !forceMarginRight),
        height: 70,
        decoration: BoxDecoration(
            color: isEnable ? colorWhenEnable : _theme.backgroundColor(),
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

    if (MediaQuery.of(context).size.width < 500) {
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
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(40))),
        margin: const EdgeInsets.only(left: 0, bottom: 0, right: 6),
        padding: const EdgeInsets.only(left: 18, bottom: 6, right: 18, top: 6),
        child: Row(
          children: [
            Icon(
              iconData,
              color: Colors.white,
              size: 20,
            ),
            Container(
              width: 6,
            ),
            Text(
              title,
              style: GoogleFonts.itim(color: Colors.white, fontSize: 18),
            )
          ],
        ),
      ),
    );
  }

  Widget _titleWidget(String text) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 26,
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
        widgets.add(_chipTagWidget(i.toString(),
            Colors.blueAccent.withAlpha(150), CupertinoIcons.number));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
      child: Row(children: widgets),
    );
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
