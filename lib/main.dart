import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'screens/home/home_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/coach/coach_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/action/action_modal.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surfaceDark,
      systemNavigationBarIconBrightness: Brightness.light,
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
      theme: AppTheme.darkTheme,
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

  // 네비게이션 화면들 (액션 버튼은 별도 처리)
  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    CoachScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _onActionTapped() {
    ActionModal.show(context);
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
