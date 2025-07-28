import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workplace_guardian/screens/home_screen.dart';
import 'package:workplace_guardian/utils/database_helper.dart';
import 'package:workplace_guardian/utils/permission_manager.dart';
import 'package:workplace_guardian/utils/performance_optimizer.dart';
import 'package:workplace_guardian/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化数据库
  await DatabaseHelper.instance.database;
  
  // 请求必要权限
  await PermissionManager.requestAllPermissions();
  
  // 启动性能优化
  await PerformanceOptimizer.instance.startOptimization();
  await BatteryOptimizer.instance.startBatteryOptimization();
  
  runApp(const WorkplaceGuardianApp());
}

class WorkplaceGuardianApp extends StatelessWidget {
  const WorkplaceGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '职场边界守卫',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      // 多语言支持
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}