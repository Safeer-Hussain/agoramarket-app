import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  generateAppIcon();
  generateThumbnails();
  generateBadges();
  generateAvatars();
  print('Asset generation complete.');
}

void generateAppIcon() {
  final image = img.Image(width: 512, height: 512);
  // Obsidian background with subtle radial vignette
  for (int y = 0; y < 512; y++) {
    for (int x = 0; x < 512; x++) {
      final dx = (x - 256) / 256.0;
      final dy = (y - 256) / 256.0;
      final dist = math.sqrt(dx * dx + dy * dy);
      final r = (15 + (1.0 - dist).clamp(0.0, 1.0) * 12).toInt();
      final g = (20 + (1.0 - dist).clamp(0.0, 1.0) * 15).toInt();
      final b = (32 + (1.0 - dist).clamp(0.0, 1.0) * 25).toInt();
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  // Draw sleek geometric play-prism and location pin emblem
  // Pin head outer circle
  img.drawCircle(
    image,
    x: 256,
    y: 220,
    radius: 140,
    color: img.ColorRgba8(0, 229, 186, 255),
  ); // Electric teal
  img.drawCircle(
    image,
    x: 256,
    y: 220,
    radius: 120,
    color: img.ColorRgba8(13, 17, 23, 255),
  ); // Obsidian inner

  // Coral-amber play prism (triangle)
  final p1x = 225, p1y = 165;
  final p2x = 320, p2y = 220;
  final p3x = 225, p3y = 275;

  // Fill triangle
  for (int y = 160; y <= 280; y++) {
    for (int x = 220; x <= 330; x++) {
      if (pointInTriangle(x, y, p1x, p1y, p2x, p2y, p3x, p3y)) {
        // Gradient from Coral #FF6B4A to Amber #FFA800
        final t = (x - 220) / 110.0;
        final r = 255;
        final g = (107 + t * 61).clamp(0, 255).toInt();
        final b = (74 * (1.0 - t)).clamp(0, 255).toInt();
        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  }

  // Location pin stem pointing down
  for (int y = 300; y <= 410; y++) {
    final width = ((410 - y) / 110.0 * 80).toInt();
    for (int x = 256 - width; x <= 256 + width; x++) {
      if (x >= 0 && x < 512 && y >= 0 && y < 512) {
        final t = (y - 300) / 110.0;
        final r = (0 * (1 - t) + 255 * t).toInt();
        final g = (229 * (1 - t) + 107 * t).toInt();
        final b = (186 * (1 - t) + 74 * t).toInt();
        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  }

  File('assets/icons/app_icon.png').writeAsBytesSync(img.encodePng(image));
}

bool pointInTriangle(
  int px,
  int py,
  int x1,
  int y1,
  int x2,
  int y2,
  int x3,
  int y3,
) {
  final d1 = (px - x2) * (y1 - y2) - (x1 - x2) * (py - y2);
  final d2 = (px - x3) * (y2 - y3) - (x2 - x3) * (py - y3);
  final d3 = (px - x1) * (y3 - y1) - (x3 - x1) * (py - y1);
  final hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
  final hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
  return !(hasNeg && hasPos);
}

void generateThumbnails() {
  final thumbs = [
    {
      'file': 'thumb_mobile_arch.png',
      'c1': [16, 24, 40],
      'c2': [0, 180, 160],
      'accent': [255, 107, 74],
      'type': 'mobile',
    },
    {
      'file': 'thumb_ui_ux.png',
      'c1': [30, 20, 50],
      'c2': [130, 80, 230],
      'accent': [0, 229, 186],
      'type': 'design',
    },
    {
      'file': 'thumb_cloud_devops.png',
      'c1': [10, 30, 45],
      'c2': [30, 120, 200],
      'accent': [255, 180, 40],
      'type': 'cloud',
    },
    {
      'file': 'thumb_ai_automation.png',
      'c1': [18, 18, 30],
      'c2': [220, 60, 100],
      'accent': [0, 235, 200],
      'type': 'ai',
    },
  ];

  for (final t in thumbs) {
    final image = img.Image(width: 720, height: 1280);
    final c1 = t['c1'] as List<int>;
    final c2 = t['c2'] as List<int>;
    final accent = t['accent'] as List<int>;

    for (int y = 0; y < 1280; y++) {
      final ratio = y / 1280.0;
      for (int x = 0; x < 720; x++) {
        final xRatio = x / 720.0;
        final r = (c1[0] * (1 - ratio) + c2[0] * ratio * (0.6 + 0.4 * xRatio))
            .toInt()
            .clamp(0, 255);
        final g = (c1[1] * (1 - ratio) + c2[1] * ratio * (0.6 + 0.4 * xRatio))
            .toInt()
            .clamp(0, 255);
        final b = (c1[2] * (1 - ratio) + c2[2] * ratio * (0.6 + 0.4 * xRatio))
            .toInt()
            .clamp(0, 255);
        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    // Draw tech geometric grids / cards
    for (int y = 200; y < 1000; y += 40) {
      for (int x = 60; x < 660; x += 40) {
        if ((x + y) % 80 == 0) {
          img.drawCircle(
            image,
            x: x,
            y: y,
            radius: 2,
            color: img.ColorRgba8(255, 255, 255, 30),
          );
        }
      }
    }

    // Center futuristic card overlay
    for (int cy = 400; cy < 880; cy++) {
      for (int cx = 100; cx < 620; cx++) {
        final border = (cx <= 104 || cx >= 616 || cy <= 404 || cy >= 876);
        if (border) {
          image.setPixelRgba(cx, cy, accent[0], accent[1], accent[2], 200);
        } else {
          final cur = image.getPixel(cx, cy);
          image.setPixelRgba(
            cx,
            cy,
            (cur.r * 0.7).toInt(),
            (cur.g * 0.7).toInt(),
            (cur.b * 0.7).toInt(),
            255,
          );
        }
      }
    }

    // Center tech symbol (prism/nodes)
    img.drawCircle(
      image,
      x: 360,
      y: 640,
      radius: 80,
      color: img.ColorRgba8(accent[0], accent[1], accent[2], 230),
    );
    img.drawCircle(
      image,
      x: 360,
      y: 640,
      radius: 60,
      color: img.ColorRgba8(13, 17, 23, 240),
    );

    // Inner play icon
    final p1x = 345, p1y = 610;
    final p2x = 390, p2y = 640;
    final p3x = 345, p3y = 670;
    for (int y = 600; y <= 680; y++) {
      for (int x = 340; x <= 400; x++) {
        if (pointInTriangle(x, y, p1x, p1y, p2x, p2y, p3x, p3y)) {
          image.setPixelRgba(x, y, accent[0], accent[1], accent[2], 255);
        }
      }
    }

    File('assets/images/${t['file']}').writeAsBytesSync(img.encodePng(image));
  }
}

void generateBadges() {
  final badges = [
    {
      'name': 'badge_job.png',
      'color': [0, 229, 186],
      'sub': [13, 40, 50],
    },
    {
      'name': 'badge_freelancer.png',
      'color': [255, 107, 74],
      'sub': [50, 20, 15],
    },
    {
      'name': 'badge_agency.png',
      'color': [78, 140, 255],
      'sub': [15, 25, 60],
    },
  ];

  for (final b in badges) {
    final image = img.Image(width: 256, height: 256);
    final col = b['color'] as List<int>;
    final sub = b['sub'] as List<int>;

    for (int y = 0; y < 256; y++) {
      for (int x = 0; x < 256; x++) {
        final dx = (x - 128) / 128.0;
        final dy = (y - 128) / 128.0;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist <= 0.95) {
          if (dist > 0.85) {
            image.setPixelRgba(x, y, col[0], col[1], col[2], 255);
          } else {
            image.setPixelRgba(x, y, sub[0], sub[1], sub[2], 255);
          }
        }
      }
    }

    // Center icon geometry
    img.drawCircle(
      image,
      x: 128,
      y: 128,
      radius: 36,
      color: img.ColorRgba8(col[0], col[1], col[2], 255),
    );
    img.drawCircle(
      image,
      x: 128,
      y: 128,
      radius: 24,
      color: img.ColorRgba8(sub[0], sub[1], sub[2], 255),
    );

    File('assets/images/${b['name']}').writeAsBytesSync(img.encodePng(image));
  }
}

void generateAvatars() {
  final avatars = [
    {
      'name': 'avatar_safeer.png',
      'color': [0, 229, 186],
      'initial': 'S',
    },
    {
      'name': 'avatar_ayesha.png',
      'color': [255, 107, 74],
      'initial': 'A',
    },
    {
      'name': 'avatar_bilal.png',
      'color': [120, 100, 240],
      'initial': 'B',
    },
    {
      'name': 'avatar_zoya.png',
      'color': [255, 180, 50],
      'initial': 'Z',
    },
  ];

  for (final a in avatars) {
    final image = img.Image(width: 256, height: 256);
    final col = a['color'] as List<int>;

    for (int y = 0; y < 256; y++) {
      for (int x = 0; x < 256; x++) {
        final dx = (x - 128) / 128.0;
        final dy = (y - 128) / 128.0;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist <= 0.96) {
          if (dist > 0.88) {
            image.setPixelRgba(x, y, col[0], col[1], col[2], 255);
          } else {
            final t = (y / 256.0);
            final r = (20 + t * 30).toInt();
            final g = (25 + t * 35).toInt();
            final b = (40 + t * 45).toInt();
            image.setPixelRgba(x, y, r, g, b, 255);
          }
        }
      }
    }

    // Stylized head and shoulders vector silhouette
    img.drawCircle(
      image,
      x: 128,
      y: 100,
      radius: 42,
      color: img.ColorRgba8(col[0], col[1], col[2], 220),
    );
    // Shoulders
    for (int y = 150; y < 225; y++) {
      final w = ((y - 150) / 75.0 * 80).toInt();
      for (int x = 128 - w; x <= 128 + w; x++) {
        final dx = (x - 128) / 128.0;
        final dy = (y - 128) / 128.0;
        if (math.sqrt(dx * dx + dy * dy) <= 0.85) {
          image.setPixelRgba(x, y, col[0], col[1], col[2], 220);
        }
      }
    }

    // Verified checkmark badge in bottom-right
    img.drawCircle(
      image,
      x: 195,
      y: 195,
      radius: 24,
      color: img.ColorRgba8(0, 229, 186, 255),
    );
    img.drawCircle(
      image,
      x: 195,
      y: 195,
      radius: 18,
      color: img.ColorRgba8(13, 17, 23, 255),
    );

    File('assets/images/${a['name']}').writeAsBytesSync(img.encodePng(image));
  }
}
