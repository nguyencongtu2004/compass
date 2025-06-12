import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isEnabled;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.isEnabled = true,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && widget.isEnabled) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          top: BorderSide(
            color: AppColors.outline(context).withValues(alpha: 0.2),
            width: AppSpacing.border,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.isEnabled,
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    borderSide: BorderSide(
                      color: AppColors.outline(context).withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    borderSide: BorderSide(
                      color: AppColors.outline(context).withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    borderSide: BorderSide(
                      color: AppColors.primary(context),
                      width: AppSpacing.border2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm2,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant(
                    context,
                  ).withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Material(
              color: _hasText && widget.isEnabled
                  ? AppColors.primary(context)
                  : AppColors.surfaceVariant(context),
              borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
              child: InkWell(
                onTap: _hasText && widget.isEnabled ? _sendMessage : null,
                borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                child: Container(
                  width: AppSpacing.lg2,
                  height: AppSpacing.lg2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                  ),
                  child: Icon(
                    Icons.send,
                    size: AppSpacing.iconSm,
                    color: _hasText && widget.isEnabled
                        ? AppColors.onPrimary(context)
                        : AppColors.onSurfaceVariant(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
