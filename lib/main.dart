import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'data/database_helper.dart';
import 'data/gym_seed_data.dart';
import 'screens/map/map_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/record/record_screen.dart';
import 'widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 로컬 DB 초기화 + 암장 시드 데이터
  await DatabaseHelper.instance.database;
  await DatabaseHelper.instance.seedGymsIfEmpty(seedGyms);

  // 네이버 지도 SDK 초기화
  await NaverMapSdk.instance.initialize(
    clientId: 'YOUR_NAVER_MAP_CLIENT_ID',
    onAuthFailed: (ex) {
      debugPrint('네이버 지도 인증 실패: $ex');
    },
  );

  // 상태바 스타일 설정 (밝은 테마)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: WandengApp()));
}

/// 완등 앱
class WandengApp extends StatelessWidget {
  const WandengApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '완등',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}

/// 메인 화면 (바텀 네비게이션 포함)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  Key _calendarKey = UniqueKey();

  // 네비게이션 화면들: 지도, (촬영 FAB), 캘린더
  List<Widget> get _screens => [
    const MapScreen(),      // index 0: 지도
    CalendarScreen(key: _calendarKey), // index 1: 캘린더
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  /// 촬영 버튼 탭 시 촬영 화면으로 이동
  void _onActionTapped() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecordScreen(),
        fullscreenDialog: true,
      ),
    );

    // 저장 완료 시 캘린더 탭으로 이동 + 데이터 새로고침
    if (result == 'saved') {
      setState(() {
        _currentIndex = 1;
        _calendarKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: WandengBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        onActionTap: _onActionTapped,
      ),
    );
  }
}
