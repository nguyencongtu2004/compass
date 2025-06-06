// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'package:flutter/material.dart';

class MinecraftCompass extends StatelessWidget {
  final double width;
  final double height;

  /// Góc của kim, tính bằng radian. 0 rad = chỉ về “phía Bắc” (lên trên).
  final double angle;

  const MinecraftCompass({
    super.key,
    required this.width,
    required this.height,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _CompassPainter(angle: angle)),
    );
  }
}

/// CustomPainter vẽ nền la bàn (14×12 pixel) và kim la bàn theo angle.
class _CompassPainter extends CustomPainter {
  final double angle;

  _CompassPainter({required this.angle});

  // Mảng màu nền 12 hàng × 14 cột, null = trong suốt
  static const List<List<Color?>> _basePixels = [
    // Row 0
    [
      null,
      null,
      null,
      null,
      Color(0xFF373737),
      Color(0xFF373737),
      Color(0xFF373737),
      Color(0xFF373737),
      Color(0xFF373737),
      Color(0xFF373737),
      null,
      null,
      null,
      null,
    ],
    // Row 1
    [
      null,
      null,
      Color(0xFF373737),
      Color(0xFF373737),
      Color(0xFF636363),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF373737),
      Color(0xFF373737),
      null,
      null,
    ],
    // Row 2
    [
      null,
      Color(0xFF373737),
      Color(0xFF636363),
      Color(0xFF636363),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF7F7F7F),
      Color(0xFFC0C0C0),
      Color(0xFF373737),
      null,
    ],
    // Row 3
    [
      Color(0xFF373737),
      Color(0xFF636363),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF7F7F7F),
      Color(0xFF1E1401),
    ],
    // Row 4
    [
      Color(0xFF373737),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF1E1401),
    ],
    // Row 5
    [
      Color(0xFF373737),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF1E1401),
    ],
    // Row 6
    [
      Color(0xFF373737),
      Color(0xFF161616),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF161616),
      Color(0xFF1E1401),
    ],
    // Row 7
    [
      Color(0xFF373737),
      Color(0xFF7F7F7F),
      Color(0xFF161616),
      Color(0xFF161616),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF2F2F2F),
      Color(0xFF161616),
      Color(0xFF161616),
      Color(0xFF636363),
      Color(0xFF1E1401),
    ],
    // Row 8
    [
      Color(0xFF373737),
      Color(0xFF7F7F7F),
      Color(0xFFC0C0C0),
      Color(0xFF7F7F7F),
      Color(0xFF161616),
      Color(0xFF161616),
      Color(0xFF161616),
      Color(0xFF161616),
      Color(0xFF161616),
      Color(0xFF161616),
      Color(0xFF636363),
      Color(0xFF636363),
      Color(0xFF636363),
      Color(0xFF1E1401),
    ],
    // Row 9
    [
      null,
      Color(0xFF1E1401),
      Color(0xFFC0C0C0),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF636363),
      Color(0xFF636363),
      Color(0xFF636363),
      Color(0xFF1E1401),
      null,
    ],
    // Row 10
    [
      null,
      null,
      Color(0xFF1E1401),
      Color(0xFF1E1401),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF7F7F7F),
      Color(0xFF636363),
      Color(0xFF1E1401),
      Color(0xFF1E1401),
      null,
      null,
    ],
    // Row 11
    [
      null,
      null,
      null,
      null,
      Color(0xFF1E1401),
      Color(0xFF1E1401),
      Color(0xFF1E1401),
      Color(0xFF1E1401),
      Color(0xFF1E1401),
      Color(0xFF1E1401),
      null,
      null,
      null,
      null,
    ],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = false;

    // 1. Tính kích thước “pixel vuông” để vẽ (đảm bảo square)
    final pixelSize = min(size.width / 14, size.height / 12);

    // 2. Tính offset để căn giữa lưới 14×12 trong vùng size.width×size.height
    final offsetX = (size.width - pixelSize * 14) / 2;
    final offsetY = (size.height - pixelSize * 12) / 2;

    // 3. Vẽ nền la bàn (các pixel tĩnh)
    for (int row = 0; row < 12; row++) {
      for (int col = 0; col < 14; col++) {
        final color = _basePixels[row][col];
        if (color == null) continue; // pixel trong suốt
        paint.color = color;
        final dx = offsetX + col * pixelSize;
        final dy = offsetY + row * pixelSize;
        canvas.drawRect(Rect.fromLTWH(dx, dy, pixelSize, pixelSize), paint);
      }
    }

    // 4. Vẽ “cây kim” la bàn theo thuật toán đã cho, với tọa độ tính trên lưới 14×12
    const NX = 7.0; // Tọa độ x trung tâm (cột) = 14/2 = 7
    const NY = 5.0; // Tọa độ y trung tâm (hàng) = 12/2 = 6
    const SCALE_X = 0.25; // Tỷ lệ chiều ngang của kim
    const SCALE_Y = SCALE_X * 0.5; // 0.25 * 0.5 = 0.125

    // Tính rx = sin(angle), ry = cos(angle)
    final rx = sin(angle);
    final ry = cos(angle);

    // --- (4.1) Vẽ “ngạnh ngang” nhỏ màu xám (#646464), i ∈ [-4..4]
    for (int i = -4; i <= 4; i++) {
      final double fx = NX + ry * i * SCALE_X;
      final double fy = NY - rx * i * SCALE_Y;
      final int xIdx = fx.round();
      final int yIdx = fy.round();

      // Kiểm tra nằm trong vùng 0..13, 0..11
      if (xIdx >= 0 && xIdx < 14 && yIdx >= 0 && yIdx < 12) {
        paint.color = const Color(0xFF646464);
        final dx = offsetX + xIdx * pixelSize;
        final dy = offsetY + yIdx * pixelSize;
        canvas.drawRect(Rect.fromLTWH(dx, dy, pixelSize, pixelSize), paint);
      }
    }

    // --- (4.2) Vẽ "mũi chính" dài: i ∈ [-8..16]
    for (int i = -8; i <= 16; i++) {
      final double fx = NX + rx * i * SCALE_X;
      final double fy = NY - ry * i * SCALE_Y;
      final int xIdx = fx.round();
      final int yIdx = fy.round();

      if (xIdx >= 0 && xIdx < 14 && yIdx >= 0 && yIdx < 12) {
        if (i >= 0) {
          // Phần mũi đỏ
          paint.color = const Color(0xFFFF1414);
        } else {
          // Phần phía sau màu xám
          paint.color = const Color(0xFF646464);
        }
        final dx = offsetX + xIdx * pixelSize;
        final dy = offsetY + yIdx * pixelSize;
        canvas.drawRect(Rect.fromLTWH(dx, dy, pixelSize, pixelSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) {
    // Chỉ vẽ lại khi angle thay đổi
    return old.angle != angle;
  }
}
