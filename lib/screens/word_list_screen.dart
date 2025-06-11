import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../models/word.dart';
import '../widgets/word_card.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('词汇表'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWordDialog(context),
          ),
        ],
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

          if (wordProvider.words.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '还没有添加单词',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击右上角的 + 按钮添加你的第一个单词',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddWordDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('添加单词'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wordProvider.words.length,
            itemBuilder: (context, index) {
              final word = wordProvider.words[index];
              return WordCard(
                word: word,
                onTap: () => _showWordDetailDialog(context, word),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddWordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddWordDialog(),
    );
  }

  void _showWordDetailDialog(BuildContext context, Word word) {
    showDialog(
      context: context,
      builder: (context) => WordDetailDialog(word: word),
    );
  }
}

class AddWordDialog extends StatefulWidget {
  const AddWordDialog({super.key});

  @override
  State<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends State<AddWordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _englishController = TextEditingController();
  final _chineseController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _exampleController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _englishController.dispose();
    _chineseController.dispose();
    _pronunciationController.dispose();
    _exampleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加新单词'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _englishController,
                  decoration: const InputDecoration(
                    labelText: '英文单词 *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入英文单词';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _chineseController,
                  decoration: const InputDecoration(
                    labelText: '中文意思 *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入中文意思';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pronunciationController,
                  decoration: const InputDecoration(
                    labelText: '音标',
                    border: OutlineInputBorder(),
                    hintText: '例: /ˈæpəl/',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _exampleController,
                  decoration: const InputDecoration(
                    labelText: '例句',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: '标签',
                    border: OutlineInputBorder(),
                    hintText: '用逗号分隔，例: 食物,水果',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveWord,
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _saveWord() async {
    if (_formKey.currentState!.validate()) {
      final wordProvider = Provider.of<WordProvider>(context, listen: false);
      
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final word = Word(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        english: _englishController.text.trim(),
        chinese: _chineseController.text.trim(),
        pronunciation: _pronunciationController.text.trim().isEmpty 
            ? null 
            : _pronunciationController.text.trim(),
        example: _exampleController.text.trim().isEmpty 
            ? null 
            : _exampleController.text.trim(),
        tags: tags,
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now(),
      );

      final success = await wordProvider.addWord(word);
      
      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('单词添加成功！')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('添加失败，请重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class WordDetailDialog extends StatelessWidget {
  final Word word;

  const WordDetailDialog({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(word.english),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (word.pronunciation != null) ...[
              Text(
                '音标: ${word.pronunciation}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              '中文: ${word.chinese}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (word.example != null) ...[
              const SizedBox(height: 12),
              Text(
                '例句:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                word.example!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (word.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '标签:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: word.tags.map((tag) => Chip(
                  label: Text(tag),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            ],
            const SizedBox(height: 12),
            _buildStatistics(context, word),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _deleteWord(context, word);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('删除'),
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context, Word word) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '学习统计',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('复习次数: ${word.reviewCount}'),
                Text('正确率: ${(word.accuracy * 100).toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 4),
            Text('熟悉度: ${(word.familiarity * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: word.familiarity,
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteWord(BuildContext context, Word word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除单词 "${word.english}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final wordProvider = Provider.of<WordProvider>(context, listen: false);
              final success = await wordProvider.deleteWord(word.id);
              
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '删除成功' : '删除失败'),
                    backgroundColor: success ? null : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
