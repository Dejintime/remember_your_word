import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/word_provider.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化存储服务
  await StorageService.getInstance();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WordProvider>(
      future: WordProvider.create(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('初始化失败: ${snapshot.error}'),
              ),
            ),
          );
        }

        return ChangeNotifierProvider.value(
          value: snapshot.data!,
          child: MaterialApp(
            title: '单词记忆助手',
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
