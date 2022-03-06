import 'package:flutter/widgets.dart';

class MenuModel {
  IconData? icon;
  IconData? activeIcon;
  String? title;
  Widget? page;
  GlobalKey<NavigatorState>? key;

  MenuModel({this.icon, this.activeIcon, this.key, this.page, this.title});
}
