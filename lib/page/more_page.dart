import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:d_chart/d_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:meloncloud_flutter_app/cubit/main/main_cubit.dart';
import 'package:meloncloud_flutter_app/page/error_page.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_loading_widget.dart';
import 'package:meloncloud_flutter_app/tools/melon_refresh_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_template.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:meloncloud_flutter_app/tools/on_hover.dart';
import 'package:routemaster/routemaster.dart';

class MorePage extends StatefulWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  ScrollController? _scrollController;
  MelonThemeData? _theme;
  int segmentedControlGroupValue = 0;
  Map<int, Widget> myTabs = {};

  List<SettingMenu> _menu = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    _theme = MelonTheme.of(context);

    _menu = updateMenu();

    super.didChangeDependencies();
  }

  List<SettingMenu> updateMenu() {
    return [
      SettingMenuHeader(title: "แอปย่อย"),
      SettingMenuItem(
          title: "ตัวสร้างรหัสผ่าน",
          icon: Ionicons.key_outline,
          group: true,
          topOfGroup: true,
          bottomOfGroup: true,
          trailing: SettingActionArrow()),
      SettingMenuHeader(title: "ธีม"),
      SettingMenuItem(
          title: "โหมดมืด",
          icon: Ionicons.moon_outline,
          group: true,
          topOfGroup: true,
          trailing: SettingActionSwitch(
              isEnabled: _theme!.isDark(),
              onAction: () {
                _theme!.changingTheme(brightness: Brightness.dark);
              },
              offAction: () {
                _theme!.changingTheme(brightness: Brightness.light);
              })),
      SettingMenuItem(
          title: "ตั้งค่าตามเครื่อง",
          icon: Ionicons.cog_outline,
          group: true,
          bottomOfGroup: true,
          trailing: SettingActionSwitch(
              isEnabled: CupertinoAdaptiveTheme.of(context).mode.isSystem,
              onAction: () {
                _theme!.changingToSystemTheme();
              },
              offAction: () {
                if (_theme!.isDark()) {
                  _theme!.changingTheme(brightness: Brightness.dark);
                } else {
                  _theme!.changingTheme(brightness: Brightness.light);
                }
              })),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CupertinoAdaptiveTheme.of(context).modeChangeNotifier,
      builder: (_, mode, child) {
        _menu = updateMenu();

        // update your UI
        return BlocBuilder<MainCubit, MainState>(builder: (context, state) {
          String path = Routemaster.of(context).currentRoute.path;
          if (path == "/more" &&
              state is! MainMoreState &&
              state is! MainMoreLoadingState &&
              state is! MainMoreFailureState) {
            context.read<MainCubit>().more(context: context);
          }
          if (state is MainMoreFailureState) {
            return ErrorPage(callback: () {
              context.read<MainCubit>().more(context: context);
            });
          }
          return Stack(
            children: [_timeline(state), _loading(state)],
          );
        });
      },
    );

    return BlocBuilder<MainCubit, MainState>(builder: (context, state) {
      String path = Routemaster.of(context).currentRoute.path;
      if (path == "/more" &&
          state is! MainMoreState &&
          state is! MainMoreLoadingState &&
          state is! MainMoreFailureState) {
        context.read<MainCubit>().more(context: context);
      }
      if (state is MainMoreFailureState) {
        return ErrorPage(callback: () {
          context.read<MainCubit>().more(context: context);
        });
      }
      return Stack(
        children: [_timeline(state), _loading(state)],
      );
    });
  }

  Widget _loading(state) {
    return Container();
  }

  Widget _timeline(state) {
    return SafeArea(
        top: false,
        bottom: false,
        child: MelonTemplate(
          title: "เพิ่มเติม",
          titleOnTap: () {
            _scrollController?.animateTo(-100,
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear);
          },
          trailingWidget: MelonRefreshButton(
              isLoading: state is MainMoreLoadingState,
              callback: () {
                if (state is MainMoreState) {
                  context
                      .read<MainCubit>()
                      .more(context: context, previousState: state);
                }
              }),
          scrollController: _scrollController,
          sliverLayout: _contentState(state),
        ));
  }

  List<SettingMenu> updatePortfolioMenu(fromState) {
    MainMoreState? state;
    List<SettingMenu> results = [];

    if (fromState is MainMoreState) {
      state = fromState;
    }
    if (fromState is MainMoreLoadingState) {
      state = fromState.previousState;
    }
    if (state != null) {
      Map<String, dynamic>? portfolios = state.portfolios;

      dynamic summary = state.summary;
      Map<String, dynamic>? coins = state.coins;
      if (coins != null && summary != null) {
        if (coins.isNotEmpty && summary.isNotEmpty) {
          results.add(
            SettingMenuHeader(title: "พอร์ตการลงทุน"),
          );

          results.add(SettingSummaryCoinMenuItem(
              title: "",
              value: state,
              icon: null,
              group: true,
              topOfGroup: true,
              bottomOfGroup: coins.isEmpty));

          int coinCount = 0;
          coins.forEach((k, v) {
            results.add(SettingCoinMenuItem(
                title: k,
                value: v,
                icon: null,
                group: true,
                topOfGroup: false,
                bottomOfGroup: coinCount == coins.length - 1));
            coinCount += 1;
          });
        }
      }

    }

    return results;
  }

  List<Widget> _portfolioGroupWidget(state) {
    if (state is MainMoreState) {
      return [];
    } else {
      return [];
    }
  }

  Widget _contentState(state) {
    List<dynamic> data = [];
    //List<SettingMenu> portfolioGroupWidget = updatePortfolioMenu(state);
    List<SettingMenu> portfolioGroupWidget = [];

    return SliverPadding(
      padding:
          const EdgeInsets.only(top: 4.0, bottom: 104.0, left: 4.0, right: 4.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (MediaQuery.of(context).size.width > 500) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 500,
                      child: index < portfolioGroupWidget.length
                          ? _settingPortfolioGroupMenuContent(state, index)
                          : _settingMenuContent(
                              index - portfolioGroupWidget.length))
                ],
              );
            } else {
              return index < portfolioGroupWidget.length
                  ? _settingPortfolioGroupMenuContent(state, index)
                  : _settingMenuContent(index - portfolioGroupWidget.length);
            }
          },
          childCount:
              _menu.length + portfolioGroupWidget.length, // 1000 list items
        ),
      ),
    );
  }

  Widget _settingPortfolioGroupMenuContent(fromState, int index) {
    MainMoreState? state;

    if (fromState is MainMoreState) {
      state = fromState;
    }
    if (fromState is MainMoreLoadingState) {
      state = fromState.previousState;
    }

    if (state != null) {
      SettingMenu menu = updatePortfolioMenu(state)[index];
      if (menu is SettingMenuHeader) {
        return _itemHeader(menu);
      }
      if (menu is SettingSummaryCoinMenuItem) {
        return Column(children: [
          _itemSummaryCoinContent(menu),
          menu.bottomOfGroup == false && menu.group == true
              ? Container(
                  color: _theme!.onColor().withOpacity(0.05),
                  margin: const EdgeInsets.only(top: 0, left: 12, right: 12),
                  child: Container(
                      margin: const EdgeInsets.only(top: 0, left: 24, right: 0),
                      color: _theme!.onColor().withOpacity(0.12),
                      height: 1.2))
              : const SizedBox()
        ]);
      }
      if (menu is SettingCoinMenuItem) {
        return Column(children: [
          _itemCoinContent(menu),
          menu.bottomOfGroup == false && menu.group == true
              ? Container(
                  color: _theme!.onColor().withOpacity(0.05),
                  margin: const EdgeInsets.only(top: 0, left: 12, right: 12),
                  child: Container(
                      margin: const EdgeInsets.only(top: 0, left: 24, right: 0),
                      color: _theme!.onColor().withOpacity(0.12),
                      height: 1.2))
              : const SizedBox()
        ]);
      }
    }

    return Container();
  }

  Widget _settingMenuContent(int index) {
    SettingMenu menu = _menu[index];
    if (menu is SettingMenuHeader) {
      return _itemHeader(menu);
    } else if (menu is SettingMenuItem) {
      return Column(children: [
        _itemContent(menu),
        menu.bottomOfGroup == false && menu.group == true
            ? Container(
                color: _theme!.onColor().withOpacity(0.05),
                margin: const EdgeInsets.only(top: 0, left: 12, right: 12),
                child: Container(
                    margin: const EdgeInsets.only(top: 0, left: 58, right: 0),
                    color: _theme!.onColor().withOpacity(0.12),
                    height: 1.2))
            : const SizedBox()
      ]);
    } else {
      return const SizedBox();
    }
  }

  Widget _itemHeader(SettingMenuHeader menu) {
    return Container(
        margin: const EdgeInsets.only(top: 16, left: 32, right: 12),
        child: Text(
          menu.title,
          style: GoogleFonts.itim(
              color: _theme?.textColor().withOpacity(0.5),
              fontSize: 18,
              fontWeight: FontWeight.normal),
        ));
  }

  Widget _itemCoinContent(SettingCoinMenuItem menu) {
    double mgtop = menu.group ? (menu.topOfGroup ? 4 : 0) : 24;
    double mgbottom = menu.group ? (menu.bottomOfGroup ? 4 : 0) : 16;
    double pdRight = menu.trailing != null ? 14 : 20;
    return OnHover(
      x: 16,
      y: 2,
      disableScale: true,
      builder: (bool isHovered) {
        return Container(
          margin: EdgeInsets.only(top: mgtop, left: 12, right: 12),
          child: MelonBouncingButton(
            active: true,
            isBouncing: false,
            borderRadius: 0,
            callback: () {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(mgtop > 0 ? 16 : 0),
                    topRight: Radius.circular(mgtop > 0 ? 16 : 0),
                    bottomLeft: Radius.circular(mgbottom > 0 ? 16 : 0),
                    bottomRight: Radius.circular(mgbottom > 0 ? 16 : 0)),
                color: isHovered
                    ? _theme?.onColor().withOpacity(0.15)
                    : _theme?.onColor().withOpacity(0.06),
              ),
              padding:
                  EdgeInsets.only(left: 0, right: pdRight, top: 8, bottom: 0),
              alignment: Alignment.center,
              height: 60,
              child: menu.value != null
                  ? Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                              height: 60,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 24,
                                  ),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          menu.value['symbol'],
                                          style: GoogleFonts.itim(
                                              color: _theme?.textColor(),
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "${menu.value['balance'].toStringAsFixed(10)} ( ${menu.value['percent'].toStringAsFixed(2)}% )",
                                          style: GoogleFonts.itim(
                                              color: _theme
                                                  ?.textColor()
                                                  .withOpacity(0.5),
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal),
                                        )
                                      ]),
                                ],
                              )),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${menu.value['balance_baht'].toStringAsFixed(2)}",
                                style: GoogleFonts.itim(
                                    color: _theme?.textColor().withOpacity(0.65),
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "${menu.value['balance_change'].toStringAsFixed(2)}",
                                style: GoogleFonts.itim(
                                    color: statusColor(menu.value),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        )
                        //_settingAction(menu)
                      ],
                    )
                  : Container(),
            ),
          ),
        );
      },
    );
  }

  Widget _itemSummaryCoinContent(SettingSummaryCoinMenuItem menu) {
    double mgtop = menu.group ? (menu.topOfGroup ? 4 : 0) : 24;
    double mgbottom = menu.group ? (menu.bottomOfGroup ? 4 : 0) : 16;
    double pdRight = menu.trailing != null ? 14 : 20;
    List<Map<String, dynamic>> pies = [];
    dynamic summary = menu.value.summary;
    menu.value.coins.forEach((k, v) {
      pies.add({'domain': v['symbol'], 'measure': v["percent"]});
    });
    double size_width = MediaQuery.of(context).size.width;
    double width = 0;
    if (size_width < 500){
      width = 160;
    }else{
      width = 260;

    }

    final List<Color> colors = <Color>[_theme!.textColor().withOpacity(0.7), _theme!.textColor().withOpacity(0.5), _theme!.textColor().withOpacity(0.3),_theme!.textColor().withOpacity(0.1)];


    return OnHover(
      x: 16,
      y: 2,
      disableScale: true,
      builder: (bool isHovered) {
        return Container(
          margin: EdgeInsets.only(top: mgtop, left: 12, right: 12),
          child: MelonBouncingButton(
            active: true,
            isBouncing: false,
            borderRadius: 0,
            callback: () {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(mgtop > 0 ? 16 : 0),
                    topRight: Radius.circular(mgtop > 0 ? 16 : 0),
                    bottomLeft: Radius.circular(mgbottom > 0 ? 16 : 0),
                    bottomRight: Radius.circular(mgbottom > 0 ? 16 : 0)),
                color: isHovered
                    ? _theme?.onColor().withOpacity(0.15)
                    : _theme?.onColor().withOpacity(0.06),
              ),
              padding:
                  EdgeInsets.only(left: 0, right: pdRight, top: 8, bottom: 0),
              alignment: Alignment.center,
              height: 160,
              child: menu.value != null
                  ? Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                              width: width,
                              height: 160,
                              child: DChartPie(
                                animate: false,
                                data: pies,
                                labelColor: _theme!.textColor(),
                                labelLineColor: _theme!.textColor(),
                                strokeWidth: 2,
                                labelLinelength: 16,
                                labelPosition: PieLabelPosition.auto,
                                fillColor: (pieData, index) => colors[index!],
                                donutWidth: 20,
                                pieLabel: (pieData, index) {
                                  return size_width >= 500 ? pieData['domain'] : "";
                                },
                              )),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${summary['balance'].toStringAsFixed(2)}",
                                style: GoogleFonts.itim(
                                    color: _theme?.textColor().withOpacity(0.7),
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                "ยอดวันนี้:  ${summary['balance_change'].toStringAsFixed(2)}  บาท",
                                style: GoogleFonts.itim(
                                    color: statusSummaryColor(summary),
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                "เปอร์เซ็นต์:  ${summary['percent_change'].toStringAsFixed(2)} %",
                                style: GoogleFonts.itim(
                                    color: statusSummaryColor(summary),
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        )
                        //_settingAction(menu)
                      ],
                    )
                  : Container(),
            ),
          ),
        );
      },
    );
  }

  Color statusSummaryColor(value) {
    if (value['percent_change'] == 0) {
      return _theme!.textColor().withOpacity(0.5);
    } else if (value['percent_change'] > 0) {
      return CupertinoColors.systemGreen.withOpacity(0.8);
    } else if (value['percent_change'] < 0) {
      return CupertinoColors.systemPink.withOpacity(0.8);
    } else {
      return Colors.transparent;
    }
  }

  Color statusColor(value) {
    if (value['status'] == "Neutral") {
      return _theme!.textColor().withOpacity(0.5);
    } else if (value['status'] == "Positive") {
      return CupertinoColors.systemGreen.withOpacity(0.8);
    } else if (value['status'] == "Negative") {
      return CupertinoColors.systemPink.withOpacity(0.8);
    } else {
      return Colors.transparent;
    }
  }

  Widget _itemContent(SettingMenuItem menu) {
    double mgtop = menu.group ? (menu.topOfGroup ? 4 : 0) : 24;
    double mgbottom = menu.group ? (menu.bottomOfGroup ? 4 : 0) : 16;
    double pdRight = menu.trailing != null ? 14 : 20;

    return OnHover(
      x: 16,
      y: 2,
      disableScale: true,
      builder: (bool isHovered) {
        return Container(
          margin: EdgeInsets.only(top: mgtop, left: 12, right: 12),
          child: MelonBouncingButton(
            active: true,
            isBouncing: false,
            borderRadius: 0,
            callback: () {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(mgtop > 0 ? 16 : 0),
                    topRight: Radius.circular(mgtop > 0 ? 16 : 0),
                    bottomLeft: Radius.circular(mgbottom > 0 ? 16 : 0),
                    bottomRight: Radius.circular(mgbottom > 0 ? 16 : 0)),
                color: isHovered
                    ? _theme?.onColor().withOpacity(0.15)
                    : _theme?.onColor().withOpacity(0.06),
              ),
              padding: EdgeInsets.only(
                  left: 20, right: pdRight, top: 16, bottom: 16),
              alignment: Alignment.center,
              height: 60,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                        height: 20,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(menu.icon,
                                color: _theme?.textColor(), size: 20),
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              menu.title,
                              style: GoogleFonts.itim(
                                  color: _theme?.textColor(),
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        )),
                  ),
                  _settingAction(menu)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _settingAction(SettingMenuItem menu) {
    if (menu.trailing != null) {
      if (menu.trailing is SettingActionArrow) {
        SettingActionArrow action = menu.trailing! as SettingActionArrow;

        return Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                action.text ?? "",
                style: GoogleFonts.itim(
                    color: _theme?.textColor().withOpacity(0.5),
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(
                width: 10,
              ),
              Icon(CupertinoIcons.chevron_right,
                  color: _theme?.textColor().withOpacity(0.5), size: 18),
            ],
          ),
        );
      } else if (menu.trailing is SettingActionSwitch) {
        SettingActionSwitch action = menu.trailing! as SettingActionSwitch;

        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            child: CupertinoSwitch(
                value: action.isEnabled,
                onChanged: (bool enabled) {
                  if (enabled) {
                    action.onAction?.call();
                  } else {
                    action.offAction?.call();
                  }
                }),
          ),
        );
      }
    }
    return Container();
  }
}

class SettingMenu {}

class SettingMenuHeader extends SettingMenu {
  String title;

  SettingMenuHeader({required this.title});
}

class SettingSummaryCoinMenuItem extends SettingMenu {
  String title;
  IconData? icon;
  bool group;
  bool topOfGroup;
  bool bottomOfGroup;
  SettingAction? trailing;
  dynamic value;

  SettingSummaryCoinMenuItem(
      {required this.title,
      this.icon,
      this.group = false,
      this.topOfGroup = false,
      this.bottomOfGroup = false,
      this.value,
      this.trailing});
}

class SettingCoinMenuItem extends SettingMenu {
  String title;
  IconData? icon;
  bool group;
  bool topOfGroup;
  bool bottomOfGroup;
  SettingAction? trailing;
  dynamic value;

  SettingCoinMenuItem(
      {required this.title,
      this.icon,
      this.group = false,
      this.topOfGroup = false,
      this.bottomOfGroup = false,
      this.value,
      this.trailing});
}

class SettingMenuItem extends SettingMenu {
  String title;
  IconData? icon;
  bool group;
  bool topOfGroup;
  bool bottomOfGroup;
  SettingAction? trailing;

  SettingMenuItem(
      {required this.title,
      this.icon,
      this.group = false,
      this.topOfGroup = false,
      this.bottomOfGroup = false,
      this.trailing});
}

class SettingAction {}

class SettingActionArrow extends SettingAction {
  String? text;

  SettingActionArrow({this.text});
}

class SettingActionSwitch extends SettingAction {
  VoidCallback? offAction;
  VoidCallback? onAction;
  bool isEnabled;

  SettingActionSwitch({this.offAction, this.onAction, this.isEnabled = false});
}

List<SettingMenu> mockSettingMenu = [
  SettingMenuHeader(title: "title"),
  SettingMenuItem(
      title: "Menu 1",
      icon: Ionicons.radio,
      group: true,
      topOfGroup: true,
      trailing: SettingActionSwitch()),
  SettingMenuItem(
      title: "Menu 2",
      icon: Ionicons.radio,
      group: true,
      trailing: SettingActionArrow()),
  SettingMenuItem(
      title: "Menu 3",
      icon: Ionicons.radio,
      group: true,
      trailing: SettingActionArrow(text: "เปิด")),
  SettingMenuItem(
      title: "Menu 4", icon: Ionicons.radio, group: true, bottomOfGroup: true),
  SettingMenuHeader(title: "title 2"),
  SettingMenuItem(
      title: "Menu 5", icon: Ionicons.radio, group: true, topOfGroup: true),
  SettingMenuItem(
      title: "Menu 6", icon: Ionicons.radio, group: true, bottomOfGroup: true),
  SettingMenuHeader(title: "title 3"),
  SettingMenuItem(
      title: "Menu 7",
      icon: Ionicons.radio,
      group: true,
      topOfGroup: true,
      bottomOfGroup: true),
  SettingMenuItem(title: "Menu 8", icon: Ionicons.radio),
];
