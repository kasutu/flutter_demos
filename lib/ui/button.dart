import 'package:flutter/material.dart';

enum _Variant { primary, secondary, outline, ghost }

// --- PUBLIC API ---

class PrimaryButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isFullWidth;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.isFullWidth = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) => _CoreButton(
    variant: _Variant.primary,
    title: title,
    icon: icon,
    onTap: onTap,
    isFullWidth: isFullWidth,
    width: width,
  );
}

class SecondaryButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isFullWidth;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.isFullWidth = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) => _CoreButton(
    variant: _Variant.secondary,
    title: title,
    icon: icon,
    onTap: onTap,
    isFullWidth: isFullWidth,
    width: width,
  );
}

class OutlineButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isFullWidth;
  final double? width;

  const OutlineButton({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.isFullWidth = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) => _CoreButton(
    variant: _Variant.outline,
    title: title,
    icon: icon,
    onTap: onTap,
    isFullWidth: isFullWidth,
    width: width,
  );
}

class GhostButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isFullWidth;
  final double? width;

  const GhostButton({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.isFullWidth = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) => _CoreButton(
    variant: _Variant.ghost,
    title: title,
    icon: icon,
    onTap: onTap,
    isFullWidth: isFullWidth,
    width: width,
  );
}

// --- INTERNAL ENGINE ---

class _CoreButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isFullWidth;
  final double? width;
  final _Variant variant;

  const _CoreButton({
    required this.variant,
    required this.title,
    this.icon,
    this.onTap,
    this.isFullWidth = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Tablet-Optimized Base Styling
    final baseStyle = ButtonStyle(
      animationDuration: const Duration(milliseconds: 50),
      overlayColor: WidgetStateProperty.all(
        theme.colorScheme.onSurface.withValues(alpha: 0.1),
      ),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      // Wider padding for tablet layouts
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 32),
      ),
    );

    // 2. Foreground Color Logic
    Color resolveFg(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return theme.colorScheme.onSurface.withValues(alpha: 0.38);
      }
      switch (variant) {
        case _Variant.primary:
          return theme.colorScheme.onPrimary;
        case _Variant.secondary:
          return theme.colorScheme.onSecondary;
        default:
          return theme.colorScheme.onSurface;
      }
    }

    // 3. Build Button Node
    Widget buttonNode;
    switch (variant) {
      case _Variant.primary:
      case _Variant.secondary:
        buttonNode = FilledButton(
          onPressed: onTap,
          style: baseStyle.copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return theme.colorScheme.onSurface.withValues(alpha: 0.12);
              }
              return variant == _Variant.primary
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary;
            }),
            foregroundColor: WidgetStateProperty.resolveWith(resolveFg),
          ),
          child: _buildContent(),
        );
        break;

      case _Variant.outline:
        buttonNode = OutlinedButton(
          onPressed: onTap,
          style: baseStyle.copyWith(
            foregroundColor: WidgetStateProperty.resolveWith(resolveFg),
            side: WidgetStateProperty.resolveWith(
              (states) => BorderSide(
                color: states.contains(WidgetState.disabled)
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
                    : theme.colorScheme.outlineVariant,
                width: 2.0, // Slightly thicker border for 56px height
              ),
            ),
          ),
          child: _buildContent(),
        );
        break;

      case _Variant.ghost:
        buttonNode = TextButton(
          onPressed: onTap,
          style: baseStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            foregroundColor: WidgetStateProperty.resolveWith(resolveFg),
          ),
          child: _buildContent(),
        );
        break;
    }

    // 4. Tablet Standard Sizing Constraint (Height: 56px)
    return SizedBox(
      height: 56.0,
      width: isFullWidth ? double.infinity : width,
      child: buttonNode,
    );
  }

  // 5. Tablet Content Layout (18px text, 24px icons)
  Widget _buildContent() {
    final textWidget = Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 18.0, // Scaled up for tablet readability
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24.0), // Standard tablet icon scale
          const SizedBox(
            width: 12,
          ), // Adjusted spacing for the larger font/icon
          Flexible(child: textWidget),
        ],
      );
    }

    return textWidget;
  }
}
