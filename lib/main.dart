import 'dart:async';
import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meloncloud_flutter_app/cubit/hashtags/hashtags_cubit.dart';
import 'package:meloncloud_flutter_app/cubit/main/main_cubit.dart';
import 'package:meloncloud_flutter_app/cubit/peoples/peoples_cubit.dart';
import 'package:meloncloud_flutter_app/cubit/profile/profile_cubit.dart';
import 'package:meloncloud_flutter_app/cubit/tweet/tweet_cubit.dart';
import 'package:meloncloud_flutter_app/page/book_page.dart';
import 'package:meloncloud_flutter_app/page/books_library_page.dart';
import 'package:meloncloud_flutter_app/page/error_page.dart';
import 'package:meloncloud_flutter_app/page/event_page.dart';
import 'package:meloncloud_flutter_app/page/gallery_page.dart';
import 'package:meloncloud_flutter_app/page/hashtag_preview_page.dart';
import 'package:meloncloud_flutter_app/page/hashtags_page.dart';
import 'package:meloncloud_flutter_app/page/home_page.dart';
import 'package:meloncloud_flutter_app/page/image_preview_page.dart';
import 'package:meloncloud_flutter_app/page/more_page.dart';
import 'package:meloncloud_flutter_app/page/peoples_page.dart';
import 'package:meloncloud_flutter_app/page/profile_page.dart';
import 'package:meloncloud_flutter_app/page/tweet_page.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:routemaster/routemaster.dart';
import 'package:url_strategy/url_strategy.dart';
import 'cubit/book_library/book_library_cubit.dart';
import 'cubit/route/route_cubit.dart';


CupertinoPage melonCupertinoPage({Widget? child}){
  return CupertinoPage(child: Container(color:Colors.white,child:child));
}


final routes = RouteMap(
  onUnknownRoute: (route) => const Redirect('/'),
  routes: {
    '/': (route) => CupertinoTabPage(
          child: const HomePage(),
          paths: MelonRouter.tabsRoute,
        ),
    '/home': (route) {
      return melonCupertinoPage(child: GalleryPage());
    },
    '/events': (route) {
      return melonCupertinoPage(child: const EventPage());
    },
    '/tags': (route) => melonCupertinoPage(child: const HashtagsPage()),
    '/books': (route) => melonCupertinoPage(child: const BooksLibraryPage()),
    '/more': (route) => melonCupertinoPage(child: const MorePage()),
    '/error': (route) => melonCupertinoPage(child: ErrorPage(callback: () {})),
    '/book/:id': (route) => melonCupertinoPage(
            child: BookPage(
          bookid: route.pathParameters['id']!,
        )),
    '/tweets/:id': (route) => melonCupertinoPage(
            child: TweetPage(
          tweetid: route.pathParameters['id']!,
        )),
    '/peoples': (route) => melonCupertinoPage(child: const PeoplesPage()),
    '/profile/:id': (route) => melonCupertinoPage(
            child: ProfilePage(
          account: route.pathParameters['id']!,
        )),
    '/preview': (route) => melonCupertinoPage(
            child: ImagePreviewPage(
          photos: route.queryParameters['photos']!,
          position: route.queryParameters['position']!,
        )),
    '/hashtags/:name': (route) => melonCupertinoPage(
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

  setPathUrlStrategy();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Brightness _brightness;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      fetchAll();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> fetchAll() async {
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        await FlutterDisplayMode.setHighRefreshRate();
        Brightness brightness =
            SchedulerBinding.instance.window.platformBrightness;
        _brightness = brightness;
        AdaptiveThemeMode? savedThemeMode = await AdaptiveTheme.getThemeMode();
        if (savedThemeMode != null) {
          if (savedThemeMode == AdaptiveThemeMode.dark) {
            brightness = Brightness.dark;
          }
          if (savedThemeMode == AdaptiveThemeMode.light) {
            brightness = Brightness.light;
          }
        }

        updateUI(brightness: brightness);
      }
    }

    setState(() {});
  }

  updateUI({required Brightness brightness}) {
    //Setting SysemUIOverlay
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        //systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.white.withOpacity(0.01),
        //systemNavigationBarDividerColor: Colors.white.withOpacity(0.1),
        systemNavigationBarDividerColor:
            brightness == Brightness.dark ? Colors.transparent : null,
        //systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark));

    //Setting SystmeUIMode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

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
        BlocProvider<BookLibraryCubit>(create: (context) => BookLibraryCubit()),
      ],
      child: Portal(
        child: CupertinoAdaptiveTheme(
          light: CupertinoThemeData(
            brightness: Brightness.light,
            primaryColor: CupertinoColors.activeBlue,
            textTheme: CupertinoTextThemeData(
              tabLabelTextStyle: GoogleFonts.itim(fontSize: 14),
              navLargeTitleTextStyle: GoogleFonts.itim(fontSize: 38),
              navTitleTextStyle: GoogleFonts.itim(fontSize: 24),
            ),
          ),
          dark: CupertinoThemeData(
            brightness: Brightness.dark,
            primaryColor: CupertinoColors.activeBlue,
            textTheme: CupertinoTextThemeData(
              tabLabelTextStyle: GoogleFonts.itim(fontSize: 14),
              navLargeTitleTextStyle: GoogleFonts.itim(fontSize: 38),
              navTitleTextStyle: GoogleFonts.itim(fontSize: 24),
            ),
          ),
          initial: AdaptiveThemeMode.system,
          builder: (theme) {
            //print(theme);
            updateUI(brightness: theme.brightness ?? _brightness);
            return CupertinoApp.router(
              title: "MelonCloud",
              debugShowCheckedModeBanner: false,
              routeInformationParser: const RoutemasterParser(),
              routerDelegate: RoutemasterDelegate(
                routesBuilder: (context) => routes,
              ),
              theme: theme,
            );
          },
        ),
      ),
    );
  }
}
