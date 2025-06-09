import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/location_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/common_appbar.dart';
import '../core/widgets/common_button.dart';
import '../core/widgets/common_scaffold.dart';
import '../core/widgets/common_textfield.dart';
import 'bloc/newsfeed_bloc.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _captionController = TextEditingController();
  File? _imageFile;
  bool _isGettingLocation = false;
  LocationModel? _location;
  bool _isCreating = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _location = LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          updatedAt: DateTime.now(),
          locationName:
              'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
        );
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _createPost() async {
    if (_imageFile == null) return;

    setState(() {
      _isCreating = true;
    });

    try {
      context.read<NewsfeedBloc>().add(
        CreatePost(
          imageFile: _imageFile!,
          caption: _captionController.text.trim().isEmpty
              ? null
              : _captionController.text.trim(),
          location: _location,
        ),
      );

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      setState(() {
        _isCreating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng bài: ${e.toString()}'),
            backgroundColor: AppColors.error(context),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppbar(
        title: 'Tạo bài đăng mới',
        leftWidget: IconButton(
          onPressed: _isCreating ? null : () => context.pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: BlocListener<NewsfeedBloc, NewsfeedState>(
        listener: (context, state) {
          if (state is PostCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Đăng bài thành công!'),
                backgroundColor: AppColors.success(context),
              ),
            );
          } else if (state is NewsfeedError) {
            setState(() {
              _isCreating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error(context),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image selection
              if (_imageFile == null) ...[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant(context),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: AppColors.outline(context),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: InkWell(
                      onTap: _isCreating ? null : _pickImage,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 64,
                            color: AppColors.primary(context),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Chụp ảnh để đăng bài',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.primary(context),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Nhấn để mở camera',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Image preview
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        child: Image.file(
                          _imageFile!,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (!_isCreating)
                        Positioned(
                          top: AppSpacing.sm,
                          right: AppSpacing.sm,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _imageFile = null;
                                  _location = null;
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg), // Caption input
                CommonTextField(
                  labelText: 'Caption',
                  controller: _captionController,
                  hintText: 'Viết caption cho bài đăng...',
                  enabled: !_isCreating,
                ),

                const SizedBox(height: AppSpacing.md),

                // Location info
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant(context),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.primary(context),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _isGettingLocation
                            ? const Text('Đang lấy vị trí...')
                            : Text(
                                _location != null
                                    ? 'Vị trí đã được ghi lại'
                                    : 'Không thể lấy vị trí',
                                style: AppTextStyles.bodySmall,
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Create button
                CommonButton(
                  text: 'Đăng bài',
                  onPressed: _isCreating ? null : _createPost,
                  isLoading: _isCreating,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
