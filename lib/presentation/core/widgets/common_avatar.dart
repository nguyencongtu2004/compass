import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommonAvatar extends StatelessWidget {
  final double radius;
  final String? avatarUrl;
  final String? displayName;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final IconData? fallbackIcon;
  final Color? borderColor;
  final double borderWidth;

  const CommonAvatar({
    super.key,
    required this.radius,
    this.avatarUrl,
    this.displayName,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.fallbackIcon,
    this.borderColor,
    this.borderWidth = 2.0,
  });

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '';

    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }

    return words
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');
  }

  Widget _buildFallbackContent(BuildContext context) {
    // Nếu có tên, hiển thị chữ cái đầu
    if (displayName != null && displayName!.trim().isNotEmpty) {
      final initials = _getInitials(displayName!);
      return Text(
        initials,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // Nếu không có tên, hiển thị icon mặc định
    return Icon(
      fallbackIcon ?? Icons.person,
      size: radius * 0.8,
      color: iconColor ?? Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = backgroundColor ?? theme.colorScheme.primary;

    Widget avatarWidget = CircleAvatar(
      radius: radius,
      backgroundColor: defaultBackgroundColor,
      child: avatarUrl != null && avatarUrl!.trim().isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 300),
                placeholder: (context, url) => Container(
                  width: radius * 2,
                  height: radius * 2,
                  color: defaultBackgroundColor,
                  child: Center(child: _buildFallbackContent(context)),
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    width: radius * 2,
                    height: radius * 2,
                    color: defaultBackgroundColor,
                    child: Center(child: _buildFallbackContent(context)),
                  );
                },
                // Callback khi load thành công
                imageBuilder: (context, imageProvider) => Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            )
          : _buildFallbackContent(context),
    );

    // Nếu có borderColor thì wrap với Container để tạo viền
    if (borderColor != null) {
      return Container(
        width: (radius + borderWidth + 2) * 2,
        height: (radius + borderWidth + 2) * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor!, width: borderWidth),
        ),
        child: Center(child: avatarWidget),
      );
    }

    return avatarWidget;
  }
}
