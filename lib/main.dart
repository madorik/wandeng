import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'screens/home/home_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/crew/crew_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/record/record_screen.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 상태바 스타일 설정 (밝은 테마)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const WandengApp());
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

  // 네비게이션 화면들: 홈 / 지도 / 크루 / 캘린더
  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    CrewScreen(),
    CalendarScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  /// 촬영 버튼 탭 시 촬영 화면으로 이동
  void _onActionTapped() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecordScreen(),
        fullscreenDialog: true,
      ),
    );
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
