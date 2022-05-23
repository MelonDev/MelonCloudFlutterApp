import 'dart:ui';

import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meloncloud_flutter_app/tools/melon_bouncing_button.dart';
import 'package:meloncloud_flutter_app/tools/melon_theme.dart';

import 'melon_context_menu_action.dart';
import 'on_hover.dart';

class MelonPopupMenuButton extends StatefulWidget {
  MelonPopupMenuButton({
    Key? key,
    @required this.actions,
    this.width,
    this.borderRadius,
    this.blurRadius,
    this.color,
    this.opacity,
    this.alignment,
    this.button,
  }) : super(key: key);

  final List<MelonPopupMenuAction?>? actions;
  final double? width;
  final BorderRadius? borderRadius;
  final double? blurRadius;
  final Color? color;
  final double? opacity;
  final Alignment? alignment;
  final MelonBouncingButton? button;

  @override
  _MelonPopupMenuButtonState createState() => _MelonPopupMenuButtonState();
}

class _MelonPopupMenuButtonState extends State<MelonPopupMenuButton>
    with SingleTickerProviderStateMixin {
  var _isOpened = false;
  late AnimationController _animationController;
  late Animation<Matrix4> _transformAnimation;
  late Orientation? _orientation;

  late MelonThemeData _theme;

  @override
  void initState() {
    super.initState();
    _orientation = null;
    _animationController = AnimationController(vsync: this);
    _transformAnimation = _animationController
        .drive(
      CurveTween(curve: Curves.easeOutQuint),
    )
        .drive(
      Matrix4Tween(
        begin: Matrix4.identity()
          ..scale(0.01, 0.01),
        end: Matrix4.identity(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orientation = MediaQuery
        .of(context)
        .orientation;
    if (_orientation != null && _orientation != orientation) {
      _close();
    }
    _orientation = orientation;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _open() {
    if (_isOpened) {
      return;
    }
    setState(() {
      _isOpened = true;
    });
    _animationController
      ..duration = const Duration(milliseconds: 300)
      ..forward();
  }

  Future<void> _close() async {
    if (!_isOpened) {
      return;
    }
    _animationController.duration = const Duration(milliseconds: 200);
    await _animationController.reverse();
    setState(() {
      _isOpened = false;
    });
  }

  Widget _outsideArea() {
    return PortalTarget(
      visible: _isOpened,
      portalFollower: GestureDetector(
        onTapDown: (_) => _close(),
      ),
      child: Material(
        color: Colors.transparent,
        child: _portalArea(),
      ),
    );
  }

  Widget _portalArea() {
    return PortalTarget(
      visible: _isOpened,
      anchor: Aligned(
        follower: widget.alignment != null
            ? _portalAnchor(widget.alignment!)
            : const Alignment(1.00, -1.15),
        target: widget.alignment ?? Alignment.bottomRight,
      ),
      portalFollower: AnimatedBuilder(
        animation: _transformAnimation,
        builder: (context, child) {
          return Transform(
            transform: _transformAnimation.value,
            alignment: const Alignment(0.9, -1),
            child: child,
          );
        },
        child: _menuArea(),
      ),
      child: _button(),
    );
  }

  Alignment _portalAnchor(Alignment alignment) {
    if (alignment == Alignment.bottomRight) {
      return const Alignment(1.00, -1.15);
    } else if (alignment == Alignment.bottomLeft) {
      return const Alignment(-1.00, -1.15);
    } else if (alignment == Alignment.topRight) {
      return const Alignment(1.00, 1.15);
    } else if (alignment == Alignment.topLeft) {
      return const Alignment(-1.00, 1.15);
    } else {
      return const Alignment(1.00, -1.15);
    }
  }

  Widget _button() {
    return OnHover(
      x: 2.0,
      y: 3.0,
      z: 0.84,
      builder: (bool isHovered) {
        return widget.button ??
            MelonBouncingButton(
              callback: _open,
              isBouncing: true,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: _isOpened
                        ? (isHovered
                        ? _theme.textColor().withOpacity(0.7)
                        : _theme.textColor().withOpacity(0.9))
                        : (isHovered
                        ? _theme.textColor().withOpacity(0.3)
                        : _theme.textColor().withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(30)),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.ellipsis,
                            size: 20,
                            color: _isOpened
                                ? _theme.backgroundColor()
                                : _theme.textColor(),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
      },
    );
  }

  Widget _menuArea() {
    return Container(
      width: widget.width ?? 230,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 80,
            spreadRadius: 10,
          ),
        ],
      ),
      child: _insideMenuArea(),
    );
  }

  Widget _insideMenuArea() {
    widget.actions?.removeWhere((value) => value == null);
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurRadius ?? 16.0,
          sigmaY: widget.blurRadius ?? 16.0,
        ),
        child: Container(
            color: widget.color != null
                ? widget.color?.withOpacity(widget.opacity ?? 0.1)
                : (_theme.isDark()
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.6)),
            //: _theme.onColor().withOpacity(0.05),
            padding : const EdgeInsets.only(bottom: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.actions != null
                  ? widget.actions!.map(
                    (action) {
                  if (action is MelonPopupMenuButtonAction) {
                    return Column(
                        children: [
                          OnHover(
                            x: 6.0, y: 2, z: 0.90,
                            builder: (bool isHovered) {
                              return MelonContextMenuAction(
                                child: action.child ??
                                    Text(
                                      action.title ?? "",
                                      style: action.style ?? GoogleFonts.itim(),
                                    ),
                                disableBottomBorder:
                                true,
                                isDefaultAction: action.isDefaultAction!,
                                isDestructiveAction:
                                action.isDestructiveAction!,
                                onPressed: () {
                                  _close();
                                  if (action.onPressed != null) {
                                    action.onPressed!();
                                  }
                                },
                                trailingIcon: action.trailingIcon,
                              );
                            },
                          ),
                          action != widget.actions!.last ? Container(
                            height: 2.0,
                              width: MediaQuery.of(context).size.width,
                              color : _theme.isDark()
                                  ? _theme.backgroundColor().withOpacity(0.6)
                                  : _theme.onColor().withOpacity(0.05)
                          ) : Container()

                        ]
                    );
                  } else if (action is MelonPopupMenuSpacingAction) {
                    return SizedBox(
                      height: 10,
                      child: Container(
                        color: _theme.isDark()
                            ? _theme.backgroundColor().withOpacity(0.6)
                            : _theme.onColor().withOpacity(0.05),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ).toList()
                  : [],
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _theme = MelonTheme.of(context);

    return _outsideArea();
  }
}

class MelonPopupMenuAction {}

class MelonPopupMenuSpacingAction extends MelonPopupMenuAction {}

class MelonPopupMenuButtonAction extends MelonPopupMenuAction {
  MelonPopupMenuButtonAction({
    this.child,
    this.title,
    this.style,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.onPressed,
    this.trailingIcon,
  });

  final title;
  final TextStyle? style;
  final Widget? child;
  final bool? isDefaultAction;
  final bool? isDestructiveAction;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
}
