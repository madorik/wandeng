import 'package:flutter/material.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 영상 촬영 화면
/// 클라이밍 난이도 색상을 선택하고 촬영할 수 있는 전체 화면
class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // 카메라 관련
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  int _selectedCameraIndex = 0;
  
  // 줌 관련
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;
  
  // 선택된 난이도 인덱스 (0-7: V0-V7+)
  int _selectedDifficulty = 3;
  
  // 촬영 상태
  bool _isRecording = false;
  bool _hasRecorded = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String? _videoPath;
  
  // 암장 관련 상태
  String? _selectedGym;
  bool _isLoadingLocation = true;
  bool _hasLocationError = false;
  
  // 더미 암장 목록 (위치 기반 - 실제 구현 시 GPS 기반으로 가져옴)
  final List<Map<String, dynamic>> _nearbyGyms = [
    {'name': '더클라임 강남점', 'distance': 50, 'address': '강남구 테헤란로 123'},
    {'name': '피커스 서울숲', 'distance': 320, 'address': '성동구 서울숲길 45'},
    {'name': '클라이밍파크 신촌', 'distance': 850, 'address': '서대문구 연세로 67'},
    {'name': '볼더프렌즈 성수', 'distance': 1200, 'address': '성동구 성수이로 89'},
    {'name': '락클라이밍 잠실', 'distance': 2500, 'address': '송파구 올림픽로 234'},
  ];
  
  // 난이도 색상 맵핑
  final List<Map<String, dynamic>> _difficultyOptions = [
    {'label': 'V0', 'color': const Color(0xFFFFFFFF)},  // 흰색
    {'label': 'V1', 'color': const Color(0xFFFFEB3B)},  // 노랑
    {'label': 'V2', 'color': const Color(0xFFFF9800)},  // 주황
    {'label': 'V3', 'color': const Color(0xFF66BB6A)},  // 초록
    {'label': 'V4', 'color': const Color(0xFF42A5F5)},  // 파랑
    {'label': 'V5', 'color': const Color(0xFFEF5350)},  // 빨강
    {'label': 'V6', 'color': const Color(0xFF7E57C2)},  // 보라
    {'label': 'V7+', 'color': const Color(0xFF424242)}, // 검정
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _detectNearbyGym();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordingTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  /// 카메라 초기화
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        throw Exception('사용 가능한 카메라가 없습니다');
      }
      
      await _initCameraController(_cameras![_selectedCameraIndex]);
    } catch (e) {
      debugPrint('카메라 초기화 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('카메라를 사용할 수 없습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 카메라 컨트롤러 초기화
  Future<void> _initCameraController(CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max, // 최고 해상도 사용
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _cameraController = cameraController;

    try {
      await cameraController.initialize();
      
      // 줌 레벨 범위 설정
      _minZoomLevel = await cameraController.getMinZoomLevel();
      _maxZoomLevel = await cameraController.getMaxZoomLevel();
      _currentZoomLevel = _minZoomLevel;
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('카메라 컨트롤러 초기화 오류: $e');
    }
  }
  
  /// 줌 레벨 변경
  Future<void> _setZoomLevel(double zoom) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    // 줌 범위 제한
    final newZoom = zoom.clamp(_minZoomLevel, _maxZoomLevel);
    
    try {
      await _cameraController!.setZoomLevel(newZoom);
      setState(() {
        _currentZoomLevel = newZoom;
      });
    } catch (e) {
      debugPrint('줌 레벨 변경 오류: $e');
    }
  }
  
  /// 핀치 줌 시작
  void _onScaleStart(ScaleStartDetails details) {
    _baseZoomLevel = _currentZoomLevel;
  }
  
  /// 핀치 줌 업데이트
  void _onScaleUpdate(ScaleUpdateDetails details) {
    // 핀치 스케일에 따라 줌 레벨 조정
    final newZoom = _baseZoomLevel * details.scale;
    _setZoomLevel(newZoom);
  }

  /// 카메라 전환 (전면/후면)
  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    
    setState(() {
      _isCameraInitialized = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
      // 카메라 전환 시 줌 레벨 초기화
      _currentZoomLevel = 1.0;
    });
    
    await _cameraController?.dispose();
    await _initCameraController(_cameras![_selectedCameraIndex]);
  }

  /// 위치 기반으로 근처 암장 자동 감지
  Future<void> _detectNearbyGym() async {
    setState(() {
      _isLoadingLocation = true;
      _hasLocationError = false;
    });
    
    // 실제 구현 시 GPS 위치 가져오기
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 더미: 50m 이내 암장이 있으면 자동 선택
    final nearestGym = _nearbyGyms.first;
    if (nearestGym['distance'] < 100) {
      setState(() {
        _selectedGym = nearestGym['name'];
        _isLoadingLocation = false;
      });
    } else {
      setState(() {
        _selectedGym = null;
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    try {
      await _cameraController!.startVideoRecording();
      
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });
      
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingSeconds++;
        });
      });
    } catch (e) {
      debugPrint('녹화 시작 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('녹화를 시작할 수 없습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_cameraController!.value.isRecordingVideo) {
      return;
    }
    
    try {
      _recordingTimer?.cancel();
      final XFile videoFile = await _cameraController!.stopVideoRecording();
      
      setState(() {
        _isRecording = false;
        _hasRecorded = true;
        _videoPath = videoFile.path;
      });
      
      // 촬영 완료 후 정보 입력 화면으로 이동
      _showVideoInfoScreen();
    } catch (e) {
      debugPrint('녹화 중지 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('녹화를 중지할 수 없습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showVideoInfoScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoInfoScreen(
          difficulty: _difficultyOptions[_selectedDifficulty]['label'],
          difficultyColor: _difficultyOptions[_selectedDifficulty]['color'],
          recordingDuration: _recordingSeconds,
          initialGym: _selectedGym,
          videoPath: _videoPath,
        ),
      ),
    ).then((result) {
      // 저장 또는 삭제 후 처리 - 카메라 화면으로 돌아감 (난이도, 암장 유지)
      setState(() {
        _hasRecorded = false;
        _recordingSeconds = 0;
        _videoPath = null;
      });
      
      if (result == 'saved') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('영상이 저장되었습니다'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else if (result == 'deleted') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('영상이 삭제되었습니다'),
              ],
            ),
            backgroundColor: AppColors.textSecondary,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = _difficultyOptions[_selectedDifficulty]['color'] as Color;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 카메라 프리뷰 (핀치 줌 지원)
          if (_isCameraInitialized && _cameraController != null)
            GestureDetector(
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              child: OrientationBuilder(
                builder: (context, orientation) {
                  final previewSize = _cameraController!.value.previewSize!;
                  final isLandscape = orientation == Orientation.landscape;
                  
                  // 화면 방향에 따라 카메라 비율 계산
                  // previewSize는 항상 landscape 기준 (width > height)
                  final double cameraAspectRatio;
                  if (isLandscape) {
                    // 가로 모드: 카메라 비율 그대로 사용
                    cameraAspectRatio = previewSize.width / previewSize.height;
                  } else {
                    // 세로 모드: 비율 뒤집기
                    cameraAspectRatio = previewSize.height / previewSize.width;
                  }
                  
                  return Center(
                    child: AspectRatio(
                      aspectRatio: cameraAspectRatio,
                      child: CameraPreview(_cameraController!),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[900]!,
                    Colors.grey[800]!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),

          // 선택된 난이도 색상 테두리
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedColor.withOpacity(0.8),
                    width: 4,
                  ),
                ),
              ),
            ),
          ),

          // 상단 UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 닫기 버튼
                  _buildCircleButton(
                    icon: Icons.close,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  
                  const Spacer(),
                  
                  // 촬영 시간 표시
                  if (_isRecording)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDuration(_recordingSeconds),
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // 플래시 버튼 (비활성화)
                  _buildCircleButton(
                    icon: Icons.flash_off,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // 좌측 정보 패널 (난이도 + 암장)
          Positioned(
            left: 16,
            bottom: 200,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 난이도 선택
                  _buildDifficultyDropdown(selectedColor),
                  const SizedBox(height: 12),
                  // 암장 선택
                  _buildGymSelector(),
                ],
              ),
            ),
          ),
          
          // 줌 슬라이더 (우측)
          if (_isCameraInitialized && _maxZoomLevel > _minZoomLevel)
            Positioned(
              right: 20,
              bottom: 200,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 줌 레벨 표시
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_currentZoomLevel.toStringAsFixed(1)}x',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 줌 슬라이더 (세로)
                    Container(
                      height: 150,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            activeTrackColor: selectedColor,
                            inactiveTrackColor: Colors.white.withOpacity(0.3),
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16,
                            ),
                            overlayColor: selectedColor.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: _currentZoomLevel,
                            min: _minZoomLevel,
                            max: _maxZoomLevel,
                            onChanged: _setZoomLevel,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 줌 버튼들
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 줌 아웃
                        GestureDetector(
                          onTap: () => _setZoomLevel(_currentZoomLevel - 0.5),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // 줌 인
                        GestureDetector(
                          onTap: () => _setZoomLevel(_currentZoomLevel + 0.5),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 하단 컨트롤
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 왼쪽 공간
                    const SizedBox(width: 48),

                    // 촬영 버튼 (중앙)
                    GestureDetector(
                      onTap: _isRecording ? _stopRecording : _startRecording,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _isRecording 
                                ? AppColors.error 
                                : selectedColor,
                            shape: _isRecording 
                                ? BoxShape.rectangle 
                                : BoxShape.circle,
                            borderRadius: _isRecording 
                                ? BorderRadius.circular(8) 
                                : null,
                          ),
                          child: _isRecording
                              ? const Icon(
                                  Icons.stop,
                                  color: Colors.white,
                                  size: 32,
                                )
                              : null,
                        ),
                      ),
                    ),

                    // 카메라 전환 버튼 (오른쪽)
                    _buildCircleButton(
                      icon: Icons.cameraswitch_outlined,
                      size: 48,
                      onTap: _switchCamera,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 40,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.55,
        ),
      ),
    );
  }

  /// 난이도 선택 드롭다운
  Widget _buildDifficultyDropdown(Color selectedColor) {
    return GestureDetector(
      onTap: () => _showDifficultyBottomSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedColor.withOpacity(0.8),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 난이도 색상 인디케이터
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selectedColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _difficultyOptions[_selectedDifficulty]['label'],
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// 암장 선택 위젯
  Widget _buildGymSelector() {
    return GestureDetector(
      onTap: () => _showGymBottomSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isLoadingLocation 
                  ? Icons.location_searching
                  : Icons.location_on,
              color: _selectedGym != null ? AppColors.success : Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            if (_isLoadingLocation)
              Text(
                '위치 확인중...',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              )
            else if (_selectedGym != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  _selectedGym!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              Text(
                '암장 선택',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// 암장 선택 바텀시트
  void _showGymBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 20),
              
              // 헤더
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '근처 암장',
                    style: AppTextStyles.headline3,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '현재 위치 기준으로 가까운 암장이에요',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),
              
              // 암장 목록
              ...List.generate(_nearbyGyms.length, (index) {
                final gym = _nearbyGyms[index];
                final isSelected = _selectedGym == gym['name'];
                final distance = gym['distance'] as int;
                String distanceText;
                if (distance < 1000) {
                  distanceText = '${distance}m';
                } else {
                  distanceText = '${(distance / 1000).toStringAsFixed(1)}km';
                }
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGym = gym['name'];
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primarySoft 
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primary 
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 거리 표시
                        Container(
                          width: 56,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: distance < 100 
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.surfaceMedium,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            distanceText,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: distance < 100 
                                  ? AppColors.success 
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // 암장 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gym['name'],
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: isSelected 
                                      ? AppColors.primaryDark 
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                gym['address'],
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 체크 표시
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 12),
              
              // 직접 입력 버튼
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _showCustomGymInput();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '직접 입력하기',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// 암장 직접 입력 다이얼로그
  void _showCustomGymInput() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '암장 이름 입력',
          style: AppTextStyles.headline3,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '암장 이름을 입력하세요',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _selectedGym = controller.text.trim();
                });
              }
              Navigator.pop(context);
            },
            child: Text(
              '확인',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 난이도 선택 바텀시트
  void _showDifficultyBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 20),
              Text(
                '난이도 선택',
                style: AppTextStyles.headline3,
              ),
              const SizedBox(height: 16),
              // 난이도 그리드
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _difficultyOptions.length,
                itemBuilder: (context, index) {
                  final option = _difficultyOptions[index];
                  final isSelected = _selectedDifficulty == index;
                  final color = option['color'] as Color;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDifficulty = index;
                      });
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.textPrimary : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              option['label'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: index == 0 || index == 1
                                    ? AppColors.textPrimary
                                    : Colors.white,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check,
                                size: 16,
                                color: index == 0 || index == 1
                                    ? AppColors.textPrimary
                                    : Colors.white,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

/// 영상 정보 입력 화면
/// 촬영 완료 후 암장, 난이도, 태그 입력
class VideoInfoScreen extends StatefulWidget {
  final String difficulty;
  final Color difficultyColor;
  final int recordingDuration;
  final String? initialGym;
  final String? videoPath;

  const VideoInfoScreen({
    super.key,
    required this.difficulty,
    required this.difficultyColor,
    required this.recordingDuration,
    this.initialGym,
    this.videoPath,
  });

  @override
  State<VideoInfoScreen> createState() => _VideoInfoScreenState();
}

class _VideoInfoScreenState extends State<VideoInfoScreen> {
  final _gymController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  String? _selectedGym;
  bool _isCompleted = true; // 완등 여부
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  // 더미 암장 목록
  final List<String> _gymList = [
    '더클라임 강남점',
    '더클라임 홍대점',
    '피커스 서울숲',
    '클라이밍파크 신촌',
    '볼더프렌즈 성수',
    '락클라이밍 잠실',
  ];

  @override
  void initState() {
    super.initState();
    // 촬영 화면에서 선택한 암장 정보 적용
    _selectedGym = widget.initialGym;
    // 비디오 플레이어 초기화
    if (widget.videoPath != null) {
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.file(File(widget.videoPath!));
      await _videoController!.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
      // 자동 재생
      _videoController!.play();
      _videoController!.setLooping(true);
    } catch (e) {
      debugPrint('비디오 플레이어 초기화 오류: $e');
    }
  }

  @override
  void dispose() {
    _gymController.dispose();
    _tagController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 5) {
      setState(() {
        _tags.add(tag);
      });
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}분 ${secs}초';
  }

  Future<void> _saveVideo() async {
    // 저장 로직
    try {
      if (widget.videoPath != null) {
        final sourceFile = File(widget.videoPath!);
        
        // 앱의 영구 저장소로 복사
        final Directory appDirectory = await getApplicationDocumentsDirectory();
        final String savedDirectory = '${appDirectory.path}/SavedVideos';
        await Directory(savedDirectory).create(recursive: true);
        
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String fileName = 'climbing_${_selectedGym ?? "unknown"}_${widget.difficulty}_$timestamp.mp4';
        final String destinationPath = '$savedDirectory/$fileName';
        
        await sourceFile.copy(destinationPath);
        
        debugPrint('영상 저장 완료: $destinationPath');
        
        // TODO: 실제 구현 시 데이터베이스에 메타데이터 저장
        // - 암장: _selectedGym
        // - 난이도: widget.difficulty
        // - 완등 여부: _isCompleted
        // - 태그: _tags
        // - 촬영 시간: widget.recordingDuration
        // - 파일 경로: destinationPath
        
        if (mounted) {
          Navigator.of(context).pop('saved');
        }
      }
    } catch (e) {
      debugPrint('영상 저장 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('영상 저장 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _deleteVideo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '영상 삭제',
          style: AppTextStyles.headline3,
        ),
        content: Text(
          '촬영한 영상을 삭제하시겠습니까?\n삭제된 영상은 복구할 수 없습니다.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // 실제 영상 파일 삭제 로직
              if (widget.videoPath != null) {
                try {
                  final file = File(widget.videoPath!);
                  if (file.existsSync()) {
                    file.deleteSync();
                  }
                } catch (e) {
                  debugPrint('영상 파일 삭제 오류: $e');
                }
              }
              Navigator.of(context).pop();
              Navigator.of(context).pop('deleted');
            },
            child: Text(
              '삭제',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 영상 비율 16:9
    final videoHeight = MediaQuery.of(context).size.width * 9 / 16;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 영상 영역 - 상단에 꽉 차게, TOP 바 바로 밑에 위치
          Container(
            width: double.infinity,
            height: videoHeight + MediaQuery.of(context).padding.top,
            color: Colors.black,
            child: Stack(
              children: [
                // 비디오 플레이어 (SafeArea 적용)
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  height: videoHeight,
                  child: _isVideoInitialized && _videoController != null
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_videoController!.value.isPlaying) {
                                _videoController!.pause();
                              } else {
                                _videoController!.play();
                              }
                            });
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 영상 (화면에 꽉 차게)
                              FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _videoController!.value.size.width,
                                  height: _videoController!.value.size.height,
                                  child: VideoPlayer(_videoController!),
                                ),
                              ),
                              // 재생/일시정지 아이콘
                              Center(
                                child: AnimatedOpacity(
                                  opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _videoController!.value.isPlaying 
                                          ? Icons.play_arrow 
                                          : Icons.pause,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: AppColors.primary),
                              const SizedBox(height: 8),
                              Text(
                                '영상 불러오는 중...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                // 상단 뒤로가기 버튼
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                // 난이도 뱃지
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.difficultyColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.difficulty,
                      style: AppTextStyles.difficultyBadge.copyWith(
                        color: widget.difficulty == 'V0' || widget.difficulty == 'V1'
                            ? AppColors.textPrimary
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                // 촬영 시간
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDuration(widget.recordingDuration),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 영상 정보 영역
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

            // 암장 선택
            Text(
              '암장',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedGym,
                decoration: const InputDecoration(
                  hintText: '암장을 선택하세요',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                dropdownColor: AppColors.background,
                items: _gymList.map((gym) {
                  return DropdownMenuItem(
                    value: gym,
                    child: Text(gym, style: AppTextStyles.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGym = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // 완등 여부
            Text(
              '완등 여부',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isCompleted = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _isCompleted 
                            ? AppColors.success.withOpacity(0.1) 
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isCompleted 
                              ? AppColors.success 
                              : AppColors.border,
                          width: _isCompleted ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: _isCompleted 
                                ? AppColors.success 
                                : AppColors.textTertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '완등',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: _isCompleted 
                                  ? AppColors.success 
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isCompleted = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !_isCompleted 
                            ? AppColors.warning.withOpacity(0.1) 
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_isCompleted 
                              ? AppColors.warning 
                              : AppColors.border,
                          width: !_isCompleted ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.hourglass_bottom,
                            color: !_isCompleted 
                                ? AppColors.warning 
                                : AppColors.textTertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '도전중',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: !_isCompleted 
                                  ? AppColors.warning 
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 태그 입력
            Text(
              '태그',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: '태그 입력 후 Enter (최대 5개)',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    onPressed: () => _addTag(_tagController.text.trim()),
                  ),
                ),
                onSubmitted: (value) => _addTag(value.trim()),
              ),
            ),
            const SizedBox(height: 12),
            
            // 태그 목록
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#$tag',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeTag(tag),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.primaryDark.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            
            // 추천 태그
            const SizedBox(height: 12),
            Text(
              '추천 태그',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['다이나믹', '슬랩', '발컨', '힐훅', '토훅', '맨틀링'].map((tag) {
                return GestureDetector(
                  onTap: () => _addTag(tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMedium,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '#$tag',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      // 하단 버튼
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // 삭제 버튼
              Expanded(
                child: GestureDetector(
                  onTap: _deleteVideo,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '삭제',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 저장 버튼
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _saveVideo,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.save_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '저장하기',
                          style: AppTextStyles.button,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
