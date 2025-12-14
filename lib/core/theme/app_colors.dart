import 'package:flutter/material.dart';

/// 완등 앱 컬러 팔레트
/// 화이트 & 클린 테마 - 클라이밍 암장의 밝은 나무벽과 초크 가루에서 영감
class AppColors {
  AppColors._();

  // 배경색 (Clean White & Soft Light Grey)
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF4F6F8);
  static const Color surfaceMedium = Color(0xFFEBEEF2);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // 메인 컬러 (Ocean Teal - 맑고 시원한 에너지, 스마트한 AI)
  static const Color primary = Color(0xFF00B8D4);
  static const Color primaryDark = Color(0xFF0097A7);
  static const Color primaryLight = Color(0xFF4DD0E1);
  static const Color primarySoft = Color(0xFFE0F7FA);

  // 포인트 컬러 (Sunset Orange - 완등의 기쁨, 활력)
  static const Color secondary = Color(0xFFFF7043);
  static const Color secondaryDark = Color(0xFFE64A19);
  static const Color secondaryLight = Color(0xFFFF8A65);
  static const Color secondarySoft = Color(0xFFFBE9E7);

  // 텍스트 컬러 (Charcoal Grey - 눈이 편안한 진한 남회색)
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF6B7C8C);
  static const Color textTertiary = Color(0xFF9CAAB8);

  // 상태 컬러
  static const Color success = Color(0xFF26A69A);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // 혼잡도 컬러 (암장 지도용)
  static const Color crowdLow = Color(0xFF26A69A);     // 🟢 쾌적
  static const Color crowdMedium = Color(0xFFFFB74D);  // 🟡 보통
  static const Color crowdHigh = Color(0xFFEF5350);    // 🔴 혼잡

  // 난이도 컬러 (클라이밍 등급 - 클라이밍 홀드 색상에서 영감)
  static const List<Color> difficultyGradient = [
    Color(0xFF66BB6A),  // V0-V1 녹색 (초보)
    Color(0xFF42A5F5),  // V2-V3 파랑
    Color(0xFFFFB74D),  // V4-V5 주황
    Color(0xFFEF5350),  // V6-V7 빨강
    Color(0xFF7E57C2),  // V8+ 보라 (고수)
  ];

  // 오버레이
  static const Color overlayDark = Color(0x66000000);
  static const Color overlayLight = Color(0x33FFFFFF);

  // 구분선 & 테두리
  static const Color divider = Color(0xFFE0E4E8);
  static const Color border = Color(0xFFD0D7DE);

  // 그라디언트
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightGradient = LinearGradient(
    colors: [background, surfaceLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient bottomFadeGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xE6FFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 카드 그림자 (밝은 테마용)
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF2C3E50).withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadowLight => [
    BoxShadow(
      color: const Color(0xFF2C3E50).withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
