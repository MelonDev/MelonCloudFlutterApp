import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meloncloud_flutter_app/cubit/home/home_cubit.dart';

import '../model/MenuModel.dart';
import '../tools/melon_theme.dart';
import 'gallery_page.dart';

final GlobalKey<NavigatorState> galleryTabNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> fridayTabNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> favoriteTabNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> tagTabNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> peopleTabNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> furryGalleryTabNavKey =
    GlobalKey<NavigatorState>();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CupertinoTabController _cupertinoTabController;
  late MelonThemeData _theme;
  late List<Widget> pages;
  int index = 0;

  List<MenuModel> menus = [
    MenuModel(
        icon: CupertinoIcons.photo_on_rectangle,
        activeIcon: CupertinoIcons.photo_fill_on_rectangle_fill,
        page: new GalleryPage(),
        title: 'คลังภาพ',
        key: galleryTabNavKey),
    MenuModel(
        icon: CupertinoIcons.rectangle_on_rectangle_angled,
        activeIcon: CupertinoIcons.rectangle_fill_on_rectangle_angled_fill,
        page: new Container(),
        title: 'แท็ก',
        key: tagTabNavKey),
    MenuModel(
        icon: CupertinoIcons.tray_full,
        activeIcon: CupertinoIcons.tray_full_fill,
        page: new Container(),
        title: 'อัลบัม',
        key: furryGalleryTabNavKey),
    MenuModel(
        icon: CupertinoIcons.book,
        activeIcon: CupertinoIcons.book_fill,
        page: new Container(),
        title: 'หนังสือ',
        key: furryGalleryTabNavKey)
  ];

  @override
  void initState() {
    super.initState();
    _cupertinoTabController = CupertinoTabController();
    _cupertinoTabController.addListener(_tabSelected);
    pages = [
      _preparingCupertinoTabView(menus[0]),
      _preparingCupertinoTabView(menus[1]),
      _preparingCupertinoTabView(menus[2]),
      _preparingCupertinoTabView(menus[3]),
    ];
  }

  void _tabSelected() {
    var currentState = context.read<HomeCubit>().state;
    print(_cupertinoTabController.index);

    if (currentState is HomeLoadedState || currentState is HomeInitialState) {
      //index = _cupertinoTabController.index;
      if (index == 0) {
        context.read<HomeCubit>().gallery(previousState: null);
      }
    } else {
      //_cupertinoTabController.index = index;
    }
  }

  Widget _preparingCupertinoTabView(MenuModel model) {
    return CupertinoTabView(
      navigatorKey: model.key,
      builder: (BuildContext context) => model.page ?? Container(),
    );
  }

  BottomNavigationBarItem _preparingBottomNavigationBarItem(MenuModel model) {
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
          controller: _cupertinoTabController,
          tabBar: CupertinoTabBar(
            backgroundColor: _theme.barColor(),
            iconSize: 22,
            activeColor: CupertinoColors.systemBlue,
            inactiveColor: _theme.onColor().withOpacity(0.6),
            currentIndex: index,
            items: [
              _preparingBottomNavigationBarItem(menus[0]),
              _preparingBottomNavigationBarItem(menus[1]),
              _preparingBottomNavigationBarItem(menus[2]),
              _preparingBottomNavigationBarItem(menus[3]),
            ],
          ),
          tabBuilder: (BuildContext context, index) {
            if (index == 0) {
              return CupertinoPageScaffold(
                child: GalleryPage(
                  title: menus[index].title,
                ),
              );
            }

            if (index == 1) {
              return CupertinoPageScaffold(
                child: Container(),
              );
            }

            return Container();
          })
    ]);
  }


}
