import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 영상 재생 화면
class VideoPlayerScreen extends StatefulWidget {
  final String gym;
  final String difficulty;
  final Color difficultyColor;
  final bool completed;
  final String time;
  final List<String> tags;
  final String date;

  const VideoPlayerScreen({
    super.key,
    required this.gym,
    required this.difficulty,
    required this.difficultyColor,
    required this.completed,
    required this.time,
    required this.tags,
    required this.date,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  final double _totalDuration = 45.0; // 샘플 영상 길이 (초)

  @override
  void initState() {
    super.initState();
    // 자동 재생 시작
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isPlaying = true);
      }
    });
  }

  void _togglePlayPause() {
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    // 영상 비율 16:9
    final videoHeight = MediaQuery.of(context).size.width * 9 / 16;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 비디오 영역 - 상단에 꽉 차게, TOP 바 바로 밑에 위치
          Container(
            width: double.infinity,
            height: videoHeight + MediaQuery.of(context).padding.top,
            color: Colors.black,
            child: Stack(
              children: [
                // 비디오 플레이스홀더 (SafeArea 적용)
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  height: videoHeight,
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      color: Colors.black,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _isPlaying ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.play_arrow : Icons.pause,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // 상단 뒤로가기 버튼
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // 상단 더보기 버튼
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                // 하단 진행 바
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 진행 바
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: AppColors.secondary,
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          thumbColor: AppColors.secondary,
                          overlayColor: AppColors.secondary.withOpacity(0.3),
                        ),
                        child: Slider(
                          value: _currentPosition,
                          max: _totalDuration,
                          onChanged: (value) {
                            setState(() => _currentPosition = value);
                          },
                        ),
                      ),
                      // 시간 표시
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_currentPosition),
                              style: AppTextStyles.caption.copyWith(color: Colors.white70),
                            ),
                            Text(
                              _formatDuration(_totalDuration),
                              style: AppTextStyles.caption.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 영상 정보 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 암장 이름 및 날짜
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.gym,
                          style: AppTextStyles.headline3.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.date} ${widget.time}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 구분선
                  Divider(color: AppColors.border, height: 1),
                  
                  // 난이도 및 완등 상태
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // 난이도 배지
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.difficultyColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.difficulty,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: widget.difficulty == 'V0' || widget.difficulty == 'V1' || widget.difficulty == 'V2' 
                                  ? AppColors.textPrimary 
                                  : Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 완등 상태
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.completed 
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.completed ? AppColors.success : AppColors.warning,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.completed ? Icons.check_circle : Icons.hourglass_bottom,
                                size: 16,
                                color: widget.completed ? AppColors.success : AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.completed ? '완등' : '도전중',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: widget.completed ? AppColors.success : AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 태그
                  if (widget.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '#$tag',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = (seconds % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

