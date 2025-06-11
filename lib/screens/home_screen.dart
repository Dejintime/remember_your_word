import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../services/storage_service.dart';
import '../services/word_service.dart';
import 'word_list_screen.dart';
import 'study_screen.dart';
import '../widgets/word_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const WordListScreen(),
    const StudyScreen(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: '词汇表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '学习',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('单词记忆助手'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<WordProvider>(
        builder: (context, wordProvider, child) {
          if (wordProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wordProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    wordProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      wordProvider.loadWords();
                      wordProvider.loadWordLists();
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          final stats = wordProvider.getStudyStatistics();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 学习统计卡片
                _buildStatsCard(context, stats),
                const SizedBox(height: 24),

                // 今日复习
                _buildSectionTitle(context, '今日复习'),
                const SizedBox(height: 12),
                _buildReviewSection(context, wordProvider),
                const SizedBox(height: 24),

                // 快速操作
                _buildSectionTitle(context, '快速操作'),
                const SizedBox(height: 12),
                _buildQuickActions(context),
                const SizedBox(height: 24),

                // 最近添加的单词
                _buildSectionTitle(context, '最近添加'),
                const SizedBox(height: 12),
                _buildRecentWords(context, wordProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, Map<String, dynamic> stats) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '学习统计',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, '总单词', stats['totalWords'].toString()),
                _buildStatItem(context, '待复习', stats['reviewWords'].toString()),
                _buildStatItem(context, '已掌握', stats['masteredWords'].toString()),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: stats['averageFamiliarity'],
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '平均熟悉度: ${(stats['averageFamiliarity'] * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context, WordProvider wordProvider) {
    if (wordProvider.reviewWords.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              Text(
                '今日无需复习！',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '继续保持学习的好习惯',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(wordProvider.reviewWords.length.toString()),
        ),
        title: const Text('有单词需要复习'),
        subtitle: Text('${wordProvider.reviewWords.length} 个单词等待复习'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudyScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudyScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.school,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    const Text('开始学习'),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WordListScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.add,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    const Text('添加单词'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentWords(BuildContext context, WordProvider wordProvider) {
    final recentWords = wordProvider.words.take(3).toList();
    
    if (recentWords.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '还没有添加单词，点击上方按钮开始添加吧！',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: recentWords.map((word) => WordCard(word: word)).toList(),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('重置示例数据'),
            subtitle: const Text('恢复25个示例单词和4个词汇表'),
            onTap: () => _resetSampleData(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于应用'),
            subtitle: const Text('单词记忆助手 v1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '单词记忆助手',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 单词记忆助手',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('使用帮助'),
            onTap: () {
              _showHelpDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('意见反馈'),
            onTap: () {
              // TODO: 打开反馈页面
            },
          ),
        ],
      ),
    );
  }

  void _resetSampleData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置示例数据'),
        content: const Text('这将清空现有数据并重新创建25个示例单词。确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final wordProvider = Provider.of<WordProvider>(context, listen: false);
        
        // 显示加载状态
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('正在重置数据...'),
              ],
            ),
          ),
        );

        // 清空现有数据并重新创建示例数据
        final storageService = await StorageService.getInstance();
        await storageService.clear();
        
        final wordService = WordService(storageService);
        await wordService.createSampleData();
        
        // 重新加载数据
        await wordProvider.loadWords();
        await wordProvider.loadWordLists();
        await wordProvider.loadReviewWords();

        if (context.mounted) {
          Navigator.of(context).pop(); // 关闭加载对话框
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('示例数据重置成功！已添加25个单词和4个词汇表'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // 关闭加载对话框
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('重置失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用帮助'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📚 添加单词',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('在词汇表页面点击右上角的 + 按钮添加新单词'),
              SizedBox(height: 12),
              Text(
                '🎯 学习模式',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('在学习页面看到英文单词，点击"查看答案"后选择认识或不认识'),
              SizedBox(height: 12),
              Text(
                '📊 复习算法',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('应用会根据你的掌握程度自动安排复习时间：\n• 不熟悉：1天后复习\n• 一般熟悉：3天后复习\n• 比较熟悉：1周后复习\n• 很熟悉：1个月后复习'),
              SizedBox(height: 12),
              Text(
                '🏷️ 标签系统',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('可以为单词添加标签，如"CET4"、"科技"等，方便分类管理'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
