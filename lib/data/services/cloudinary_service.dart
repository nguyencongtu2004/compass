import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:minecraft_compass/config/cloudinary_config.dart';

class CloudinaryService {
  final _dio = Dio();

  /// Hàm upload ảnh lên Cloudinary
  Future<String?> uploadImageToCloudinary(
    File imageFile, {
    String? publicId,
    required String uploadPreset,
  }) async {
    try {
      // URL endpoint upload của Cloudinary (unsigned)
      final uploadUrl =
          'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload';
      final timeStamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
          .toString();

      // Tạo các parameters cho signature (không bao gồm file, api_key, cloud_name)
      final signatureParams = <String, String>{
        'timestamp': timeStamp,
        'upload_preset': uploadPreset,
        'overwrite': 'true',
      };

      // Chỉ thêm public_id vào signature nếu nó không null và không rỗng
      if (publicId != null && publicId.isNotEmpty) {
        signatureParams['public_id'] = publicId;
      }

      // Tạo multipart form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'timestamp': timeStamp,
        'upload_preset': uploadPreset,
        'overwrite': true,
        if (publicId != null) 'public_id': publicId,
        'api_key': CloudinaryConfig.apiKey,
        'signature': computeCloudinarySignature(
          signatureParams,
          CloudinaryConfig.apiSecret,
        ),
      });

      // Gửi request POST
      final response = await _dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      if (response.statusCode == 200) {
        // Kết quả trả về có chứa 'secure_url' (URL để hiển thị) hoặc 'public_id'
        final data = response.data;
        final secureUrl = data['secure_url'];
        debugPrint('Upload thành công! URL: $secureUrl');

        return secureUrl; // Trả về URL của ảnh đã upload
      } else {
        debugPrint('Upload thất bại. Mã lỗi: ${response.statusCode}');
        throw Exception(
          'Upload failed with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Dio Error khi upload: ${e.message}');
      throw Exception('Network error during upload: ${e.message}');
    } catch (e) {
      debugPrint('Lỗi khi upload: $e');
      throw Exception('Upload failed: $e');
    }
  }

  /// Hàm upload avatar cho user với public_id cố định để ghi đè
  Future<String?> uploadUserAvatar(File imageFile, String userId) async {
    final publicId = 'avatars/$userId';
    return await uploadImageToCloudinary(
      imageFile,
      publicId: publicId,
      uploadPreset: CloudinaryConfig.avatarUploadPreset,
    );
  }

  /// Hàm upload ảnh cho user với public_id cố định để ghi đè
  Future<String?> uploadUserImage(File imageFile, String userId) async {
    final publicId = 'images/$userId-${DateTime.now().millisecondsSinceEpoch}';
    return await uploadImageToCloudinary(
      imageFile,
      publicId: publicId,
      uploadPreset: CloudinaryConfig.imageUploadPreset,
    );
  }

  /// Dispose Dio instance khi không cần thiết nữa
  void dispose() {
    _dio.close();
  }

  /// Tính signature cho Cloudinary
  ///
  /// [params] là các tham số cần đưa vào signature
  /// Theo tài liệu Cloudinary: bao gồm tất cả parameters NGOẠI TRỪ: file, cloud_name, resource_type và api_key
  /// [apiSecret] là API Secret của bạn (tuyệt đối không commit lên git).
  ///
  /// Trả về kết quả SHA-1 dưới dạng hex string, để gán vào field "signature" khi upload.
  String computeCloudinarySignature(
    Map<String, String> params,
    String apiSecret,
  ) {
    // 1. Lọc bỏ các tham số có giá trị null hoặc rỗng
    final filtered = params.entries.where((e) => e.value.isNotEmpty).toList();

    // 2. Sắp xếp tham số theo key (lexicographically)
    filtered.sort((a, b) => a.key.compareTo(b.key));

    // 3. Nối chuỗi "key1=value1&key2=value2&...&keyN=valueN"
    final signatureBase = filtered.map((e) => '${e.key}=${e.value}').join('&');

    // 4. Thêm apiSecret vào cuối chuỗi
    final toSign = '$signatureBase$apiSecret';

    // 5. Tính SHA-1
    final bytes = utf8.encode(toSign);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }
}
