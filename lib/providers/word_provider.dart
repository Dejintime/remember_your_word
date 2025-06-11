import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../models/word_list.dart';
import '../services/word_service.dart';
import '../services/storage_service.dart';

class WordProvider extends ChangeNotifier {
  final WordService _wordService;
  
  List<Word> _words = [];
  List<WordList> _wordLists = [];
  List<Word> _reviewWords = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Word> get words => _words;
  List<WordList> get wordLists => _wordLists;
  List<Word> get reviewWords => _reviewWords;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WordProvider._create(this._wordService) {
    _initializeData();
  }

  static Future<WordProvider> create() async {
    final storageService = await StorageService.getInstance();
    final wordService = WordService(storageService);
    return WordProvider._create(wordService);
  }

  // 初始化数据
  Future<void> _initializeData() async {
    await loadWords();
    await loadWordLists();
    await loadReviewWords();
    
    // 如果没有数据，创建示例数据
    if (_words.isEmpty && _wordLists.isEmpty) {
      await _wordService.createSampleData();
      await loadWords();
      await loadWordLists();
      await loadReviewWords();
    }
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 设置错误信息
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // 加载所有单词
  Future<void> loadWords() async {
    try {
      _setLoading(true);
      _setError(null);
      _words = await _wordService.getAllWords();
      notifyListeners();
    } catch (e) {
      _setError('加载单词失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 加载词汇表
  Future<void> loadWordLists() async {
    try {
      _setLoading(true);
      _setError(null);
      _wordLists = await _wordService.getAllWordLists();
      notifyListeners();
    } catch (e) {
      _setError('加载词汇表失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 加载需要复习的单词
  Future<void> loadReviewWords() async {
    try {
      _reviewWords = await _wordService.getWordsForReview();
      notifyListeners();
    } catch (e) {
      _setError('加载复习单词失败: $e');
    }
  }

  // 添加单词
  Future<bool> addWord(Word word) async {
    try {
      _setError(null);
      final success = await _wordService.addWord(word);
      if (success) {
        _words.add(word);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('添加单词失败: $e');
      return false;
    }
  }

  // 更新单词
  Future<bool> updateWord(Word updatedWord) async {
    try {
      _setError(null);
      final success = await _wordService.updateWord(updatedWord);
      if (success) {
        final index = _words.indexWhere((word) => word.id == updatedWord.id);
        if (index != -1) {
          _words[index] = updatedWord;
          notifyListeners();
        }
        // 也更新复习列表中的单词
        final reviewIndex = _reviewWords.indexWhere((word) => word.id == updatedWord.id);
        if (reviewIndex != -1) {
          _reviewWords[reviewIndex] = updatedWord;
        }
        return true;
      }
      return false;
    } catch (e) {
      _setError('更新单词失败: $e');
      return false;
    }
  }

  // 删除单词
  Future<bool> deleteWord(String wordId) async {
    try {
      _setError(null);
      final success = await _wordService.deleteWord(wordId);
      if (success) {
        _words.removeWhere((word) => word.id == wordId);
        _reviewWords.removeWhere((word) => word.id == wordId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('删除单词失败: $e');
      return false;
    }
  }

  // 添加词汇表
  Future<bool> addWordList(WordList wordList) async {
    try {
      _setError(null);
      final success = await _wordService.addWordList(wordList);
      if (success) {
        _wordLists.add(wordList);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('添加词汇表失败: $e');
      return false;
    }
  }

  // 更新词汇表
  Future<bool> updateWordList(WordList updatedWordList) async {
    try {
      _setError(null);
      final success = await _wordService.updateWordList(updatedWordList);
      if (success) {
        final index = _wordLists.indexWhere((wordList) => wordList.id == updatedWordList.id);
        if (index != -1) {
          _wordLists[index] = updatedWordList;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _setError('更新词汇表失败: $e');
      return false;
    }
  }

  // 删除词汇表
  Future<bool> deleteWordList(String wordListId) async {
    try {
      _setError(null);
      final success = await _wordService.deleteWordList(wordListId);
      if (success) {
        _wordLists.removeWhere((wordList) => wordList.id == wordListId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('删除词汇表失败: $e');
      return false;
    }
  }

  // 根据词汇表获取单词
  Future<List<Word>> getWordsByListId(String wordListId) async {
    try {
      return await _wordService.getWordsByListId(wordListId);
    } catch (e) {
      _setError('获取词汇表单词失败: $e');
      return [];
    }
  }

  // 搜索单词
  Future<List<Word>> searchWords(String query) async {
    try {
      return await _wordService.searchWords(query);
    } catch (e) {
      _setError('搜索单词失败: $e');
      return [];
    }
  }

  // 更新单词复习记录
  Future<void> updateWordReview(String wordId, bool isCorrect) async {
    final word = _words.firstWhere((w) => w.id == wordId);
    final updatedWord = word.updateReview(isCorrect: isCorrect);
    await updateWord(updatedWord);
    await loadReviewWords(); // 重新加载复习列表
  }

  // 获取学习统计信息
  Map<String, dynamic> getStudyStatistics() {
    if (_words.isEmpty) {
      return {
        'totalWords': 0,
        'reviewWords': 0,
        'averageFamiliarity': 0.0,
        'masteredWords': 0,
        'learningWords': 0,
      };
    }

    final totalWords = _words.length;
    final reviewWords = _reviewWords.length;
    final averageFamiliarity = _words.map((w) => w.familiarity).reduce((a, b) => a + b) / totalWords;
    final masteredWords = _words.where((w) => w.familiarity >= 0.8).length;
    final learningWords = _words.where((w) => w.familiarity > 0 && w.familiarity < 0.8).length;

    return {
      'totalWords': totalWords,
      'reviewWords': reviewWords,
      'averageFamiliarity': averageFamiliarity,
      'masteredWords': masteredWords,
      'learningWords': learningWords,
    };
  }
}
