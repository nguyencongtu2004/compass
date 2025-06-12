import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

/// Widget chung để hiển thị ảnh từ URL với cache
class CommonCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Border? border;
  final Widget? placeholder;
  final Widget? errorWidget;
  final List<BoxShadow>? boxShadow;

  const CommonCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.border,
    this.placeholder,
    this.errorWidget,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        border: border,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit,
          width: width,
          height: height,
          placeholder: (context, url) =>
              placeholder ??
              Container(
                width: width,
                height: height,
                color: AppColors.surfaceVariant(context),
                child: Icon(
                  Icons.image,
                  color: AppColors.onSurfaceVariant(context),
                ),
              ),
          errorWidget: (context, url, error) =>
              errorWidget ??
              Container(
                width: width,
                height: height,
                color: AppColors.surfaceVariant(context),
                child: Icon(
                  Icons.broken_image,
                  color: AppColors.onSurfaceVariant(context),
                ),
              ),
        ),
      ),
    );
  }
}
