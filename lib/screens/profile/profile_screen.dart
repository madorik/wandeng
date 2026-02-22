import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/database_helper.dart';
import '../../models/climb_record.dart';
import '../../models/user_profile.dart';

/// 마이페이지 (프로필) 화면
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // DB 기반 데이터
  UserProfile _profile = const UserProfile();
  List<ClimbRecord> _allRecords = [];
  List<ClimbRecord> _myVideos = [];
  Map<String, int> _gymVisitCounts = {};
  String _maxDifficulty = '-';
  Map<String, double> _difficultyProgress = {};
  List<double> _monthlyCompletions = [];

  final List<Color> _stampColors = [
    AppColors.primary, AppColors.info, AppColors.secondary,
    AppColors.warning, AppColors.success, Colors.purple,
    Colors.teal, Colors.pink, Colors.indigo, Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfileData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final profile = await DatabaseHelper.instance.getUserProfile();
    final records = await DatabaseHelper.instance.getAllClimbRecords();
    final gymCounts = await DatabaseHelper.instance.getGymVisitCounts();

    // 영상이 있는 기록만
    final videos = records.where((r) => r.videoPath != null && r.videoPath!.isNotEmpty).toList();

    // 최고 난이도
    int maxV = -1;
    String maxD = '-';
    for (final r in records) {
      final match = RegExp(r'V(\d+)').firstMatch(r.difficulty);
      if (match != null) {
        final v = int.parse(match.group(1)!);
        if (v > maxV) { maxV = v; maxD = r.difficulty; }
      }
    }

    // 난이도별 완등률
    final Map<String, int> total = {'V0-V1': 0, 'V2-V3': 0, 'V4-V5': 0, 'V6-V7': 0, 'V8+': 0};
    final Map<String, int> completed = {'V0-V1': 0, 'V2-V3': 0, 'V4-V5': 0, 'V6-V7': 0, 'V8+': 0};
    for (final r in records) {
      final match = RegExp(r'V(\d+)').firstMatch(r.difficulty);
      final v = match != null ? int.parse(match.group(1)!) : 0;
      String key;
      if (v <= 1) key = 'V0-V1';
      else if (v <= 3) key = 'V2-V3';
      else if (v <= 5) key = 'V4-V5';
      else if (v <= 7) key = 'V6-V7';
      else key = 'V8+';
      total[key] = (total[key] ?? 0) + 1;
      if (r.isCompleted) completed[key] = (completed[key] ?? 0) + 1;
    }
    final Map<String, double> progress = {};
    for (final key in total.keys) {
      progress[key] = total[key]! > 0 ? completed[key]! / total[key]! : 0;
    }

    // 최근 6개월 월별 완등 수
    final now = DateTime.now();
    final List<double> monthly = [];
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final monthRecords = await DatabaseHelper.instance.getClimbRecordsByMonth(m.year, m.month);
      int count = 0;
      for (final list in monthRecords.values) {
        count += list.where((r) => r.isCompleted).length;
      }
      monthly.add(count.toDouble());
    }

    if (mounted) {
      setState(() {
        _profile = profile;
        _allRecords = records;
        _myVideos = videos;
        _gymVisitCounts = gymCounts;
        _maxDifficulty = maxD;
        _difficultyProgress = progress;
        _monthlyCompletions = monthly;
      });
    }
  }

  void _editNickname() {
    final controller = TextEditingController(text: _profile.nickname);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('닉네임 변경'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          decoration: const InputDecoration(
            hintText: '닉네임을 입력하세요',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final updated = _profile.copyWith(nickname: name);
              await DatabaseHelper.instance.updateUserProfile(updated);
              Navigator.pop(ctx);
              setState(() => _profile = updated);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _editBodySpecs() {
    final heightCtrl = TextEditingController(
      text: _profile.height?.toString() ?? '',
    );
    final wingspanCtrl = TextEditingController(
      text: _profile.wingspan?.toString() ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('신체 스펙 수정'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: heightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '신장 (cm)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: wingspanCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '윙스팬 (cm)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final h = int.tryParse(heightCtrl.text.trim());
              final w = int.tryParse(wingspanCtrl.text.trim());
              final updated = _profile.copyWith(
                height: h ?? _profile.height,
                wingspan: w ?? _profile.wingspan,
              );
              await DatabaseHelper.instance.updateUserProfile(updated);
              Navigator.pop(ctx);
              setState(() => _profile = updated);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  String get _climberTitle {
    final match = RegExp(r'V(\d+)').firstMatch(_maxDifficulty);
    if (match == null) return '입문 클라이머';
    final v = int.parse(match.group(1)!);
    if (v <= 1) return '입문 클라이머';
    if (v <= 3) return '초급 클라이머';
    if (v <= 5) return '중급 클라이머';
    if (v <= 7) return '상급 클라이머';
    return '마스터 클라이머';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 프로필 헤더
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),

            // 통계 카드들
            SliverToBoxAdapter(
              child: _buildStatisticsSection(),
            ),

            // 탭바
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '내 영상'),
                    Tab(text: '저장한 베타'),
                    Tab(text: '성장 기록'),
                  ],
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: AppTextStyles.labelLarge,
                  unselectedLabelStyle: AppTextStyles.labelMedium,
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMyVideosTab(),
            _buildSavedBetasTab(),
            _buildGrowthTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 상단 액션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '마이페이지',
                  style: AppTextStyles.headline2,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share_outlined),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 프로필 정보
            Row(
              children: [
                // 프로필 사진
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _profile.profileImagePath != null
                        ? Image.file(
                            File(_profile.profileImagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.surfaceLight,
                                child: const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.textTertiary,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppColors.surfaceLight,
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.textTertiary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 20),

                // 이름 & 칭호
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _profile.nickname,
                            style: AppTextStyles.headline3,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _editNickname,
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              AppColors.secondary.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _climberTitle,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 신체 스펙
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.divider,
                  width: 1,
                ),
                boxShadow: AppColors.cardShadowLight,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSpecItem('신장', _profile.height != null ? '${_profile.height}cm' : '-'),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.divider,
                  ),
                  _buildSpecItem('윙스팬', _profile.wingspan != null ? '${_profile.wingspan}cm' : '-'),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.divider,
                  ),
                  _buildSpecItem('에이프 인덱스', _profile.apeIndexText),
                  IconButton(
                    onPressed: _editBodySpecs,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Climb Passport
          _buildPassportCard(),
          const SizedBox(height: 16),

          // Level Badge
          _buildLevelBadge(),
          const SizedBox(height: 16),

          // 통계 요약
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.videocam,
                  value: '${_myVideos.length}',
                  label: '업로드',
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  value: '${_allRecords.where((r) => r.isCompleted).length}',
                  label: '완등',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.location_on,
                  value: '${_gymVisitCounts.length}',
                  label: '방문 암장',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceLight,
            AppColors.cardBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: AppColors.cardShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.card_membership,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Climb Passport',
                style: AppTextStyles.labelLarge,
              ),
              const Spacer(),
              Text(
                '${_gymVisitCounts.length}곳 방문',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 암장 스탬프
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ..._gymVisitCounts.entries.map((e) => _buildStamp(e.key, e.value)),
              // 빈 스탬프들
              if (_gymVisitCounts.length < 10)
                ...List.generate(
                  (10 - _gymVisitCounts.length).clamp(0, 4),
                  (_) => _buildEmptyStamp(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStamp(String gymName, int visitCount) {
    final colorIndex = gymName.hashCode.abs() % _stampColors.length;
    final color = _stampColors[colorIndex];
    final shortName = gymName.length >= 2 ? gymName.substring(0, 2) : gymName;
    return Tooltip(
      message: '$gymName (${visitCount}회)',
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            shortName,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStamp() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.divider,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.add,
          color: AppColors.textTertiary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.15),
            AppColors.secondarySoft,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warning,
                  AppColors.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _maxDifficulty,
                style: AppTextStyles.headline2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '최고 완등 난이도',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  _climberTitle,
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '총 ${_allRecords.where((r) => r.isCompleted).length}개 완등!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.emoji_events,
            color: AppColors.warning,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
        boxShadow: AppColors.cardShadowLight,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.numberMedium.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildMyVideosTab() {
    if (_myVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off_outlined,
              size: 64,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '촬영한 영상이 없습니다',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '클라이밍을 촬영해서 기록해보세요!',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.7,
      ),
      itemCount: _myVideos.length,
      itemBuilder: (context, index) {
        return _buildVideoThumbnail(_myVideos[index]);
      },
    );
  }

  Widget _buildVideoThumbnail(ClimbRecord record) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: record.thumbnailPath != null && record.thumbnailPath!.isNotEmpty
              ? Image.file(
                  File(record.thumbnailPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surfaceLight,
                      child: const Icon(
                        Icons.videocam,
                        color: AppColors.textTertiary,
                      ),
                    );
                  },
                )
              : Container(
                  color: AppColors.surfaceLight,
                  child: const Icon(
                    Icons.videocam,
                    color: AppColors.textTertiary,
                  ),
                ),
        ),
        // 난이도 뱃지
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: record.difficultyColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              record.difficulty,
              style: AppTextStyles.difficultyBadge.copyWith(
                fontSize: 10,
              ),
            ),
          ),
        ),
        // 완등 여부
        if (record.isCompleted)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 14,
                color: AppColors.success,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSavedBetasTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '저장한 베타가 없습니다',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 클라이머의 베타를 저장해보세요!',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthTab() {
    final now = DateTime.now();
    final monthLabels = List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i), 1);
      return '${m.month}월';
    });
    final maxY = _monthlyCompletions.isEmpty
        ? 10.0
        : (_monthlyCompletions.reduce((a, b) => a > b ? a : b) * 1.3).clamp(5.0, 100.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 월별 완등 그래프
          Text('월별 완등 수', style: AppTextStyles.labelLarge),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.divider,
                width: 1,
              ),
              boxShadow: AppColors.cardShadowLight,
            ),
            child: _monthlyCompletions.isEmpty
                ? const Center(child: Text('데이터가 없습니다'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= monthLabels.length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  monthLabels[idx],
                                  style: AppTextStyles.caption,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(_monthlyCompletions.length, (i) {
                        return _makeGroupData(i, _monthlyCompletions[i]);
                      }),
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          // 난이도별 완등 현황
          Text('난이도별 완등', style: AppTextStyles.labelLarge),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.divider,
                width: 1,
              ),
              boxShadow: AppColors.cardShadowLight,
            ),
            child: Column(
              children: [
                _buildDifficultyProgress('V0-V1', _difficultyProgress['V0-V1'] ?? 0, AppColors.success),
                _buildDifficultyProgress('V2-V3', _difficultyProgress['V2-V3'] ?? 0, AppColors.info),
                _buildDifficultyProgress('V4-V5', _difficultyProgress['V4-V5'] ?? 0, AppColors.warning),
                _buildDifficultyProgress('V6-V7', _difficultyProgress['V6-V7'] ?? 0, AppColors.secondary),
                _buildDifficultyProgress('V8+', _difficultyProgress['V8+'] ?? 0, Colors.purple),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.6),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 20,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyProgress(
    String label,
    double progress,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: AppTextStyles.labelSmall,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              '${(progress * 100).toInt()}%',
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// 탭바 고정용 Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
