import 'dart:async';
import 'dart:io';

import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meloncloud_flutter_app/cubit/hashtags/hashtags_cubit.dart';
import 'package:meloncloud_flutter_app/cubit/main/main_cubit.dart';
import 'package:meloncloud_flutter_app/cubit/peoples/peoples_cubit.dart';
import 'package:meloncloud_flutter_app/cubit/profile/profile_cubit.dart';
import 'package:meloncloud_flutter_app/cubit/tweet/tweet_cubit.dart';
import 'package:meloncloud_flutter_app/extensions/kotlin_scope_functions.dart';
import 'package:meloncloud_flutter_app/model/MenuModel.dart';
import 'package:meloncloud_flutter_app/page/error_page.dart';
import 'package:meloncloud_flutter_app/page/event_page.dart';
import 'package:meloncloud_flutter_app/page/gallery_page.dart';
import 'package:meloncloud_flutter_app/page/hashtag_preview_page.dart';
import 'package:meloncloud_flutter_app/page/hashtags_page.dart';
import 'package:meloncloud_flutter_app/page/home_page.dart';
import 'package:meloncloud_flutter_app/page/image_preview_page.dart';
import 'package:meloncloud_flutter_app/page/peoples_page.dart';
import 'package:meloncloud_flutter_app/page/profile_page.dart';
import 'package:meloncloud_flutter_app/page/tweet_page.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'package:url_strategy/url_strategy.dart';

import 'cubit/route/route_cubit.dart';
import 'main.dart';

final routes = RouteMap(
  //onUnknownRoute: (route) => const Redirect('/'),
  routes: {
    '/': (route) => CupertinoTabPage(
          child: HomePage(),
          paths: MelonRouter.tabsRoute,
        ),
    '/home': (route) {
      return CupertinoPage(child: GalleryPage());
    },
    //child: OldGalleryPage(title: 'คลังภาพ', page: "home", message: "h")),
    '/events': (route) {
      return const CupertinoPage(child: EventPage());
    },
//child: OldGalleryPage(title: 'เทศกาล', page: "events", message: "e")),

    '/tags': (route) => const CupertinoPage(child: HashtagsPage()),
    '/books': (route) => CupertinoPage(
            child: Container(
          color: Colors.green,
        )),
    '/more': (route) => CupertinoPage(
            child: Container(
          color: Colors.purple,
        )),
    '/error': (route) => CupertinoPage(child: ErrorPage(callback: (){
      print("ทดสอบ");
    })),

    '/tweets/:id': (route) => CupertinoPage(
            child: TweetPage(
          tweetid: route.pathParameters['id']!,
        )),
    '/peoples': (route) => const CupertinoPage(child: PeoplesPage()),
    '/profile/:id': (route) => CupertinoPage(
            child: ProfilePage(
          account: route.pathParameters['id']!,
        )),
    '/preview': (route) => CupertinoPage(
            child: ImagePreviewPage(
          photos: route.queryParameters['photos']!,
          position: route.queryParameters['position']!,
        )),
    '/hashtags/:name': (route) => CupertinoPage(
        child: HashtagPreviewPage(
          name: route.pathParameters['name']!,
        )),
  },
);

Future main() async {
  Intl.defaultLocale = "th";

  initializeDateFormatting();

  //SharedPreferences? prefs = await SharedPreferences.getInstance();
  //await prefs.setStringList('routes', <String>[]);
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      await FlutterDisplayMode.setHighRefreshRate();
    }
  }
  //await dotenv.load(fileName: "assets/.env");
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RouteCubit>(create: (context) => RouteCubit()),
        BlocProvider<TweetCubit>(create: (context) => TweetCubit()),
        BlocProvider<MainCubit>(create: (context) => MainCubit()),
        BlocProvider<PeoplesCubit>(create: (context) => PeoplesCubit()),
        BlocProvider<ProfileCubit>(create: (context) => ProfileCubit()),
        BlocProvider<HashtagsCubit>(create: (context) => HashtagsCubit()),
      ],
      child: Portal(
        child: CupertinoApp.router(
          debugShowCheckedModeBanner: false,
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: RoutemasterDelegate(
            routesBuilder: (context) => routes,
          ),
          theme: CupertinoThemeData(
            primaryColor: CupertinoColors.activeBlue,
            textTheme: CupertinoTextThemeData(
              tabLabelTextStyle: GoogleFonts.itim(fontSize: 14),
              navLargeTitleTextStyle: GoogleFonts.itim(fontSize: 38),
              navTitleTextStyle: GoogleFonts.itim(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
