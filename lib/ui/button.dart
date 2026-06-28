import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  void _triggerIndustrialHaptic() {
    HapticFeedback.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool enabled = onTap != null;

    final VoidCallback? wrappedOnTap = enabled
        ? () {
            _triggerIndustrialHaptic();
            onTap!();
          }
        : null;

    // 1. Shadcn-Optimized Base Transition Tuning
    final baseStyle = ButtonStyle(
      // Replicates Tailwind's 'transition-all duration-150' interpolation curve
      animationDuration: const Duration(milliseconds: 150),
      // Uses a very soft overlay highlight instead of an aggressive material ripple
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return theme.colorScheme.onSurface.withValues(alpha: 0.04);
        }
        return Colors.transparent;
      }),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 32),
      ),
    );

    // 2. Foreground State Resolver (Mimics Tailwind text token modifications)
    Color resolveFg(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return theme.colorScheme.onSurface.withValues(alpha: 0.38);
      }

      switch (variant) {
        case _Variant.primary:
          return theme.colorScheme.onPrimary; // text-primary-foreground
        case _Variant.secondary:
          return theme.colorScheme.onSecondary; // text-secondary-foreground
        case _Variant.outline:
        case _Variant.ghost:
          if (states.contains(WidgetState.pressed)) {
            return theme.colorScheme.onSecondary; // text-accent-foreground
          }
          return theme.colorScheme.onSurface;
      }
    }

    // 3. Native Button Compilation Layer
    Widget buttonNode;
    switch (variant) {
      case _Variant.primary:
      case _Variant.secondary:
        buttonNode = FilledButton(
          onPressed: wrappedOnTap,
          style: baseStyle.copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return theme.colorScheme.onSurface.withValues(alpha: 0.12);
              }

              final baseBg = variant == _Variant.primary
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary;

              // Replicates 'hover:bg-primary/90' and 'hover:bg-secondary/80' alpha blending
              if (states.contains(WidgetState.pressed)) {
                return baseBg.withValues(
                  alpha: variant == _Variant.primary ? 0.50 : 0.40,
                );
              }
              return baseBg;
            }),
            foregroundColor: WidgetStateProperty.resolveWith(resolveFg),
          ),
          child: _buildContent(),
        );
        break;

      case _Variant.outline:
        buttonNode = OutlinedButton(
          onPressed: wrappedOnTap,
          style: baseStyle.copyWith(
            // Replicates 'hover:bg-accent' by gracefully loading your secondary layout surface
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return theme.colorScheme.secondary;
              }
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith(resolveFg),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return BorderSide(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                  width: 2.0,
                );
              }
              return BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 2.0,
              );
            }),
          ),
          child: _buildContent(),
        );
        break;

      case _Variant.ghost:
        buttonNode = TextButton(
          onPressed: wrappedOnTap,
          style: baseStyle.copyWith(
            // Replicates 'hover:bg-accent' on empty backgrounds
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return theme.colorScheme.secondary;
              }
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith(resolveFg),
          ),
          child: _buildContent(),
        );
        break;
    }

    return SizedBox(
      height: 56.0,
      width: isFullWidth ? double.infinity : width,
      child: buttonNode,
    );
  }

  Widget _buildContent() {
    final textWidget = Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 18.0,
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
          Icon(icon, size: 24.0),
          const SizedBox(width: 12),
          Flexible(child: textWidget),
        ],
      );
    }

    return textWidget;
  }
}
