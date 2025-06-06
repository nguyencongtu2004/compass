import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:minecraft_compass/config/cloudinary_config.dart';

class CloudinaryService {
  final _dio = Dio();
  String cloudName = CloudinaryConfig.cloudName;
  String uploadPreset = CloudinaryConfig.uploadPreset;

  /// Hàm upload ảnh lên Cloudinary
  Future<String?> uploadImageToCloudinary(File imageFile) async {
    try {
      // URL endpoint upload của Cloudinary (unsigned)
      final uploadUrl =
          'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

      // Tạo multipart form data: 'file' và 'upload_preset'
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'upload_preset': uploadPreset,
      });

      // Gửi request POST
      final response = await _dio.post(
        uploadUrl,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        // Kết quả trả về có chứa 'secure_url' (URL để hiển thị) hoặc 'public_id'
        final data = response.data;
        final secureUrl = data['secure_url'];
        debugPrint('Upload thành công! URL: $secureUrl');

        return secureUrl; // Trả về URL của ảnh đã upload
      } else {
        debugPrint('Upload thất bại. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi khi upload: $e');
    } finally {
      _dio.close();
    }
    return null; // Trả về null nếu có lỗi
  }

}
