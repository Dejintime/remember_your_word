import '../models/word.dart';
import '../models/word_list.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class WordService {
  final StorageService _storageService;

  WordService(this._storageService);

  // 获取所有单词
  Future<List<Word>> getAllWords() async {
    final wordsData = _storageService.getJsonList(AppConstants.wordsStorageKey);
    if (wordsData != null) {
      return wordsData.map((json) => Word.fromJson(json)).toList();
    }
    return [];
  }

  // 保存单词列表
  Future<bool> saveWords(List<Word> words) async {
    final wordsData = words.map((word) => word.toJson()).toList();
    return await _storageService.setJsonList(AppConstants.wordsStorageKey, wordsData);
  }

  // 添加单词
  Future<bool> addWord(Word word) async {
    final words = await getAllWords();
    words.add(word);
    return await saveWords(words);
  }

  // 更新单词
  Future<bool> updateWord(Word updatedWord) async {
    final words = await getAllWords();
    final index = words.indexWhere((word) => word.id == updatedWord.id);
    if (index != -1) {
      words[index] = updatedWord;
      return await saveWords(words);
    }
    return false;
  }

  // 删除单词
  Future<bool> deleteWord(String wordId) async {
    final words = await getAllWords();
    words.removeWhere((word) => word.id == wordId);
    return await saveWords(words);
  }

  // 根据ID获取单词
  Future<Word?> getWordById(String id) async {
    final words = await getAllWords();
    for (Word word in words) {
      if (word.id == id) {
        return word;
      }
    }
    return null;
  }

  // 获取需要复习的单词
  Future<List<Word>> getWordsForReview() async {
    final words = await getAllWords();
    return words.where((word) => word.needsReview).toList();
  }

  // 根据熟悉度筛选单词
  Future<List<Word>> getWordsByFamiliarity(double minFamiliarity, double maxFamiliarity) async {
    final words = await getAllWords();
    return words.where((word) => 
        word.familiarity >= minFamiliarity && word.familiarity <= maxFamiliarity).toList();
  }

  // 搜索单词
  Future<List<Word>> searchWords(String query) async {
    final words = await getAllWords();
    final lowerQuery = query.toLowerCase();
    return words.where((word) =>
        word.english.toLowerCase().contains(lowerQuery) ||
        word.chinese.toLowerCase().contains(lowerQuery) ||
        (word.pronunciation?.toLowerCase().contains(lowerQuery) ?? false) ||
        word.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))).toList();
  }

  // 获取所有词汇表
  Future<List<WordList>> getAllWordLists() async {
    final wordListsData = _storageService.getJsonList(AppConstants.wordListsStorageKey);
    if (wordListsData != null) {
      return wordListsData.map((json) => WordList.fromJson(json)).toList();
    }
    return [];
  }

  // 保存词汇表列表
  Future<bool> saveWordLists(List<WordList> wordLists) async {
    final wordListsData = wordLists.map((wordList) => wordList.toJson()).toList();
    return await _storageService.setJsonList(AppConstants.wordListsStorageKey, wordListsData);
  }

  // 添加词汇表
  Future<bool> addWordList(WordList wordList) async {
    final wordLists = await getAllWordLists();
    wordLists.add(wordList);
    return await saveWordLists(wordLists);
  }

  // 更新词汇表
  Future<bool> updateWordList(WordList updatedWordList) async {
    final wordLists = await getAllWordLists();
    final index = wordLists.indexWhere((wordList) => wordList.id == updatedWordList.id);
    if (index != -1) {
      wordLists[index] = updatedWordList;
      return await saveWordLists(wordLists);
    }
    return false;
  }

  // 删除词汇表
  Future<bool> deleteWordList(String wordListId) async {
    final wordLists = await getAllWordLists();
    wordLists.removeWhere((wordList) => wordList.id == wordListId);
    return await saveWordLists(wordLists);
  }

  // 根据词汇表ID获取单词
  Future<List<Word>> getWordsByListId(String wordListId) async {
    final wordLists = await getAllWordLists();
    final wordList = wordLists.firstWhere((list) => list.id == wordListId);
    
    final allWords = await getAllWords();
    return allWords.where((word) => wordList.wordIds.contains(word.id)).toList();
  }

  // 创建示例数据
  Future<void> createSampleData() async {
    final sampleWords = [
      // 基础词汇
      Word(
        id: '1',
        english: 'apple',
        chinese: '苹果',
        pronunciation: '/ˈæpəl/',
        example: 'I eat an apple every day.',
        tags: ['fruit', 'food', 'CET4'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 2)),
        familiarity: 0.3,
      ),
      Word(
        id: '2',
        english: 'book',
        chinese: '书',
        pronunciation: '/bʊk/',
        example: 'I am reading a book about history.',
        tags: ['education', 'learning', 'CET4'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 1)),
        familiarity: 0.7,
      ),
      Word(
        id: '3',
        english: 'computer',
        chinese: '电脑',
        pronunciation: '/kəmˈpjuːtər/',
        example: 'I use a computer for work.',
        tags: ['technology', 'work', 'CET4'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 3)),
        familiarity: 0.5,
      ),
      Word(
        id: '4',
        english: 'beautiful',
        chinese: '美丽的',
        pronunciation: '/ˈbjuːtɪfl/',
        example: 'The sunset is beautiful tonight.',
        tags: ['adjective', 'appearance', 'CET4'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 1)),
        familiarity: 0.6,
      ),
      Word(
        id: '5',
        english: 'important',
        chinese: '重要的',
        pronunciation: '/ɪmˈpɔːrtnt/',
        example: 'Education is very important for everyone.',
        tags: ['adjective', 'significance', 'CET4'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 4)),
        familiarity: 0.4,
      ),
      Word(
        id: '6',
        english: 'environment',
        chinese: '环境',
        pronunciation: '/ɪnˈvaɪrənmənt/',
        example: 'We should protect our environment.',
        tags: ['nature', 'ecology', 'CET4'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 2)),
        familiarity: 0.3,
      ),
      Word(
        id: '7',
        english: 'opportunity',
        chinese: '机会',
        pronunciation: '/ˌɑːpərˈtuːnəti/',
        example: 'This is a great opportunity to learn.',
        tags: ['chance', 'business', 'CET4'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 5)),
        familiarity: 0.2,
      ),
      Word(
        id: '8',
        english: 'experience',
        chinese: '经验；经历',
        pronunciation: '/ɪkˈspɪriəns/',
        example: 'I gained valuable experience from this job.',
        tags: ['life', 'work', 'CET4'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 1)),
        familiarity: 0.8,
      ),
      Word(
        id: '9',
        english: 'knowledge',
        chinese: '知识',
        pronunciation: '/ˈnɑːlɪdʒ/',
        example: 'Knowledge is power.',
        tags: ['education', 'learning', 'CET4'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 3)),
        familiarity: 0.9,
      ),
      Word(
        id: '10',
        english: 'success',
        chinese: '成功',
        pronunciation: '/səkˈses/',
        example: 'Hard work is the key to success.',
        tags: ['achievement', 'goal', 'CET4'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 2)),
        familiarity: 0.7,
      ),
      
      // CET6 词汇
      Word(
        id: '11',
        english: 'efficient',
        chinese: '高效的',
        pronunciation: '/ɪˈfɪʃnt/',
        example: 'This new system is more efficient.',
        tags: ['productivity', 'work', 'CET6'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 6)),
        familiarity: 0.1,
      ),
      Word(
        id: '12',
        english: 'negotiate',
        chinese: '谈判；协商',
        pronunciation: '/nɪˈɡoʊʃieɪt/',
        example: 'We need to negotiate the contract terms.',
        tags: ['business', 'communication', 'CET6'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 4)),
        familiarity: 0.2,
      ),
      Word(
        id: '13',
        english: 'magnificent',
        chinese: '宏伟的；壮丽的',
        pronunciation: '/mæɡˈnɪfɪsnt/',
        example: 'The view from the mountain top is magnificent.',
        tags: ['description', 'beauty', 'CET6'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 7)),
        familiarity: 0.0,
      ),
      Word(
        id: '14',
        english: 'phenomenon',
        chinese: '现象',
        pronunciation: '/fəˈnɑːmɪnən/',
        example: 'Global warming is a serious phenomenon.',
        tags: ['science', 'observation', 'CET6'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 5)),
        familiarity: 0.3,
      ),
      Word(
        id: '15',
        english: 'elaborate',
        chinese: '详尽的；精心制作的',
        pronunciation: '/ɪˈlæbərət/',
        example: 'She gave an elaborate explanation of the theory.',
        tags: ['detail', 'complex', 'CET6'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 3)),
        familiarity: 0.4,
      ),
      
      // 科技词汇
      Word(
        id: '16',
        english: 'artificial',
        chinese: '人工的；人造的',
        pronunciation: '/ˌɑːrtɪˈfɪʃl/',
        example: 'Artificial intelligence is changing our world.',
        tags: ['technology', 'AI', 'modern'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 1)),
        familiarity: 0.6,
      ),
      Word(
        id: '17',
        english: 'algorithm',
        chinese: '算法',
        pronunciation: '/ˈælɡərɪðəm/',
        example: 'This algorithm can solve complex problems.',
        tags: ['programming', 'computer', 'math'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 8)),
        familiarity: 0.1,
      ),
      Word(
        id: '18',
        english: 'database',
        chinese: '数据库',
        pronunciation: '/ˈdeɪtəbeɪs/',
        example: 'All customer information is stored in the database.',
        tags: ['data', 'storage', 'IT'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 2)),
        familiarity: 0.5,
      ),
      
      // 日常生活词汇
      Word(
        id: '19',
        english: 'restaurant',
        chinese: '餐厅',
        pronunciation: '/ˈrestərɑːnt/',
        example: 'Let\'s go to that new restaurant for dinner.',
        tags: ['food', 'dining', 'daily'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 1)),
        familiarity: 0.8,
      ),
      Word(
        id: '20',
        english: 'exercise',
        chinese: '锻炼；练习',
        pronunciation: '/ˈeksərsaɪz/',
        example: 'Regular exercise is good for your health.',
        tags: ['health', 'fitness', 'daily'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 2)),
        familiarity: 0.7,
      ),
      Word(
        id: '21',
        english: 'medicine',
        chinese: '药物；医学',
        pronunciation: '/ˈmedɪsn/',
        example: 'Take this medicine twice a day.',
        tags: ['health', 'medical', 'care'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 4)),
        familiarity: 0.6,
      ),
      Word(
        id: '22',
        english: 'transportation',
        chinese: '交通运输',
        pronunciation: '/ˌtrænspərˈteɪʃn/',
        example: 'Public transportation is convenient in this city.',
        tags: ['travel', 'city', 'daily'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 3)),
        familiarity: 0.4,
      ),
      Word(
        id: '23',
        english: 'communication',
        chinese: '交流；通讯',
        pronunciation: '/kəˌmjuːnɪˈkeɪʃn/',
        example: 'Good communication skills are essential.',
        tags: ['social', 'skill', 'language'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 1)),
        familiarity: 0.8,
      ),
      Word(
        id: '24',
        english: 'adventure',
        chinese: '冒险；奇遇',
        pronunciation: '/ədˈventʃər/',
        example: 'Traveling alone can be a great adventure.',
        tags: ['travel', 'excitement', 'experience'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 5)),
        familiarity: 0.5,
      ),
      Word(
        id: '25',
        english: 'creative',
        chinese: '有创造力的',
        pronunciation: '/kriˈeɪtɪv/',
        example: 'She has a very creative mind.',
        tags: ['art', 'innovation', 'talent'],
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now().subtract(const Duration(days: 2)),
        familiarity: 0.7,
      ),
    ];

    final sampleWordLists = [
      WordList(
        id: '1',
        name: 'CET4 核心词汇',
        description: '大学英语四级考试核心单词',
        wordIds: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: 'CET4',
      ),
      WordList(
        id: '2',
        name: 'CET6 高级词汇',
        description: '大学英语六级考试重点单词',
        wordIds: ['11', '12', '13', '14', '15'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: 'CET6',
      ),
      WordList(
        id: '3',
        name: '科技与编程',
        description: '科技、编程相关专业词汇',
        wordIds: ['3', '16', '17', '18'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: '专业词汇',
      ),
      WordList(
        id: '4',
        name: '日常生活',
        description: '日常生活中常用的英语单词',
        wordIds: ['1', '19', '20', '21', '22', '23', '24', '25'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: '生活用语',
      ),
    ];

    await saveWords(sampleWords);
    await saveWordLists(sampleWordLists);
  }
}
