import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meloncloud_flutter_app/cubit/main/main_cubit.dart';
import 'package:meloncloud_flutter_app/page/error_page.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meloncloud_flutter_app/tools/melon_books_grid.dart';
import 'package:meloncloud_flutter_app/tools/melon_loading_sliver_grid.dart';
import 'package:meloncloud_flutter_app/tools/melon_loading_widget.dart';
import 'package:meloncloud_flutter_app/tools/melon_refresh_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_sliver_grid.dart';
import 'package:meloncloud_flutter_app/tools/melon_template.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:routemaster/routemaster.dart';

class BooksLibraryPage extends StatefulWidget {
  const BooksLibraryPage({Key? key}) : super(key: key);

  @override
  _BooksLibraryPageState createState() => _BooksLibraryPageState();
}

class _BooksLibraryPageState extends State<BooksLibraryPage> {
  ScrollController? _scrollController;
  MelonThemeData? _theme;
  int segmentedControlGroupValue = 0;
  Map<int, Widget> myTabs = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController!.addListener(_handleOverScroll);
  }

  @override
  void didChangeDependencies() {
    _theme = MelonTheme.of(context);

    super.didChangeDependencies();
  }

  void _handleOverScroll() {
    double pixels = _scrollController!.position.pixels;
    if (pixels == _scrollController!.position.maxScrollExtent) {
      var state = context.read<MainCubit>().state;
      //print(pixels >= _scrollController.position.maxScrollExtent);

      if (state is MainBooksState) {
        int step = (state.timeline.length / 10).round();
        if (step > 0) {
          context
              .read<MainCubit>()
              .books(context: context, previousState: state, command: "NEXT");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(builder: (context, state) {
      String path = Routemaster.of(context).currentRoute.path;
      if (path == "/books" &&
          state is! MainBooksState &&
          state is! MainBooksLoadingState &&
          state is! MainBooksFailureState) {
        context.read<MainCubit>().books(context: context);
      }
      if (state is MainBooksFailureState) {
        return ErrorPage(callback: () {
          context.read<MainCubit>().books(context: context);
        });
      }
      if (state is MainBooksState || state is MainBooksLoadingState) {
        return Stack(
          children: [_timeline(state), _loading(state)],
        );
      } else {
        return Container();
      }
    });
  }

  Widget _loading(state) {
    if (state is MainBooksLoadingState) {
      if (state.previousState == null) {
        return const MelonLoadingWidget();
      } else {
        return Container();
      }
    } else if (state is! MainBooksLoadingState && state is! MainBooksState) {
      return const MelonLoadingWidget();
    } else {
      return Container();
    }
  }

  Widget _timeline(state) {
    List<dynamic> data = [];

    if (state is MainBooksState) {
      data = state.timeline;
    }
    if (state is MainBooksLoadingState) {
      if (state.previousState != null) {
        data = state.previousState!.timeline;
      }
    }
    return Container(
        color: _theme!.backgroundColor(),
        child: SafeArea(
            top: false,
            bottom: false,
            child: Container(
                child: MelonTemplate(
              title: "ชั้นหนังสือ",
              titleOnTap: () {
                _scrollController!.animateTo(-100,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.linear);
              },
              trailingWidget: MelonRefreshButton(
                  isLoading: state is MainBooksLoadingState,
                  callback: () {
                    if (state is MainBooksState) {
                      context.read<MainCubit>().books(context: context);
                    }
                  }),
              //leadingWidget: MelonBackButton(),
              scrollController: _scrollController,
              sliverLayout: _sliverHub(state),
            ))));
  }

  Widget _sliverHub(state) {
    if (state is MainBooksState) {
      return _availableState(state.timeline);
    } else if (state is MainBooksLoadingState) {
      if (state.previousState != null) {
        List<dynamic> data = state.previousState!.timeline;
        return _availableState(data);
      } else {
        return MelonLoadingSliverGrid();
      }
    } else {
      return MelonLoadingSliverGrid();
    }
  }

  Widget _availableState(List<dynamic> timeline) {
    return MelonBooksGrid(
      timeline: timeline,
      //fixWidth: 200,
      //topPadding: 12,
      callback: (data) {
        MelonRouter.push(context: context, path: "/book/${data['id']}");
      },
      children: (int position, int radio) {
        dynamic data = timeline[position];
        //int count = timeline[position]['count'];
        return [
          //_imageBackground(profile['banner']),
          Container(
            color: _theme!
                .backgroundColor()
                .withOpacity(_theme!.isDark() ? 0.6 : 0.75),
          ),
          _books(data, radio)
        ];
      },
    );
  }

  Widget _books(data, radio) {
    double width =
        MediaQuery.of(context).size.width - ((4 * 2) + (2 * (radio - 1)));
    double item_width = width / radio;
    double image_width = item_width / 2.4;
    double content_width = item_width - image_width;

    double item_height = item_width / 1.7;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          color: _theme!.backgroundColor(),
          margin: const EdgeInsets.only(left: 0),
          padding: const EdgeInsets.only(left: 0, bottom: 0, right: 0),
          child: Row(
            children: [
              Container(
                  width: image_width - 8,
                  height: item_height,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/preview.png',
                      fadeInDuration: const Duration(milliseconds: 200),
                      image: data['cover'],
                      imageScale: 1.0,
                      imageErrorBuilder: (BuildContext context,
                          Object exception, StackTrace? stackTrace) {
                        return Container(
                          color: _theme!.onColor().withOpacity(0.2),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.xmark_seal_fill,
                                color: _theme!.textColor(),
                                size: 50,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "ไม่พบข้อมูล",
                                style: GoogleFonts.itim(
                                    color: _theme!.textColor()),
                              )
                            ],
                          ),
                        );
                      },
                      fit: BoxFit.cover,
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 22, bottom: 0),
                  width: content_width - 10,
                  height: item_height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${data['name']}",
                        style: GoogleFonts.itim(
                          color: _theme!.textColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${data['artist']}",
                        style: GoogleFonts.itim(
                          color: _theme!.textColor().withOpacity(0.8),
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "ภาษา: ${data['language']}",
                        style: GoogleFonts.itim(
                          color: _theme!.textColor().withOpacity(0.8),
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                      )
                    ],
                  ))
            ],
          )),
    );
  }
}
