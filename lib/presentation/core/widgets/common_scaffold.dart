import 'package:flutter/material.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';

class CommonScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? drawer;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final bool isLoading;

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
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: appBar,
          bottomNavigationBar: bottomNavigationBar,
          body: body,
          floatingActionButton: floatingActionButton,
          drawer: drawer,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        ),
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary(context),
              ),
            ),
          ),
      ],
    );
  }
}
