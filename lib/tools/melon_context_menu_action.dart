import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'melon_theme.dart';

class MelonContextMenuAction extends StatefulWidget {
  const MelonContextMenuAction({
    Key? key,
    @required this.child,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.onPressed,
    this.disableBottomBorder = false,
    this.bottomBorderColor,
    this.backgroundColorPressed,
    this.onColorPressed,
    this.backgroundColor = Colors.transparent,
    this.style,
    this.trailingIcon,
  })  : assert(child != null),
        assert(isDefaultAction != null),
        assert(isDestructiveAction != null),
        super(key: key);

  final Widget? child;
  final bool disableBottomBorder;

  final bool isDefaultAction;

  final bool isDestructiveAction;

  final Color? bottomBorderColor;

  final VoidCallback? onPressed;

  final TextStyle? style;
  final IconData? trailingIcon;
  final Color? backgroundColorPressed;
  final Color? onColorPressed;
  final Color? backgroundColor;

  @override
  _MelonContextMenuActionState createState() => _MelonContextMenuActionState();
}

class _MelonContextMenuActionState extends State<MelonContextMenuAction> {
  static const double _kButtonHeight = 52.0;

  late MelonThemeData _theme;

  final GlobalKey _globalKey = GlobalKey();
  bool _isPressed = false;

  void onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _theme = MelonTheme.of(context);

    return GestureDetector(
      key: _globalKey,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
            minHeight: _kButtonHeight, maxHeight: _kButtonHeight),
        child: Semantics(
          button: true,
          child: Container(
            decoration: BoxDecoration(
              color: _isPressed
                  ? (widget.backgroundColorPressed ??
                      _theme.onColor().withOpacity(0.2))
                  : widget.backgroundColor,
              border: Border(
                bottom: BorderSide(
                    width: widget.disableBottomBorder ? 0.0 : 2.0,
                    color: widget.backgroundColorPressed ??
                        (widget.bottomBorderColor ??
                            (_theme.isDark()
                                ? _theme.backgroundColor().withOpacity(0.6)
                                : _theme.onColor().withOpacity(0.05)))),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 6.0,
              horizontal: 12.0,
            ),
            child: DefaultTextStyle(
              style: widget.style ??
                  GoogleFonts.itim(
                      color: (widget.isDestructiveAction
                          ? CupertinoColors.systemRed.withOpacity(0.8)
                          : _theme.onColor().withOpacity(0.8)),
                      fontSize: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: widget.child ?? Container(),
                  ),
                  if (widget.trailingIcon != null)
                    Icon(
                      widget.trailingIcon,
                      size: 24,
                      color: widget.style != null
                          ? widget.style?.color
                          : (widget.isDestructiveAction
                              ? CupertinoColors.systemRed.withOpacity(0.8)
                              : _theme.onColor().withOpacity(0.8)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
