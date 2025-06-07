import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_scaffold.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_button.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_textfield.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/models/user_model.dart';
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
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

    setState(() {
      _isCheckingUsername = true;
    });

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

      if (hasDisplayNameChanged || hasUsernameChanged || hasImageChanged) {
        context.read<ProfileBloc>().add(
          ProfileUpdateRequested(
            displayName: hasDisplayNameChanged ? displayName : null,
            username: hasUsernameChanged ? username : null,
            avatarFile: _selectedImage,
          ),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Cập nhật hồ sơ thành công!'),
                backgroundColor: AppColors.success(context),
              ),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
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
                              avatarUrl: widget.user.avatarUrl,
                              displayName: widget.user.displayName,
                              backgroundColor: AppColors.primary(context),
                              fallbackIcon: Icons.person,
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary(context),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg3),

                // Display Name field
                CommonTextField(
                  labelText: 'Tên hiển thị',
                  hintText: 'Nhập tên hiển thị của bạn',
                  controller: _displayNameController,
                  prefixIcon: Icons.person_outlined,
                  validator: (value) => Validator.validateDisplayName(value),
                ),
                const SizedBox(height: AppSpacing.md),

                // Username field
                CommonTextField(
                  labelText: 'Tên người dùng',
                  hintText: 'Nhập tên người dùng (ví dụ: congtu123)',
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
                  validator: (value) => Validator.validateUsername(value),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (!_isUsernameAvailable)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tên người dùng đã được sử dụng',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error(context),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg3),

                // Email field (readonly)
                CommonTextField(
                  labelText: 'Email',
                  controller: TextEditingController(text: widget.user.email),
                  prefixIcon: Icons.email_outlined,
                  enabled: false,
                ),
                const SizedBox(height: AppSpacing.lg3),

                // Update button
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    return CommonButton(
                      text: 'Cập nhật hồ sơ',
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
