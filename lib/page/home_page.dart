import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ionicons/ionicons.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:routemaster/routemaster.dart';

import '../cubit/book_library/book_library_cubit.dart';
import '../cubit/main/main_cubit.dart';
import '../model/MenuModel.dart';
import '../tools/melon_theme.dart';
import 'gallery_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CupertinoTabPageState _tabState;
  late MelonThemeData _theme;
  int index = 0;

  List<MenuModel> menus = [
    MenuModel(
        icon: Ionicons.paw_outline,
        activeIcon: Ionicons.paw,
        title: 'ไทม์ไลน์'),
    MenuModel(
        icon: Ionicons.earth_outline,
        activeIcon: Ionicons.earth,
        title: 'อีเวนท์'),
    MenuModel(
        icon: Ionicons.ticket_outline,
        activeIcon: Ionicons.ticket,
        title: 'แท็ก'),
    MenuModel(
        icon: Ionicons.book_outline,
        activeIcon: Ionicons.book,
        title: 'หนังสือ'),
    MenuModel(
        icon: Ionicons.ellipsis_horizontal_outline,
        activeIcon: Ionicons.ellipsis_horizontal,
        title: 'เพิ่มเติม'),
  ];

  @override
  void initState() {
    super.initState();
    //_cupertinoTabController = CupertinoTabController();
    //_cupertinoTabController.addListener(_tabSelected);
  }

  @override
  void didChangeDependencies() {
    _tabState = CupertinoTabPage.of(context);
    _tabState.controller.removeListener(selecting);
    //_tabState.controller.addListener(selecting);
    super.didChangeDependencies();
  }

  void selecting() {
    int currentIndex = _tabState.controller.index;
    if (currentIndex == 3) {
      print("SELECTING BOOKS");
      context.read<BookLibraryCubit>().load();
    }
/*
    if (currentIndex == 0) {
      context.read<MainCubit>().gallery(context:context);
    }
    if (currentIndex == 1) {
      context.read<MainCubit>().event(context:context);
    }

 */
  }

  Widget cupertinoTabView(MenuModel model) {
    return CupertinoTabView(
      navigatorKey: model.key,
      builder: (BuildContext context) => model.page ?? Container(),
    );
  }

  BottomNavigationBarItem bottomNavigationBarItem(MenuModel model) {
    return BottomNavigationBarItem(
        icon: Icon(model.icon),
        activeIcon: Icon(model.activeIcon),
        label: model.title);
  }

  @override
  Widget build(BuildContext context) {
    _theme = MelonTheme.of(context);
    return Stack(fit: StackFit.loose, children: [
      CupertinoTabScaffold(
        controller: _tabState.controller,
        tabBuilder: _tabState.tabBuilder,
        tabBar: CupertinoTabBar(
          //backgroundColor: _theme.barColor(),
          backgroundColor: (_theme.isDark()
                  ? const Color.fromARGB(0, 25, 25, 25)
                  : const Color.fromARGB(0, 240, 240, 240))
              .withOpacity(0.7),
          iconSize: 22,
          activeColor: CupertinoColors.systemBlue,
          inactiveColor: _theme.onColor().withOpacity(0.6),
          currentIndex: index,
          items: [
            bottomNavigationBarItem(menus[0]),
            bottomNavigationBarItem(menus[1]),
            bottomNavigationBarItem(menus[2]),
            bottomNavigationBarItem(menus[3]),
            bottomNavigationBarItem(menus[4]),
          ],
        ),
      )
    ]);
  }
}
