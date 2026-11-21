import 'package:flutter/material.dart';

import '../theme/rf_tokens.dart';

// Focus, Enter/Space activation and a focus ring for the custom Rf controls.
class RfTappable extends StatefulWidget {
  const RfTappable({
    required this.child,
    required this.onTap,
    this.radius = 0,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onLongPressStart,
    this.onLongPressEnd,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double radius;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final VoidCallback? onTapCancel;
  final GestureLongPressStartCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  @override
  State<RfTappable> createState() => _RfTappableState();
}

class _RfTappableState extends State<RfTappable> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    final enabled = onTap != null;
    return FocusableActionDetector(
      enabled: enabled,
      mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            onTap?.call();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onTapDown: enabled ? widget.onTapDown : null,
        onTapUp: enabled ? widget.onTapUp : null,
        onTapCancel: enabled ? widget.onTapCancel : null,
        onLongPressStart: enabled ? widget.onLongPressStart : null,
        onLongPressEnd: enabled && widget.onLongPressEnd != null
            ? (_) => widget.onLongPressEnd!()
            : null,
        onLongPressCancel: enabled ? widget.onLongPressEnd : null,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: _focused
                ? Border.all(color: RfColors.of(context).actionInk, width: 2)
                : null,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
