import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloncloud_flutter_app/cubit/route/route_cubit.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MelonRouter {
  static List<String> tabsRoute = [
    '/home',
    '/events',
    '/tags',
    '/books',
    '/more'
  ];

  static push(
      {required BuildContext context,
      required String path,
      Map<String, String>? queryParameters}) {
    context
        .read<RouteCubit>()
        .push(context: context, path: path, queryParameters: queryParameters);
  }

  static pop({required BuildContext context}) {
    context.read<RouteCubit>().pop(context: context);
  }

  static push_async(
      {required BuildContext context,
      required String path,
      Map<String, String>? queryParameters}) async {

    String currentPath = Routemaster.of(context).currentRoute.fullPath;
    final prefs = await SharedPreferences.getInstance();
    List<String>? routes = prefs.getStringList('routes');
    String params = "";
    if(queryParameters != null){
      queryParameters.forEach((k,v) {
        if (params.isEmpty){
          params="?";
        }else{
          params+="&";
        }
        params += "$k=$v";
      });
    }
    path+=params;

    if(tabsRoute.contains(currentPath) && tabsRoute.length > 1){
      routes = [currentPath];
    }

    if (!tabsRoute.contains(path)) {
      routes ??= [];
      if (routes.isEmpty){
        routes = [currentPath];
      }
      /*else if (!routes.contains(currentPath)){
        routes = ["/",currentPath];
      }

       */
      routes.add(path);
      await prefs.setStringList('routes', routes);
      Routemaster.of(context).push(path, queryParameters: queryParameters);
    } else {
      routes = [path];
      await prefs.setStringList('routes', routes);
    }
    print(routes);
  }

  static pop_async({required BuildContext context}) async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    String currentPath = Routemaster.of(context).currentRoute.path;
    List<String>? routes = prefs.getStringList('routes');
    String? path = lastPath(routes);
    List<String>? finalRoutes = popPath(routes);
    await prefs.setStringList('routes', finalRoutes ?? []);
    Routemaster.of(context).push(path ?? "/");
    print(routes);
  }

  static String? lastPath(List<String>? routes) {
    if (routes == null) {
      return null;
    } else if (routes.isEmpty) {
      return "/";
    } else if (routes.length == 1) {
      return routes[routes.length - 1];
    } else {
      return routes[routes.length - 2];
    }
  }

  static List<String>? popPath(List<String>? routes) {
    if (routes == null) {
      return routes;
    } else if (routes.isEmpty) {
      return routes;
    } else {
      routes.removeLast();
      return routes;
    }
  }
}
