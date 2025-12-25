import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../profile/profile_screen.dart';

/// 캘린더 화면
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;
  
  // 더미 클라이밍 기록
  final Map<String, List<Map<String, dynamic>>> _climbingRecords = {
    '2024-12-20': [
      {'gym': '더클라임 강남점', 'difficulty': 'V3', 'difficultyColor': const Color(0xFF66BB6A), 'completed': true, 'time': '14:30'},
      {'gym': '더클라임 강남점', 'difficulty': 'V4', 'difficultyColor': const Color(0xFF42A5F5), 'completed': false, 'time': '15:20'},
    ],
    '2024-12-25': [
      {'gym': '클라이밍파크 신촌', 'difficulty': 'V5', 'difficultyColor': const Color(0xFFEF5350), 'completed': true, 'time': '16:00'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
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

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _focusedMonth = DateTime(year, month - 1)),
              ),
              Text('$year년 $month월', style: AppTextStyles.headline3),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _focusedMonth = DateTime(year, month + 1)),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                final hasRecords = _hasRecords(date);
                
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${dayOffset + 1}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isSelected ? Colors.white : (dayIndex == 0 ? AppColors.error : dayIndex == 6 ? AppColors.info : AppColors.textPrimary),
                              fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: hasRecords ? (isSelected ? Colors.white : AppColors.secondary) : Colors.transparent,
                              shape: BoxShape.circle,
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
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_selectedDate == null) return const Center(child: Text('날짜를 선택하세요'));
    
    final records = _getRecords(_selectedDate!);
    final dateStr = '${_selectedDate!.month}월 ${_selectedDate!.day}일';

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_outlined, size: 48, color: AppColors.textTertiary.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text('$dateStr에는 기록이 없어요', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      );
    }

    return ListView(
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
        ...records.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (r['difficultyColor'] as Color).withOpacity(0.3)),
            boxShadow: AppColors.cardShadowLight,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: r['difficultyColor'], borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text(
                    r['difficulty'],
                    style: AppTextStyles.labelLarge.copyWith(
                      color: r['difficulty'] == 'V0' || r['difficulty'] == 'V1' ? AppColors.textPrimary : Colors.white,
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
        )),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
