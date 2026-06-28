import 'package:flutter/material.dart';

/// Industrial-styled flat action button.
///
/// Features sharp zero-radius corners, clear color-inversion on interaction,
/// and an optional icon configuration.
class Button extends StatefulWidget {
  final String title;
  final IconData? icon; // 1. Made IconData nullable
  final VoidCallback? onTap;
  final bool isIconOnly;
  final Color? accentColor;

  const Button({
    super.key,
    required this.title,
    this.icon, // 2. Removed the 'required' constraint
    this.onTap,
    this.isIconOnly = false,
    this.accentColor,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool enabled = widget.onTap != null;

    final Color accent = widget.accentColor ?? theme.colorScheme.primary;
    final Color chassis = theme.colorScheme.surface;

    final Color backgroundColor = enabled
        ? (_isPressed ? accent : chassis)
        : chassis;

    final Color borderColor = enabled
        ? accent
        : theme.colorScheme.onSurface.withValues(alpha: 0.15);

    final Color contentColor = enabled
        ? (_isPressed
              ? (widget.accentColor == null
                    ? theme.colorScheme.onPrimary
                    : chassis)
              : accent)
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);

    return RepaintBoundary(
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.title,
        child: MouseRegion(
          cursor: enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          child: GestureDetector(
            onTapDown: enabled
                ? (_) => setState(() => _isPressed = true)
                : null,
            onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
            onTapCancel: enabled
                ? () => setState(() => _isPressed = false)
                : null,
            onTap: enabled ? widget.onTap : null,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(color: borderColor, width: 1.5),
                borderRadius: BorderRadius.zero,
              ),
              padding: widget.isIconOnly
                  ? const EdgeInsets.all(16)
                  : const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3. Conditionally render icon and structural gap spacing
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: widget.isIconOnly ? 24 : 20,
                      color: contentColor,
                    ),
                    if (!widget.isIconOnly) const SizedBox(width: 12),
                  ],
                  if (!widget.isIconOnly)
                    Text(
                      widget.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: contentColor,
                      ),
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
