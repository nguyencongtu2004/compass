import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AddFriendSection extends StatefulWidget {
  final TextEditingController emailController;
  final bool isSearching;
  final VoidCallback onAddFriend;
  final VoidCallback? onClear;

  const AddFriendSection({
    super.key,
    required this.emailController,
    required this.isSearching,
    required this.onAddFriend,
    this.onClear,
  });

  @override
  State<AddFriendSection> createState() => _AddFriendSectionState();
}

class _AddFriendSectionState extends State<AddFriendSection> {
  @override
  void initState() {
    super.initState();
    widget.emailController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.emailController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surfaceVariant(context),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.emailController,
              decoration: InputDecoration(
                hintText: 'Nhập email để thêm bạn',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm2,
                  vertical: AppSpacing.xs2,
                ),
                suffixIcon:
                    widget.emailController.text.isNotEmpty &&
                        widget.onClear != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          widget.emailController.clear();
                          widget.onClear?.call();
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs2),
          ElevatedButton(
            onPressed: widget.isSearching ? null : widget.onAddFriend,
            child: widget.isSearching
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}
