import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class DebugDataPage extends StatelessWidget {
  const DebugDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据调试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder(
        future: _getStorageData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('错误: ${snapshot.error}'),
            );
          }

          final data = snapshot.data as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('存储位置', [
                  'macOS: ~/Library/Preferences/com.example.remember_your_word.plist',
                  'Web: 浏览器 LocalStorage',
                  'Android: /data/data/包名/shared_prefs/',
                ]),
                const SizedBox(height: 20),
                _buildSection('存储键', [
                  'words: ${AppConstants.wordsStorageKey}',
                  'word_lists: ${AppConstants.wordListsStorageKey}',
                  'settings: ${AppConstants.settingsStorageKey}',
                ]),
                const SizedBox(height: 20),
                _buildSection('当前数据', [
                  '单词数量: ${data['wordCount']}',
                  '词汇表数量: ${data['wordListCount']}',
                ]),
                const SizedBox(height: 20),
                _buildJsonSection('单词数据 JSON', data['wordsJson']),
                const SizedBox(height: 20),
                _buildJsonSection('词汇表数据 JSON', data['wordListsJson']),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _clearAllData(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('清空所有数据'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(item),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonSection(String title, String json) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                json.isEmpty ? '暂无数据' : json,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getStorageData() async {
    final storageService = await StorageService.getInstance();
    
    final wordsData = storageService.getJsonList(AppConstants.wordsStorageKey) ?? [];
    final wordListsData = storageService.getJsonList(AppConstants.wordListsStorageKey) ?? [];
    
    return {
      'wordCount': wordsData.length,
      'wordListCount': wordListsData.length,
      'wordsJson': wordsData.isEmpty ? '' : wordsData.toString(),
      'wordListsJson': wordListsData.isEmpty ? '' : wordListsData.toString(),
    };
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有数据吗？此操作不可恢复！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storageService = await StorageService.getInstance();
      await storageService.clear();
      
      if (!context.mounted) return;
      
      // 重新加载数据
      final wordProvider = Provider.of<WordProvider>(context, listen: false);
      await wordProvider.loadWords();
      await wordProvider.loadWordLists();
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('所有数据已清空')),
      );
      Navigator.of(context).pop();
    }
  }
}
