import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 액션 버튼 모달 (+)
/// 영상 업로드, 촬영, AR 루트 파인더 기능
class ActionModal extends StatefulWidget {
  const ActionModal({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Action Modal',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const ActionModal();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<ActionModal> createState() => _ActionModalState();
}

class _ActionModalState extends State<ActionModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _itemAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.15,
            0.6 + index * 0.15,
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: AppColors.background.withOpacity(0.95),
            child: SafeArea(
              child: Stack(
                children: [
                  // 상단 닫기 버튼
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                        size: 28,
                      ),
                    ),
                  ),

                  // 중앙 액션 버튼들
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 제목
                        Text(
                          '무엇을 할까요?',
                          style: AppTextStyles.headline2.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // 액션 버튼들
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAnimatedActionItem(
                              index: 0,
                              icon: Icons.video_library_outlined,
                              label: '영상 업로드',
                              description: '갤러리에서 선택',
                              color: AppColors.info,
                              onTap: () => _handleUpload(context),
                            ),
                            const SizedBox(width: 24),
                            _buildAnimatedActionItem(
                              index: 1,
                              icon: Icons.videocam_outlined,
                              label: '촬영하기',
                              description: '지금 바로 촬영',
                              color: AppColors.secondary,
                              onTap: () => _handleRecord(context),
                            ),
                            const SizedBox(width: 24),
                            _buildAnimatedActionItem(
                              index: 2,
                              icon: Icons.view_in_ar_outlined,
                              label: 'AR 루트',
                              description: '홀드 찾기',
                              color: AppColors.primary,
                              onTap: () => _handleAR(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 하단 힌트
                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Text(
                      '화면을 탭하면 닫힙니다',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedActionItem({
    required int index,
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _itemAnimations[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _itemAnimations[index].value)),
          child: Opacity(
            opacity: _itemAnimations[index].value,
            child: child,
          ),
        );
      },
      child: _buildActionItem(
        icon: icon,
        label: label,
        description: description,
        color: color,
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘 버튼
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: color.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 40,
              color: color,
            ),
          ),
          const SizedBox(height: 16),

          // 라벨
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // 설명
          Text(
            description,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpload(BuildContext context) {
    Navigator.pop(context);
    _showUploadSheet(context);
  }

  void _handleRecord(BuildContext context) {
    Navigator.pop(context);
    _showRecordScreen(context);
  }

  void _handleAR(BuildContext context) {
    Navigator.pop(context);
    _showARScreen(context);
  }

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => const _UploadSheet(),
    );
  }

  void _showRecordScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => const _RecordSheet(),
    );
  }

  void _showARScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => const _ARSheet(),
    );
  }
}

/// 업로드 시트
class _UploadSheet extends StatelessWidget {
  const _UploadSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 헤더
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
              Text('영상 업로드', style: AppTextStyles.headline3),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                child: const Text('다음'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 갤러리 그리드 (더미)
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 20,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      // 썸네일 (더미)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.primaries[index % Colors.primaries.length]
                                  .withOpacity(0.3),
                              AppColors.surfaceLight,
                            ],
                          ),
                        ),
                      ),
                      // 비디오 아이콘
                      const Positioned(
                        bottom: 4,
                        right: 4,
                        child: Icon(
                          Icons.videocam,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      // 선택 시 체크
                      if (index == 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 촬영 시트
class _RecordSheet extends StatefulWidget {
  const _RecordSheet();

  @override
  State<_RecordSheet> createState() => _RecordSheetState();
}

class _RecordSheetState extends State<_RecordSheet> {
  int _timerSeconds = 3;
  bool _aiAnalysis = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // 헤더
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
              Text('촬영하기', style: AppTextStyles.headline3),
            ],
          ),
          const SizedBox(height: 32),

          // 카메라 프리뷰 영역 (더미)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 64,
                      color: AppColors.textTertiary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '카메라 프리뷰',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 타이머 설정
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('타이머', style: AppTextStyles.labelMedium),
              const SizedBox(width: 16),
              ...List.generate(4, (index) {
                final seconds = index == 0 ? 0 : (index + 2);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _timerSeconds = seconds),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _timerSeconds == seconds
                            ? AppColors.primary
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          seconds == 0 ? 'OFF' : '${seconds}s',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _timerSeconds == seconds
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // AI 분석 옵션
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI 분석 요청', style: AppTextStyles.labelMedium),
                      Text(
                        '촬영 후 자동으로 분석합니다',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _aiAnalysis,
                  onChanged: (value) => setState(() => _aiAnalysis = value),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 촬영 버튼
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 4),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// AR 루트 파인더 시트
class _ARSheet extends StatefulWidget {
  const _ARSheet();

  @override
  State<_ARSheet> createState() => _ARSheetState();
}

class _ARSheetState extends State<_ARSheet> {
  double _selectedDifficulty = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // 헤더
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
              Text('AR 루트 파인더', style: AppTextStyles.headline3),
            ],
          ),
          const SizedBox(height: 32),

          // AR 카메라 영역 (더미)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _getDifficultyColor(_selectedDifficulty.round())
                      .withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // 배경
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.view_in_ar,
                          size: 64,
                          color: AppColors.textTertiary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'AR 카메라 프리뷰',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '벽을 향해 카메라를 비춰주세요',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // AR 홀드 데모 (점들)
                  ..._buildDemoHolds(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 난이도 선택기
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('난이도 선택', style: AppTextStyles.labelMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(_selectedDifficulty.round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'V${_selectedDifficulty.round()}',
                      style: AppTextStyles.difficultyBadge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _getDifficultyColor(_selectedDifficulty.round()),
                  inactiveTrackColor: AppColors.surfaceLight,
                  thumbColor: _getDifficultyColor(_selectedDifficulty.round()),
                  overlayColor: _getDifficultyColor(_selectedDifficulty.round())
                      .withOpacity(0.2),
                  trackHeight: 8,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                  ),
                ),
                child: Slider(
                  value: _selectedDifficulty,
                  min: 0,
                  max: 8,
                  divisions: 8,
                  onChanged: (value) {
                    setState(() => _selectedDifficulty = value);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'V0',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    'V8+',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.difficultyGradient.last,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 힌트
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary.withOpacity(0.8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '선택한 난이도의 홀드만 밝게 표시됩니다',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDemoHolds() {
    final random = [
      const Offset(0.2, 0.3),
      const Offset(0.5, 0.4),
      const Offset(0.7, 0.25),
      const Offset(0.3, 0.55),
      const Offset(0.6, 0.6),
      const Offset(0.4, 0.75),
    ];

    return random.map((offset) {
      return Positioned(
        left: offset.dx * 200 + 50,
        top: offset.dy * 300 + 50,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _getDifficultyColor(_selectedDifficulty.round())
                .withOpacity(0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getDifficultyColor(_selectedDifficulty.round())
                    .withOpacity(0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Color _getDifficultyColor(int difficulty) {
    if (difficulty <= 1) return AppColors.difficultyGradient[0];
    if (difficulty <= 3) return AppColors.difficultyGradient[1];
    if (difficulty <= 5) return AppColors.difficultyGradient[2];
    if (difficulty <= 7) return AppColors.difficultyGradient[3];
    return AppColors.difficultyGradient[4];
  }
}
