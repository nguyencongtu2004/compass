import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_appbar.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_scaffold.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_button.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_textfield.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/models/user_model.dart';
import 'package:minecraft_compass/router/app_routes.dart';
import 'package:minecraft_compass/utils/validator.dart';
import 'bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isUsernameAvailable = true;
  bool _isCheckingUsername = false;
  bool _isDeletingImage = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _displayNameController.text = widget.user.displayName;
    _usernameController.text = widget.user.username;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _onAvatarTap() {
    // lựa chọn xóa hoặc thay đổi ảnh đại diện
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.profilePicture),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(context.l10n.selectPhotosFromTheLibrary),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(context.l10n.deleteProfilePicture),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    _isDeletingImage = true;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn ảnh: $e'),
          backgroundColor: AppColors.error(context),
        ),
      );
    }
  }

  void _checkUsernameAvailability(String username) {
    if (username.isEmpty || username == widget.user.username) {
      setState(() {
        _isUsernameAvailable = true;
        _isCheckingUsername = false;
      });
      return;
    }

    setState(() => _isCheckingUsername = true);

    context.read<ProfileBloc>().add(UsernameAvailabilityCheck(username));
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate() && _isUsernameAvailable) {
      final displayName = _displayNameController.text.trim();
      final username = _usernameController.text.trim();

      // Chỉ cập nhật nếu có thay đổi
      final hasDisplayNameChanged = displayName != widget.user.displayName;
      final hasUsernameChanged = username != widget.user.username;
      final hasImageChanged = _selectedImage != null;
      final hasImageRemoved = _isDeletingImage;

      if (hasDisplayNameChanged ||
          hasUsernameChanged ||
          hasImageChanged ||
          hasImageRemoved) {
        setState(() => _isUpdating = true);

        context.read<ProfileBloc>().add(
          ProfileUpdateRequested(
            displayName: hasDisplayNameChanged ? displayName : null,
            username: hasUsernameChanged ? username : null,
            avatarFile: _selectedImage,
            isAvatarRemoved: _isDeletingImage,
          ),
        );
      } else {
        context.go(AppRoutes.profileRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppbar(
        title: context.l10n.editProfile,
        leftWidget: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, size: AppSpacing.md4),
        ),
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && _isUpdating) {
            // Profile updated successfully - now showing updated data
            setState(() => _isUpdating = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.profileUpdatedSuccessfully),
                backgroundColor: AppColors.success(context),
              ),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            setState(() => _isUpdating = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error(context),
              ),
            );
          } else if (state is UsernameAvailable) {
            setState(() {
              _isUsernameAvailable = state.isAvailable;
              _isCheckingUsername = false;
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md3),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar section
                Center(
                  child: GestureDetector(
                    onTap: _onAvatarTap,
                    child: Stack(
                      children: [
                        _selectedImage != null
                            ? CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.primary(context),
                                backgroundImage: FileImage(_selectedImage!),
                              )
                            : CommonAvatar(
                                radius: 60,
                                avatarUrl: _isDeletingImage
                                    ? null
                                    : widget.user.avatarUrl,
                                displayName: widget.user.displayName,
                                backgroundColor: AppColors.primary(context),
                                fallbackIcon: Icons.person,
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary(context),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg3),

                // Display Name field
                CommonTextField(
                  labelText: context.l10n.displayName,
                  hintText: context.l10n.enterYourDisplayName,
                  controller: _displayNameController,
                  prefixIcon: Icons.person_outlined,
                  validator: (value) =>
                      Validator.validateDisplayName(value, context),
                ),
                const SizedBox(height: AppSpacing.md),

                // Username field
                CommonTextField(
                  labelText: context.l10n.userName,
                  hintText: context.l10n.enterYourUsernameEGNguoidep123,
                  controller: _usernameController,
                  prefixIcon: Icons.alternate_email,
                  suffixIcon: _isCheckingUsername
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _isUsernameAvailable ? Icons.check : Icons.close,
                          color: _isUsernameAvailable
                              ? AppColors.success(context)
                              : AppColors.error(context),
                        ),
                  onChanged: (value) {
                    // Debounce username check
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_usernameController.text == value) {
                        _checkUsernameAvailability(value);
                      }
                    });
                  },
                  validator: (value) =>
                      Validator.validateUsername(value, context),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (!_isUsernameAvailable)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.theUsernameHasAlreadyBeenUsed,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error(context),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg3),

                // Email field (readonly)
                CommonTextField(
                  labelText: context.l10n.email,
                  controller: TextEditingController(text: widget.user.email),
                  prefixIcon: Icons.email_outlined,
                  enabled: false,
                ),
                const SizedBox(height: AppSpacing.lg3),

                // Update button
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    return CommonButton(
                      text: context.l10n.updateProfile,
                      onPressed: _updateProfile,
                      isLoading: state is ProfileUpdateLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
