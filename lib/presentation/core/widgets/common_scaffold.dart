import 'package:flutter/material.dart';

class CommonScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? drawer;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final bool isLoading;
  final bool isAppBarOverlay;

  const CommonScaffold({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.drawer,
    this.appBar,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.isLoading = false,
    this.isAppBarOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        Positioned.fill(
          child: Scaffold(
            
            appBar: isAppBarOverlay ? null : appBar as PreferredSizeWidget?,
            bottomNavigationBar: bottomNavigationBar,
            body: body,
            floatingActionButton: floatingActionButton,
            drawer: drawer,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          ),
        ),
        if (isAppBarOverlay && appBar != null)
          Positioned(top: 0, left: 0, right: 0, child: appBar!),
      ],
    );
  }
}
