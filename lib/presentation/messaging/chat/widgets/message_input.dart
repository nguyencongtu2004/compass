import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isEnabled;
  final Color? backgroundColor;
  final bool autoFocus;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.isEnabled = true,
    this.backgroundColor,
    this.autoFocus = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    
    // Auto focus nếu được yêu cầu
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
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
      // Giữ focus để không ẩn bàn phím sau khi gửi
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: widget.backgroundColor ?? AppColors.surface(context),

      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.isEnabled,
                maxLines: 5,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: TextStyle(color: AppColors.onSurface(context)),
                decoration: InputDecoration(
                  hintText: context.l10n.enterMessage,
                  hintStyle: TextStyle(
                    color: AppColors.onSurface(context).withValues(alpha: 0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground(
                    context,
                  ), // Sử dụng màu chung
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            IconButton.filled(
              onPressed: _hasText && widget.isEnabled ? _sendMessage : null,
              icon: Icon(
                Icons.send,
                size: AppSpacing.iconMd,
                color: _hasText && widget.isEnabled
                    ? AppColors.primary(context)
                    : AppColors.onSurface(context).withValues(alpha: 0.4),
              ),
              style: IconButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
