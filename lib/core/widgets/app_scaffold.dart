import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/settings/presentation/providers/settings_provider.dart';

/// Scaffold shared by every screen so the background photo (or themed
/// gradient fallback) and its scrim stay identical app-wide.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bgPath = context.watch<SettingsProvider>().settings.backgroundImagePath;

    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: bgPath != null
                ? Image.file(File(bgPath), key: ValueKey(bgPath), fit: BoxFit.cover)
                : Container(
                    key: const ValueKey('no-bg'),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [scheme.primaryContainer, scheme.surface],
                      ),
                    ),
                  ),
          ),
        ),
        // Scrim: keeps text legible over any photo, in either theme.
        Positioned.fill(
          child: Container(
            color: scheme.surface.withValues(alpha: bgPath != null ? 0.55 : 0.0),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: body,
          floatingActionButton: floatingActionButton,
        ),
      ],
    );
  }
}
