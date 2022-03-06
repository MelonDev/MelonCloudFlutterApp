import 'dart:io';

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
import 'package:meloncloud_flutter_app/extensions/kotlin_scope_functions.dart';
import 'package:meloncloud_flutter_app/model/MenuModel.dart';
import 'package:meloncloud_flutter_app/page/HomePage.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:sizer/sizer.dart';

import 'cubit/home/home_cubit.dart';

Future main() async {
  Intl.defaultLocale = "th";
  initializeDateFormatting();
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      await FlutterDisplayMode.setHighRefreshRate();
    }
  }
  await dotenv.load(fileName: "assets/.env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>(create: (context) => HomeCubit()..gallery()),
        ],
        child: Portal(
            child: CupertinoApp(
          debugShowCheckedModeBanner: false,
          home: const HomePage(),
          theme: CupertinoThemeData(
              primaryColor: CupertinoColors.activeBlue,
              textTheme: CupertinoTextThemeData(
                tabLabelTextStyle: GoogleFonts.itim(fontSize: 14),
                navLargeTitleTextStyle: GoogleFonts.itim(fontSize: 38),
                navTitleTextStyle: GoogleFonts.itim(fontSize: 24),
              )),
        )));
  }
}
