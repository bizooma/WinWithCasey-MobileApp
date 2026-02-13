import 'package:flutter/material.dart';

/// A pinned bottom bar for short legal/privacy disclaimers.
///
/// Use as `Scaffold.bottomNavigationBar` so it stays visible at all times.
class LegalDisclaimerBar extends StatelessWidget {
  final String text;

  /// Height used by consuming screens to pad scrollable content.
  static const double preferredHeight = 88;

  const LegalDisclaimerBar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodySmall;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.6), width: 1),
            ),
          ),
          child: SizedBox(
            height: preferredHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: textStyle?.copyWith(
                    height: 1.35,
                    color: colorScheme.onSurface.withValues(alpha: 0.78),
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
