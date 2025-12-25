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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 비디오 영역 (샘플)
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Stack(
                children: [
                  // 비디오 플레이스홀더
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isPlaying ? Icons.play_circle_outline : Icons.pause_circle_outline,
                          size: 80,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '영상 재생 중',
                          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  // 재생/일시정지 제스처
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 상단 정보 오버레이
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 뒤로가기 버튼
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          // 더보기 버튼
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 암장 이름
                      Text(
                        widget.gym,
                        style: AppTextStyles.headline3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 날짜 및 시간
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.date} ${widget.time}',
                            style: AppTextStyles.caption.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // 하단 정보 오버레이
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 난이도 및 완등 상태
                      Row(
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
                      const SizedBox(height: 12),
                      // 태그
                      if (widget.tags.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )).toList(),
                        ),
                      const SizedBox(height: 16),
                      // 진행 바
                      Row(
                        children: [
                          Text(
                            _formatDuration(_currentPosition),
                            style: AppTextStyles.caption.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 2,
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
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDuration(_totalDuration),
                            style: AppTextStyles.caption.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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

