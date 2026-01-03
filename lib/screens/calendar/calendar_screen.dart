import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../profile/profile_screen.dart';
import '../video/video_player_screen.dart';

/// 캘린더 화면
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(2025, 12);
  DateTime? _selectedDate;
  bool _isCalendarExpanded = true;
  
  // 스와이프 제스처 추적용 변수
  double _dragStartX = 0;
  double _dragStartY = 0;
  bool _isDragging = false;
  bool _isHorizontalSwipe = false; // 수평 스와이프인지 수직 스크롤인지 구분
  
  // 더미 클라이밍 기록
  final Map<String, List<Map<String, dynamic>>> _climbingRecords = {
    '2025-12-05': [
      {'gym': '더클라임 강남점', 'difficulty': 'V2', 'difficultyColor': const Color(0xFFFFEB3B), 'completed': true, 'time': '18:30', 'tags': ['힐', '다이나믹']},
    ],
    '2025-12-08': [
      {'gym': '클라이밍파크 홍대', 'difficulty': 'V3', 'difficultyColor': const Color(0xFF66BB6A), 'completed': true, 'time': '14:00', 'tags': ['크림프', '슬랩']},
      {'gym': '클라이밍파크 홍대', 'difficulty': 'V4', 'difficultyColor': const Color(0xFF42A5F5), 'completed': false, 'time': '15:30', 'tags': ['오버행']},
    ],
    '2025-12-12': [
      {'gym': '더클라임 양재점', 'difficulty': 'V5', 'difficultyColor': const Color(0xFFEF5350), 'completed': true, 'time': '19:00', 'tags': ['루프', '다이나믹', '점프']},
      {'gym': '더클라임 양재점', 'difficulty': 'V6', 'difficultyColor': const Color(0xFF9C27B0), 'completed': false, 'time': '20:15', 'tags': ['오버행', '핀치']},
      {'gym': '더클라임 양재점', 'difficulty': 'V4', 'difficultyColor': const Color(0xFF42A5F5), 'completed': true, 'time': '21:00', 'tags': ['슬랩']},
    ],
    '2025-12-15': [
      {'gym': '클라이밍파크 신촌', 'difficulty': 'V3', 'difficultyColor': const Color(0xFF66BB6A), 'completed': true, 'time': '13:00', 'tags': ['크림프']},
    ],
    '2025-12-20': [
      {'gym': '더클라임 강남점', 'difficulty': 'V3', 'difficultyColor': const Color(0xFF66BB6A), 'completed': true, 'time': '14:30', 'tags': ['슬랩', '밸런스']},
      {'gym': '더클라임 강남점', 'difficulty': 'V4', 'difficultyColor': const Color(0xFF42A5F5), 'completed': false, 'time': '15:20', 'tags': ['오버행', '루프']},
      {'gym': '더클라임 강남점', 'difficulty': 'V5', 'difficultyColor': const Color(0xFFEF5350), 'completed': true, 'time': '16:45', 'tags': ['다이나믹', '점프']},
      {'gym': '더클라임 강남점', 'difficulty': 'V2', 'difficultyColor': const Color(0xFFFFEB3B), 'completed': true, 'time': '17:30', 'tags': ['힐']},
    ],
    '2025-12-22': [
      {'gym': '볼더링짐 서울', 'difficulty': 'V6', 'difficultyColor': const Color(0xFF9C27B0), 'completed': false, 'time': '18:00', 'tags': ['루프', '오버행']},
      {'gym': '볼더링짐 서울', 'difficulty': 'V5', 'difficultyColor': const Color(0xFFEF5350), 'completed': true, 'time': '19:20', 'tags': ['크림프', '다이나믹']},
    ],
    '2025-12-25': [
      {'gym': '클라이밍파크 신촌', 'difficulty': 'V5', 'difficultyColor': const Color(0xFFEF5350), 'completed': true, 'time': '16:00', 'tags': ['오버행', '루프', '점프']},
      {'gym': '클라이밍파크 신촌', 'difficulty': 'V4', 'difficultyColor': const Color(0xFF42A5F5), 'completed': true, 'time': '17:15', 'tags': ['슬랩']},
      {'gym': '클라이밍파크 신촌', 'difficulty': 'V6', 'difficultyColor': const Color(0xFF9C27B0), 'completed': false, 'time': '18:30', 'tags': ['핀치', '다이나믹']},
    ],
    '2025-12-28': [
      {'gym': '더클라임 강남점', 'difficulty': 'V7', 'difficultyColor': const Color(0xFF000000), 'completed': false, 'time': '20:00', 'tags': ['루프', '오버행', '핀치']},
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2025, 12, 25);
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _hasRecords(DateTime date) => _climbingRecords.containsKey(_formatDateKey(date));
  List<Map<String, dynamic>> _getRecords(DateTime date) => _climbingRecords[_formatDateKey(date)] ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('캘린더', style: AppTextStyles.headline3),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceLight,
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/a/default-user=s96-c'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(child: _buildRecordsList()),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday % 7;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: (details) {
        // 캘린더 전체 영역에서 스와이프 감지
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -300) {
            setState(() => _isCalendarExpanded = false);
          } else if (details.primaryVelocity! > 300) {
            setState(() => _isCalendarExpanded = true);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.transparent, // 제스처 감지를 위해 투명 색상 추가
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 캘린더 헤더 (항상 표시)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                onPressed: () {
                  setState(() {
                    if (_selectedDate != null) {
                      _selectedDate = _selectedDate!.subtract(const Duration(days: 1));
                      _focusedMonth = DateTime(_selectedDate!.year, _selectedDate!.month);
                    }
                  });
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isCalendarExpanded = !_isCalendarExpanded),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$year년 $month월', style: AppTextStyles.headline3),
                        if (!_isCalendarExpanded && _selectedDate != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_selectedDate!.day}일',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 300),
                          turns: _isCalendarExpanded ? 0.5 : 0,
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onPressed: () {
                  setState(() {
                    if (_selectedDate != null) {
                      _selectedDate = _selectedDate!.add(const Duration(days: 1));
                      _focusedMonth = DateTime(_selectedDate!.year, _selectedDate!.month);
                    }
                  });
                },
              ),
            ],
          ),
          // 캘린더 그리드 (접었다 펼쳤다 가능)
          AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isCalendarExpanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        // 스와이프 가능 영역 표시
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: day == '일' ? AppColors.error : day == '토' ? AppColors.info : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(6, (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final cellIndex = weekIndex * 7 + dayIndex;
                final dayOffset = cellIndex - startWeekday;
                
                if (dayOffset < 0 || dayOffset >= daysInMonth) {
                  return const Expanded(child: SizedBox(height: 50));
                }
                
                final date = DateTime(year, month, dayOffset + 1);
                final isToday = _isToday(date);
                final isSelected = _selectedDate != null && _isSameDay(date, _selectedDate!);
                final records = _getRecords(date);
                final recordCount = records.length;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : isToday ? AppColors.primarySoft : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '${dayOffset + 1}',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isSelected ? Colors.white : (dayIndex == 0 ? AppColors.error : dayIndex == 6 ? AppColors.info : AppColors.textPrimary),
                                fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (recordCount > 0)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.error.withOpacity(0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Center(
                                  child: Text(
                                    '+$recordCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
                      }),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        // 접힌 상태에서도 스와이프 가능 영역 표시
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_selectedDate == null) return const Center(child: Text('날짜를 선택하세요'));
    
    final records = _getRecords(_selectedDate!);
    final dateStr = '${_selectedDate!.month}월 ${_selectedDate!.day}일';

    // Listener를 사용하여 포인터 이벤트를 직접 처리 (제스처 아레나 우회)
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        _dragStartX = event.localPosition.dx;
        _dragStartY = event.localPosition.dy;
        _isDragging = true;
        _isHorizontalSwipe = false;
      },
      onPointerMove: (event) {
        if (!_isDragging) return;
        
        // 첫 이동에서 수평/수직 방향 결정
        if (!_isHorizontalSwipe) {
          final deltaX = (event.localPosition.dx - _dragStartX).abs();
          final deltaY = (event.localPosition.dy - _dragStartY).abs();
          
          // 수평 이동이 수직 이동보다 크면 수평 스와이프로 판단
          if (deltaX > 10 || deltaY > 10) {
            _isHorizontalSwipe = deltaX > deltaY;
          }
        }
      },
      onPointerUp: (event) {
        if (!_isDragging) return;
        
        final wasHorizontalSwipe = _isHorizontalSwipe;
        _isDragging = false;
        _isHorizontalSwipe = false;
        
        // 수평 스와이프가 아니면 무시 (수직 스크롤)
        if (!wasHorizontalSwipe) return;
        
        final deltaX = event.localPosition.dx - _dragStartX;
        const threshold = 50.0; // 스와이프 인식 최소 거리
        
        if (deltaX > threshold) {
          // 오른쪽 스와이프 -> 이전 날짜
          setState(() {
            _selectedDate = _selectedDate!.subtract(const Duration(days: 1));
            _focusedMonth = DateTime(_selectedDate!.year, _selectedDate!.month);
          });
        } else if (deltaX < -threshold) {
          // 왼쪽 스와이프 -> 다음 날짜
          setState(() {
            _selectedDate = _selectedDate!.add(const Duration(days: 1));
            _focusedMonth = DateTime(_selectedDate!.year, _selectedDate!.month);
          });
        }
      },
      onPointerCancel: (event) {
        _isDragging = false;
        _isHorizontalSwipe = false;
      },
      child: records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_outlined, size: 48, color: AppColors.textTertiary.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text('$dateStr에는 기록이 없어요', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe, size: 20, color: AppColors.textTertiary.withOpacity(0.5)),
                      const SizedBox(width: 8),
                      Text(
                        '좌우로 스와이프하여 날짜 이동',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
        Row(
          children: [
            Text(dateStr, style: AppTextStyles.labelLarge),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
              child: Text('${records.length}개', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryDark)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...records.map((r) => GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  gym: r['gym'],
                  difficulty: r['difficulty'],
                  difficultyColor: r['difficultyColor'],
                  completed: r['completed'],
                  time: r['time'],
                  tags: List<String>.from(r['tags'] ?? []),
                  date: dateStr,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (r['difficultyColor'] as Color).withOpacity(0.3)),
              boxShadow: AppColors.cardShadowLight,
            ),
            child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: r['difficultyColor'], borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text(
                        r['difficulty'],
                        style: AppTextStyles.labelLarge.copyWith(
                          color: r['difficulty'] == 'V0' || r['difficulty'] == 'V1' || r['difficulty'] == 'V2' ? AppColors.textPrimary : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['gym'], style: AppTextStyles.labelLarge),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Text(r['time'], style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: r['completed'] ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(r['completed'] ? Icons.check_circle : Icons.hourglass_bottom, size: 16, color: r['completed'] ? AppColors.success : AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          r['completed'] ? '완등' : '도전중',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: r['completed'] ? AppColors.success : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (r['tags'] != null && (r['tags'] as List).isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (r['tags'] as List<String>).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '#$tag',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
          ),
          )),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime(2025, 12, 25);
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
