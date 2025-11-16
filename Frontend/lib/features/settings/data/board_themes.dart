import 'package:flutter/material.dart';

/// 🎨 Tập hợp các theme bàn cờ
class BoardThemes {
  static const Map<String, (Color light, Color dark)> themes = {
    'theme_classic': (Color(0xFFEEEED2), Color(0xFF769656)),
    'theme_wood': (Color(0xFFEAD2AC), Color(0xFFB58863)),
    'theme_marble': (Color(0xFFE8E6E3), Color(0xFFA9A9A9)),
    'theme_blue': (Color(0xFFDCEEFF), Color(0xFF4A90E2)),
    'theme_bw': (Color(0xFFFFFFFF), Color(0xFF333333)),
  };

  static (Color light, Color dark) getColors(String key) {
    return themes[key] ?? themes['theme_classic']!;
  }
}
