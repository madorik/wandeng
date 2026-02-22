import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/database_helper.dart';

/// 영상 재생 화면
class VideoPlayerScreen extends StatefulWidget {
  final int? recordId;
  final String gym;
  final String difficulty;
  final Color difficultyColor;
  final bool completed;
  final String time;
  final List<String> tags;
  final String date;
  final String? videoPath;

  const VideoPlayerScreen({
    super.key,
    this.recordId,
    required this.gym,
    required this.difficulty,
    required this.difficultyColor,
    required this.completed,
    required this.time,
    required this.tags,
    required this.date,
    this.videoPath,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  double _currentPosition = 0.0;
  double _totalDuration = 1.0;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    if (widget.videoPath == null || widget.videoPath!.isEmpty) return;

    final file = File(widget.videoPath!);
    if (!await file.exists()) return;

    final controller = VideoPlayerController.file(file);
    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) return;

      controller.addListener(_onVideoUpdate);

      setState(() {
        _isInitialized = true;
        _totalDuration = controller.value.duration.inMilliseconds / 1000.0;
      });

      // 자동 재생
      await controller.play();
      setState(() => _isPlaying = true);
      _autoHideControls();
    } catch (e) {
      debugPrint('영상 초기화 실패: $e');
    }
  }

  void _onVideoUpdate() {
    if (!mounted || _controller == null) return;
    final value = _controller!.value;
    setState(() {
      _currentPosition = value.position.inMilliseconds / 1000.0;
      _isPlaying = value.isPlaying;
    });
  }

  void _autoHideControls() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    if (_isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
      _autoHideControls();
    }
  }

  void _onTapVideo() {
    setState(() => _showControls = !_showControls);
    if (_showControls && _isPlaying) {
      _autoHideControls();
    }
  }

  void _onSeek(double value) {
    if (_controller == null) return;
    _controller!.seekTo(Duration(milliseconds: (value * 1000).toInt()));
    setState(() => _currentPosition = value);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 영상 비율 16:9
    final videoHeight = MediaQuery.of(context).size.width * 9 / 16;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 비디오 영역
          Container(
            width: double.infinity,
            height: videoHeight + MediaQuery.of(context).padding.top,
            color: Colors.black,
            child: Stack(
              children: [
                // 비디오 위젯
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  height: videoHeight,
                  child: GestureDetector(
                    onTap: _onTapVideo,
                    child: _isInitialized && _controller != null
                        ? FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: _controller!.value.size.width,
                              height: _controller!.value.size.height,
                              child: VideoPlayer(_controller!),
                            ),
                          )
                        : Container(
                            color: Colors.black,
                            child: widget.videoPath != null
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white54,
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.videocam_off,
                                      size: 48,
                                      color: Colors.white30,
                                    ),
                                  ),
                          ),
                  ),
                ),
                // 재생/일시정지 오버레이
                if (_isInitialized)
                  Positioned(
                    top: MediaQuery.of(context).padding.top,
                    left: 0,
                    right: 0,
                    height: videoHeight,
                    child: GestureDetector(
                      onTap: _onTapVideo,
                      child: AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          color: Colors.black26,
                          child: Center(
                            child: GestureDetector(
                              onTap: _togglePlayPause,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 48,
                                  color: Colors.white,
                                ),
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
                    onPressed: () => _showMoreOptions(),
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
                          value: _currentPosition.clamp(0.0, _totalDuration),
                          max: _totalDuration,
                          onChanged: _onSeek,
                        ),
                      ),
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

  void _showMoreOptions() {
    _controller?.pause();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (widget.recordId != null) ...[
                ListTile(
                  leading: const Icon(Icons.swap_vert, color: AppColors.primary),
                  title: Text(
                    widget.completed ? '도전중으로 변경' : '완등으로 변경',
                    style: AppTextStyles.bodyMedium,
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _toggleCompleted();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: Text('기록 삭제', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDelete();
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.close),
                title: Text('닫기', style: AppTextStyles.bodyMedium),
                onTap: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleCompleted() async {
    if (widget.recordId == null) return;
    final record = await DatabaseHelper.instance.getClimbRecord(widget.recordId!);
    if (record == null) return;
    final updated = record.copyWith(isCompleted: !record.isCompleted);
    await DatabaseHelper.instance.updateClimbRecord(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updated.isCompleted ? '완등으로 변경했습니다!' : '도전중으로 변경했습니다.'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true); // true = 변경됨
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 기록을 삭제하시겠습니까?\n영상 파일도 함께 삭제됩니다.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteRecord();
            },
            child: Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecord() async {
    if (widget.recordId == null) return;

    // 영상 파일 삭제
    if (widget.videoPath != null) {
      final videoFile = File(widget.videoPath!);
      if (await videoFile.exists()) await videoFile.delete();
    }

    // DB에서 삭제
    await DatabaseHelper.instance.deleteClimbRecord(widget.recordId!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기록이 삭제되었습니다.'), duration: Duration(seconds: 2)),
      );
      Navigator.pop(context, true); // true = 변경됨
    }
  }

  String _formatDuration(double seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = (seconds % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
