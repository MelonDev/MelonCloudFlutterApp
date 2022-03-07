import 'package:flutter/material.dart';

class TweetPage extends StatefulWidget {
  const TweetPage({Key key}) : super(key: key);

  @override
  _TweetPageState createState() => _TweetPageState();
}

class _TweetPageState extends State<TweetPage> {
  late MelonThemeData _theme;

  @override
  Widget build(BuildContext context) {
    _theme = MelonTheme.of(context);

    return BlocBuilder<TweetDetailCubit, TweetDetailState>(
        builder: (context, state) {
      bool isActiveBlurNavigationBar = false;

      return Container(
        color: _theme.backgroundColor(),
        child: Stack(
          fit: StackFit.loose,
          children: [
            CupertinoPageScaffold(
              backgroundColor: _theme.backgroundColor(),
              navigationBar: CupertinoNavigationBar(
                //brightness: disable ? Brightness.dark :null,
                border: Border(bottom: BorderSide(color: Colors.transparent)),
                backgroundColor: _theme.barColor(),
                trailing: _loadingChip(state),
                leading: MelonBouncingButton(
                  callback: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.back,
                          color: disable ? Colors.white : _theme.textColor(),
                        ),
                        Text(
                          widget.fromTitle,
                          style: GoogleFonts.itim(
                              color:
                                  disable ? Colors.white : _theme.textColor(),
                              fontSize: 18),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              child: Container(
                  color: _theme.backgroundColor(), child: _area(state)),
            ),
            isActiveBlurNavigationBar
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.of(context).padding.bottom,
                      width: MediaQuery.of(context).size.width,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                          child: Container(
                            color: Colors.black.withOpacity(0.0),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      );
    });
  }
}
