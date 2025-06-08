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
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.outline(context).withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: widget.emailController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm bạn bè qua email...',
            hintStyle: TextStyle(
              color: AppColors.onSurfaceVariant(context).withValues(alpha: 0.7),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.onSurfaceVariant(context).withValues(alpha: 0.7),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.emailController.text.isNotEmpty &&
                    widget.onClear != null)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.onSurfaceVariant(context),
                      size: 20,
                    ),
                    onPressed: () {
                      widget.emailController.clear();
                      widget.onClear?.call();
                    },
                  ),
                Container(
                  margin: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Material(
                    color:
                        widget.isSearching ||
                            widget.emailController.text.trim().isEmpty
                        ? AppColors.surfaceVariant(context)
                        : AppColors.primary(context),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap:
                          widget.isSearching ||
                              widget.emailController.text.trim().isEmpty
                          ? null
                          : widget.onAddFriend,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: widget.isSearching
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.onSurfaceVariant(context),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.person_add,
                                color:
                                    widget.emailController.text.trim().isEmpty
                                    ? AppColors.onSurfaceVariant(context)
                                    : AppColors.onPrimary(context),
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
