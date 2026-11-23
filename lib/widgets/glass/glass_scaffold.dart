import 'package:flutter/material.dart';

import 'glass_app_bar.dart';
import 'glass_background.dart';

/// Scaffold with glass wallpaper background and transparent surface.
class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBodyBehindAppBar = false,
    this.safeArea = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBodyBehindAppBar;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    Widget content = body ?? const SizedBox.shrink();
    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        const GlassBackground(child: SizedBox.expand()),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          body: content,
        ),
      ],
    );
  }
}

/// Convenience: glass scaffold with [GlassAppBar] title string.
class GlassPage extends StatelessWidget {
  const GlassPage({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.safeArea = true,
    this.showBackButton = true,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool safeArea;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      safeArea: safeArea,
      appBar: title != null
          ? GlassAppBar(
              title: Text(title!),
              actions: actions,
              automaticallyImplyLeading: showBackButton,
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}
