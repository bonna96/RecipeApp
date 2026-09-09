import 'package:flutter/material.dart';

/// Interactive Hover widget providing elevation lift, shadow expansion,
/// cursor updates, and hover state callbacks for Desktop and Web.
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double translateY;
  final double borderRadius;
  final Duration duration;
  final Color? hoverBorderColor;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.translateY = -8.0,
    this.borderRadius = 24.0,
    this.duration = const Duration(milliseconds: 220),
    this.hoverBorderColor,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? widget.translateY : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: (widget.hoverBorderColor ?? Colors.black).withOpacity(0.16),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
