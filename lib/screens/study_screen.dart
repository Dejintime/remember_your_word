import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../models/word.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  List<Word> _studyWords = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  int _correctCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudyWords();
    });
  }

  void _loadStudyWords() {
    final wordProvider = Provider.of<WordProvider>(context, listen: false);
    setState(() {
      _studyWords = wordProvider.reviewWords.isNotEmpty 
          ? wordProvider.reviewWords 
          : wordProvider.words;
      _currentIndex = 0;
      _showAnswer = false;
      _correctCount = 0;
      _totalCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_studyWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('学习'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '没有可学习的单词',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '请先添加一些单词',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_currentIndex >= _studyWords.length) {
      return _buildCompletionScreen();
    }

    final currentWord = _studyWords[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('学习 (${_currentIndex + 1}/${_studyWords.length})'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudyWords,
            tooltip: '重新开始',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 进度条
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _studyWords.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // 单词卡片
            Expanded(
              child: Center(
                child: _buildWordCard(currentWord),
              ),
            ),

            // 操作按钮
            _buildActionButtons(currentWord),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCard(Word word) {
    return Card(
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 英文单词
            Text(
              word.english,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (word.pronunciation != null) ...[
              const SizedBox(height: 8),
              Text(
                word.pronunciation!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // 答案区域
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showAnswer ? null : 100,
              child: _showAnswer 
                  ? _buildAnswerSection(word)
                  : _buildQuestionSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionSection() {
    return Column(
      children: [
        Icon(
          Icons.help_outline,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          '点击下方按钮查看答案',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerSection(Word word) {
    return Column(
      children: [
        Text(
          word.chinese,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        if (word.example != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              word.example!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        if (word.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 4,
            children: word.tags.map((tag) => Chip(
              label: Text(tag),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(Word word) {
    if (!_showAnswer) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _showAnswer = true;
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            '查看答案',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _answerWord(word, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, size: 24),
                SizedBox(height: 4),
                Text('不认识'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _answerWord(word, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 24),
                SizedBox(height: 4),
                Text('认识'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    final accuracy = _totalCount > 0 ? _correctCount / _totalCount : 0.0;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习完成'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              '恭喜完成学习！',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '学习统计',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('总题数', _totalCount.toString()),
                        _buildStatItem('正确数', _correctCount.toString()),
                        _buildStatItem('准确率', '${(accuracy * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _loadStudyWords();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '再来一次',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  '返回首页',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

  void _answerWord(Word word, bool isCorrect) async {
    // 更新统计
    setState(() {
      _totalCount++;
      if (isCorrect) {
        _correctCount++;
      }
    });

    // 更新单词的复习记录
    final wordProvider = Provider.of<WordProvider>(context, listen: false);
    await wordProvider.updateWordReview(word.id, isCorrect);

    // 前往下一个单词
    setState(() {
      _currentIndex++;
      _showAnswer = false;
    });
  }
}
