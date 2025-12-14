import 'package:flutter/material.dart';

/// 완등 앱 컬러 팔레트
/// 다크 테마 기반의 네온 컬러 시스템
class AppColors {
  AppColors._();

  // 배경색
  static const Color background = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color cardBackground = Color(0xFF1E1E1E);

  // 포인트 컬러 (네온 라임)
  static const Color primary = Color(0xFFCCFF00);
  static const Color primaryDark = Color(0xFF99CC00);
  static const Color primaryLight = Color(0xFFDDFF55);

  // 보조 컬러 (네온 핑크 - 실패/위험/크럭스 강조)
  static const Color secondary = Color(0xFFFF0055);
  static const Color secondaryDark = Color(0xFFCC0044);
  static const Color secondaryLight = Color(0xFFFF3377);

  // 텍스트 컬러
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textTertiary = Color(0xFF555555);

  // 상태 컬러
  static const Color success = Color(0xFF00FF88);
  static const Color warning = Color(0xFFFFAA00);
  static const Color error = Color(0xFFFF0055);
  static const Color info = Color(0xFF00AAFF);

  // 혼잡도 컬러 (암장 지도용)
  static const Color crowdLow = Color(0xFF00FF88);     // 🟢 쾌적
  static const Color crowdMedium = Color(0xFFFFAA00);  // 🟡 보통
  static const Color crowdHigh = Color(0xFFFF0055);    // 🔴 혼잡

  // 난이도 컬러 (클라이밍 등급)
  static const List<Color> difficultyGradient = [
    Color(0xFF00FF88),  // V0-V1 초록
    Color(0xFF00AAFF),  // V2-V3 파랑
    Color(0xFFFFAA00),  // V4-V5 주황
    Color(0xFFFF0055),  // V6-V7 빨강
    Color(0xFFAA00FF),  // V8+ 보라
  ];

  // 오버레이
  static const Color overlayDark = Color(0x99000000);
  static const Color overlayLight = Color(0x33FFFFFF);

  // 그라디언트
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [background, surfaceDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient bottomFadeGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC121212)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

