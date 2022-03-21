import 'dart:ui';

import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meloncloud_flutter_app/tools/melon_icon_button.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../tools/melon_back_button.dart';
import '../tools/melon_theme.dart';

class ImagePreviewPage extends StatefulWidget {
  ImagePreviewPage({Key? key, required this.photos, required this.position})
      : super(key: key);

  String photos;
  String position;

  @override
  _ImagePreviewPageState createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  MelonThemeData? _theme;
  late PageController _pageController;

  late List<String> _photos;
  late int _initialPage;
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _initialPage = widget.position.toInt();
    _photos = widget.photos.split('@');
    _pageController = PageController(initialPage: _initialPage);
    _pageController.addListener(_selecting);
  }

  void _selecting() {
    setState(() {
      currentIndex = (_pageController.page!).toInt() + 1;
    });
  }

  @override
  void didChangeDependencies() {
    _theme = MelonTheme.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.loose,
        children: [
          CupertinoPageScaffold(
            backgroundColor: Colors.black,
            navigationBar: CupertinoNavigationBar(
              border:
                  const Border(bottom: BorderSide(color: Colors.transparent)),
              brightness: Brightness.dark,
              backgroundColor: Colors.black.withOpacity(0.7),
              //trailing: _loadingChip(state),
              leading: MelonIconButton(
                icon: Ionicons.close,
                brightness: Brightness.dark,
                callback: () {
                  MelonRouter.pop(context: context);
                  //Routemaster.of(context).pop();
                },
              ),
              middle: _middle(),
            ),
            child: Container(color: _theme!.backgroundColor(), child: _area()),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    //_videoPlayerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _middle() {
    bool enableNavigatorButton = false;
    if (MediaQuery.of(context).size.width >= 500) {
      enableNavigatorButton = _photos.length > 1;
    } else {
      enableNavigatorButton = false;
    }

    return _photos.length <= 4
        ? Container(
            color: Colors.transparent,
            width: enableNavigatorButton ? 200 : 84,
            height: const CupertinoNavigationBar().preferredSize.height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                enableNavigatorButton
                    ? MelonIconButton(
                        icon: Ionicons.chevron_back,
                        brightness: Brightness.dark,
                        callback: () {
                          if (_pageController.page! > 0) {
                            _pageController.animateToPage(
                                _pageController.page!.toInt() - 1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.linear);
                          }
                        })
                    : Container(),
                SizedBox(
                  width: enableNavigatorButton ? 16 : 0,
                ),
                _photos.length > 1
                    ? SmoothPageIndicator(
                        controller: _pageController,
                        // PageController
                        count: _photos.length,
                        effect: ExpandingDotsEffect(
                            dotHeight: 10,
                            dotWidth: 10,
                            activeDotColor: Colors.white.withOpacity(1.0),
                            dotColor: Colors.white.withOpacity(0.5)),
                        // your preferred effect
                        onDotClicked: (index) {})
                    : Container(),
                SizedBox(
                  width: enableNavigatorButton ? 16 : 0,
                ),
                enableNavigatorButton
                    ? MelonIconButton(
                        icon: Ionicons.chevron_forward,
                        brightness: Brightness.dark,
                        callback: () {
                          if (_pageController.page! < _photos.length - 1) {
                            _pageController.animateToPage(
                                _pageController.page!.toInt() + 1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.linear);
                          }
                        })
                    : Container(),
              ],
            ))
        : Container(
            child: Text(
              "หน้า ${currentIndex} จาก ${_photos.length}",
              style: GoogleFonts.itim(
                  color: Colors.white.withOpacity(0.9), fontSize: 16),
            ),
          );
  }

  Widget _area() {
    return Container(
      color: Colors.black,
      child: PhotoViewGallery.builder(
        pageController: _pageController,
        customSize: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          /*
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(_photos[index] + ":orig"),
            initialScale: PhotoViewComputedScale.contained * 1,
            minScale: PhotoViewComputedScale.contained * 0.5,
            maxScale: PhotoViewComputedScale.covered * 5,
          );

           */

          PhotoViewController viewController = PhotoViewController();
          double paddingTop =
              const CupertinoNavigationBar().preferredSize.height;
          return PhotoViewGalleryPageOptions.customChild(
            child: Hero(
                tag: _photos[index],
                child: Container(
                  padding: EdgeInsets.only(top: paddingTop),
                  child: PhotoView(
                    loadingBuilder: (context, event) => Center(
                      child: SizedBox(
                        width: 36.0,
                        height: 36.0,
                        child: CircularProgressIndicator(
                          value: event == null
                              ? 0
                              : event.cumulativeBytesLoaded /
                                  event.expectedTotalBytes!,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    imageProvider: NetworkImage(_photos[index]),
                  ),
                )),
            disableGestures: false,
            controller: viewController,
            initialScale: PhotoViewComputedScale.contained * 1,
            minScale: PhotoViewComputedScale.contained * 0.5,
            maxScale: PhotoViewComputedScale.covered * 4,
          );
        },
        itemCount: _photos.length,
        //backgroundDecoration: widget.backgroundDecoration,
        //pageController: widget.pageController,
        //onPageChanged: onPageChanged,
      ),
    );
  }
}
