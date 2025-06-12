import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_cached_network_image.dart';
import '../../../newfeed/bloc/newsfeed_bloc.dart';
import '../../../../models/message_model.dart';
import '../../../../models/newsfeed_post_model.dart';
import '../../../../utils/format_utils.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isFromMe;
  final bool showTimestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isFromMe,
    this.showTimestamp = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  NewsfeedPost? post;
  bool isLoadingPost = false;

  @override
  void initState() {
    super.initState();
    if (widget.message.isPost) {
      _loadPost();
    }
  }

  void _loadPost() async {
    if (widget.message.content.isEmpty) return;

    setState(() => isLoadingPost = true);

    try {
      final loadedPost = await context
          .read<NewsfeedBloc>()
          .newsfeedRepository
          .getPostById(widget.message.content);

      if (mounted) {
        setState(() {
          post = loadedPost;
          isLoadingPost = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingPost = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.isFromMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // Hiển thị timestamp căn giữa trước tin nhắn
        if (widget.showTimestamp) ...[
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant(
                    context,
                  ).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  FormatUtils.formatMessageTime(widget.message.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant(context),
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
        // Message bubble - giữ nguyên vị trí bình thường
        Container(
          margin: EdgeInsets.only(
            bottom: AppSpacing.sm,
            left: widget.isFromMe ? AppSpacing.xl : AppSpacing.md,
            right: widget.isFromMe ? AppSpacing.md : AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: widget.isFromMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm2,
                ),
                decoration: BoxDecoration(
                  color: widget.isFromMe
                      ? AppColors.primary(context)
                      : AppColors.surfaceVariant(context),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppSpacing.radiusLg),
                    topRight: const Radius.circular(AppSpacing.radiusLg),
                    bottomLeft: Radius.circular(
                      widget.isFromMe
                          ? AppSpacing.radiusLg
                          : AppSpacing.radiusSm,
                    ),
                    bottomRight: Radius.circular(
                      widget.isFromMe
                          ? AppSpacing.radiusSm
                          : AppSpacing.radiusLg,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.message.isPost) ...[
                      _buildPostPreview(),
                    ] else ...[
                      Text(
                        widget.message.content,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: widget.isFromMe
                              ? AppColors.onPrimary(context)
                              : AppColors.onSurface(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Hiển thị trạng thái đã đọc
              if (widget.isFromMe && widget.message.isRead) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.done_all,
                      size: AppSpacing.iconXs,
                      color: AppColors.primary(context),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostPreview() {
    if (isLoadingPost) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: widget.isFromMe
              ? Colors.white.withValues(alpha: 0.2)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: AppSpacing.iconSm,
              height: AppSpacing.iconSm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.isFromMe
                      ? AppColors.onPrimary(context)
                      : AppColors.onSurface(context),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Đang tải bài đăng...',
              style: AppTextStyles.bodySmall.copyWith(
                color: widget.isFromMe
                    ? AppColors.onPrimary(context)
                    : AppColors.onSurface(context),
              ),
            ),
          ],
        ),
      );
    }

    if (post == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: widget.isFromMe
              ? Colors.white.withValues(alpha: 0.2)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSpacing.iconSm,
              color: widget.isFromMe
                  ? AppColors.onPrimary(context)
                  : AppColors.error(context),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Bài đăng không tồn tại',
              style: AppTextStyles.bodySmall.copyWith(
                color: widget.isFromMe
                    ? AppColors.onPrimary(context)
                    : AppColors.error(context),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: widget.isFromMe
            ? Colors.white.withValues(alpha: 0.2)
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.image,
                size: AppSpacing.iconSm,
                color: widget.isFromMe
                    ? AppColors.onPrimary(context)
                    : AppColors.primary(context),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Bài đăng',
                style: AppTextStyles.bodySmall.copyWith(
                  color: widget.isFromMe
                      ? AppColors.onPrimary(context)
                      : AppColors.onSurface(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (post!.caption?.isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              post!.caption!,
              style: AppTextStyles.bodySmall.copyWith(
                color: widget.isFromMe
                    ? AppColors.onPrimary(context).withValues(alpha: 0.8)
                    : AppColors.onSurfaceVariant(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: CommonCachedNetworkImage(
              imageUrl: post!.imageUrl,
              width: 120,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
