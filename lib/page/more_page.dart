import 'package:adaptive_theme/adaptive_theme.dart';
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
    if (state is MainMoreLoadingState) {
      if (state.previousState == null) {
        return const MelonLoadingWidget();
      } else {
        return Container();
      }
    } else if (state is! MainMoreLoadingState && state is! MainMoreState) {
      return const MelonLoadingWidget();
    } else {
      return Container();
    }
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
          scrollController: _scrollController,
          sliverLayout: _contentState(state),
        ));
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
                  Container(width: 500, child: _settingMenuContent(index))
                ],
              );
            } else {
              return _settingMenuContent(index);
            }
          },
          childCount: _menu.length, // 1000 list items
        ),
      ),
    );
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
