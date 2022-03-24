import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meloncloud_flutter_app/page/error_page.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meloncloud_flutter_app/tools/melon_back_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_book_page_grid.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_loading_widget.dart';
import 'package:meloncloud_flutter_app/tools/melon_refresh_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_sliver_list.dart';
import 'package:meloncloud_flutter_app/tools/melon_template.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';
import 'package:meloncloud_flutter_app/tools/on_hover.dart';

import '../cubit/book_library/book_library_cubit.dart';

class BookPage extends StatefulWidget {
  BookPage({Key? key, required this.bookid}) : super(key: key);

  String bookid;

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  ScrollController? _scrollController;
  MelonThemeData? _theme;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    context.read<BookLibraryCubit>().book(bookid: widget.bookid);
  }

  @override
  void didChangeDependencies() {
    _theme = MelonTheme.of(context);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookLibraryCubit, BookLibraryBaseState>(
        builder: (context, state) {
      if (state is BookFailureState) {
        return ErrorPage(callback: () {
          context.read<BookLibraryCubit>().book(bookid: widget.bookid);
        });
      }
      if (state is BookState || state is BookLoadingState) {
        String? name;
        if(state is BookState){
          name = state.name;
        }
        if(state is BookLoadingState){
          if (state.previousState != null){
            name = state.previousState!.name;
          }else {
            name = null;
          }
        }
        return Container(
          color: _theme!.backgroundColor(),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              //children: [_body(state), _loading(state)],
                children: [MelonTemplate(
                  title: name ?? "กำลังโหลด..",
                  middle: "",
                  header: _headerGrid(state),
                  headerPadding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                  titleOnTap: () {
                    _scrollController!.animateTo(-100,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.linear);
                  },
                  leadingWidget: MelonBackButton(),
                  trailingWidget: MelonRefreshButton(
                      isLoading: state is BookLoadingState,
                      callback: () {
                        if (state is BookState) {
                          context.read<BookLibraryCubit>().book(bookid: widget.bookid);
                        }
                      }),
                  //leadingWidget: MelonBackButton(),
                  scrollController: _scrollController,
                  sliverLayout: _contentState(state),
                ),_loading(state)]
            ),
          )
        );
      } else {
        return Container();
      }
    });
  }

  Widget _body(state) {
    return Container(
        color: _theme!.backgroundColor(),
        child: Stack(fit: StackFit.loose, children: [
          CupertinoPageScaffold(
            backgroundColor: _theme!.backgroundColor(),
            navigationBar: CupertinoNavigationBar(
              border:
                  const Border(bottom: BorderSide(color: Colors.transparent)),
              backgroundColor: _theme!.barColor(),
              trailing: MelonRefreshButton(
                  isLoading: state is BookLoadingState,
                  callback: () {
                    if (state is BookState) {
                      context
                          .read<BookLibraryCubit>()
                          .book(bookid: widget.bookid);
                    }
                  }),
              middle: Text(
                "",
                style:
                    GoogleFonts.itim(color: _theme!.textColor(), fontSize: 20),
              ),
              leading: MelonBackButton(),
            ),
            child: _timeline(state),
          )
        ]));
  }

  Widget _timeline(state) {
    List<dynamic> data = [];

    if (state is BookState) {
      data = state.timeline;
    }
    if (state is BookLoadingState) {
      if (state.previousState != null) {
        data = state.previousState!.timeline;
      }
    }
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          itemCount: 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return _header(state);
            } else if (index == 1) {
              return _horizontal(data);
            } else {
              return Container();
            }
            return Container(height: 100, width: 100, color: Colors.lightGreen);
          },
        ));
  }

  Widget _headerGrid(state) {
    if (state is BookState) {
      return Container(
          color: _theme!.onColor().withOpacity(0.00 ),
          padding:
          const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                "ผู้วาด: ${state.artist ?? "-"}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.itim(
                    color: _theme!.textColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 6),
              Text(
                "กลุ่ม: ${state.group ?? "-"}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.itim(
                    color: _theme!.textColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 6),
              Text(
                "ภาษา: ${state.language ?? "-"}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.itim(
                    color: _theme!.textColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 6),
              Text(
                "จำนวน: ${state.timeline.length} หน้า",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.itim(
                    color: _theme!.textColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget _header(state) {
    if (state is BookState) {
      return Container(
          color: _theme!.onColor().withOpacity(0.1),
          padding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.itim(
                    color: _theme!.textColor(),
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                "ผู้วาด: ${state.artist ?? "-"}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.itim(
                    color: _theme!.textColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 6),
              Text(
                "กลุ่ม: ${state.group ?? "-"}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.itim(
                    color: _theme!.textColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 6),
              Text(
                "ภาษา: ${state.language ?? "-"}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.itim(
                    color: _theme!.textColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 6),
              Text(
                "จำนวน: ${state.timeline.length} หน้า",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.itim(
                    color: _theme!.textColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget _horizontal(data) {
    List<String> photosPreview = [];
    List<String> photosOriginal = [];

    for (dynamic i in data) {
      String preview = i['preview'];
      String original = i['url'];

      photosPreview.add(preview);
      photosOriginal.add(original);
    }
    int len = photosPreview.length;

    double _width;
    if (MediaQuery.of(context).size.width >= 900) {
      _width = 390.0;
    } else if (MediaQuery.of(context).size.width >= 600) {
      _width = 600.0;
    } else {
      _width = MediaQuery.of(context).size.width;
    }

    return Container(
        margin: const EdgeInsets.only(top: 20, bottom: 40),
        height: MediaQuery.of(context).size.width > 900
            ? _width * 1.1
            : _width * 0.7,
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (sContext, sPosition) {
            return OnHover(
              x: 5,
              y: 10,
              builder: (bool isHovered) {
                return MelonBouncingButton(
                  callback: () {
                    String photosString = photosOriginal.join('@');
                    String positionString = sPosition.toString();
                    Map<String, String> queryParameters = {
                      "photos": photosString,
                      "position": positionString
                    };
                    MelonRouter.push(
                        context: context,
                        path: "/preview",
                        queryParameters: queryParameters);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: MediaQuery.of(context).size.width > 900
                        ? _width * 0.7
                        : _width * 0.45,
                    height: MediaQuery.of(context).size.width > 900
                        ? _width * 1.1
                        : _width * 0.6,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            FadeInImage.assetNetwork(
                              placeholder: _theme!.isDark()
                                  ? 'assets/white_loading.gif'
                                  : 'assets/black_loading.gif',
                              fadeInDuration: const Duration(milliseconds: 200),
                              image: photosPreview[sPosition],
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
                            )
                          ],
                        )),
                  ),
                );
              },
            );
          },
          itemCount: len,
          scrollDirection: Axis.horizontal,
        ));
  }

  Widget _contentState(state) {
    List<dynamic> data = [];
    if (state is BookState) {
      data = state.timeline;
    }
    if (state is BookLoadingState) {
      if (state.previousState != null) {
        data = state.previousState!.timeline;
      }
    }
    return MelonBookPageGrid(
      timeline: data,
      //fixWidth: 200,
      //topPadding: 12,
      callback: (position) {
        List<String> photosOriginal = [];

        for (dynamic i in data) {
          String original = i['url'];
          photosOriginal.add(original);
        }
        String photosString = photosOriginal.join('@');
        String positionString = position.toString();
        Map<String, String> queryParameters = {
          "photos": photosString,
          "position": positionString
        };
        MelonRouter.push(
            context: context,
            path: "/preview",
            queryParameters: queryParameters);
      },
      /*children: (int position, int radio) {
        dynamic item = data[position];
        //int count = timeline[position]['count'];
        return [
          //_imageBackground(profile['banner']),
          Container(
            color: _theme!
                .backgroundColor()
                .withOpacity(_theme!.isDark() ? 0.6 : 0.75),
          ),
          _bookGrid(item, radio)
        ];
      },

       */
    );
  }

  Widget _bookGrid(data, radio) {
    double width =
        MediaQuery.of(context).size.width - ((4 * 2) + (2 * (radio - 1)));
    double item_width = width / radio;
    double image_width = item_width / 2.4;
    double content_width = item_width - image_width;

    double item_height = item_width / 1.7;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          color:
          _theme!.isDark() ? Colors.white.withOpacity(0.1) : Colors.white,
          margin: const EdgeInsets.only(left: 0),
          padding: const EdgeInsets.only(left: 0, bottom: 0, right: 0),
          child: Container(
              width: image_width - 8,
              height: item_height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/preview.png',
                  fadeInDuration: const Duration(milliseconds: 200),
                  image: data['preview'],
                  imageScale: 1.0,
                  imageErrorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
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
                            style: GoogleFonts.itim(color: _theme!.textColor()),
                          )
                        ],
                      ),
                    );
                  },
                  fit: BoxFit.cover,
                ),
              ))),
    );
  }

  Widget _book(data, radio) {
    double width =
        MediaQuery.of(context).size.width - ((4 * 2) + (2 * (radio - 1)));
    double item_width = width / radio;
    double image_width = item_width / 2.4;
    double content_width = item_width - image_width;

    double item_height = item_width / 1.7;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          color:
              _theme!.isDark() ? Colors.white.withOpacity(0.1) : Colors.white,
          margin: const EdgeInsets.only(left: 0),
          padding: const EdgeInsets.only(left: 0, bottom: 0, right: 0),
          child: Container(
              width: image_width - 8,
              height: item_height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/preview.png',
                  fadeInDuration: const Duration(milliseconds: 200),
                  image: data['cover'],
                  imageScale: 1.0,
                  imageErrorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
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
                            style: GoogleFonts.itim(color: _theme!.textColor()),
                          )
                        ],
                      ),
                    );
                  },
                  fit: BoxFit.cover,
                ),
              ))),
    );
  }

  Widget _sliverList(state) {
    List<dynamic> data = [];

    if (state is BookState) {
      data = state.timeline;
    }
    if (state is BookLoadingState) {
      if (state.previousState != null) {
        data = state.previousState!.timeline;
      }
    }
    return SingleChildScrollView(
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(
              //top: 16.0 + statusBarHeight + appbarSize.height,
              //bottom: (navigationBarHeight).toDouble(),
              ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_layout(data)],
          )),
    );
  }

  Widget _layout(data) {
    List<String> photosPreview = [];
    List<String> photosOriginal = [];

    for (dynamic i in data) {
      String preview = i['preview'];
      String original = i['url'];

      photosPreview.add(preview);
      photosOriginal.add(original);
    }
    int len = photosPreview.length;

    double _width;
    if (MediaQuery.of(context).size.width >= 900) {
      _width = 390.0;
    } else if (MediaQuery.of(context).size.width >= 600) {
      _width = 600.0;
    } else {
      _width = MediaQuery.of(context).size.width;
    }

    return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 350,
              child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 0),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (sContext, sPosition) {
                      return OnHover(
                        x: 5,
                        y: 10,
                        builder: (bool isHovered) {
                          return MelonBouncingButton(
                            callback: () {
                              String photosString = photosOriginal.join('@');
                              String positionString = sPosition.toString();
                              Map<String, String> queryParameters = {
                                "photos": photosString,
                                "position": positionString
                              };
                              MelonRouter.push(
                                  context: context,
                                  path: "/preview",
                                  queryParameters: queryParameters);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: MediaQuery.of(context).size.width > 900
                                  ? _width * 0.7
                                  : _width * 0.45,
                              height: MediaQuery.of(context).size.width > 900
                                  ? _width * 1.1
                                  : _width * 0.6,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      FadeInImage.assetNetwork(
                                        placeholder: _theme!.isDark()
                                            ? 'assets/white_loading.gif'
                                            : 'assets/black_loading.gif',
                                        fadeInDuration:
                                            const Duration(milliseconds: 200),
                                        image: photosPreview[sPosition],
                                        imageErrorBuilder:
                                            (BuildContext context,
                                                Object exception,
                                                StackTrace? stackTrace) {
                                          return Container(
                                            color: _theme!
                                                .onColor()
                                                .withOpacity(0.2),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  CupertinoIcons
                                                      .xmark_seal_fill,
                                                  color: _theme!.textColor(),
                                                  size: 50,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  "ไม่พบข้อมูล",
                                                  style: GoogleFonts.itim(
                                                      color:
                                                          _theme!.textColor()),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                        fit: BoxFit.cover,
                                      )
                                    ],
                                  )),
                            ),
                          );
                        },
                      );
                    },
                    itemCount: len,
                    scrollDirection: Axis.horizontal,
                  )))
        ]);
  }

  Widget _loading(state) {
    if (state is BookLoadingState) {
      if (state.previousState == null) {
        return const MelonLoadingWidget();
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }
}
