// 应用常量
class AppConstants {
  // 存储键
  static const String wordsStorageKey = 'words';
  static const String wordListsStorageKey = 'word_lists';
  static const String settingsStorageKey = 'settings';
  
  // 默认词汇表分类
  static const List<String> defaultCategories = [
    'CET4',
    'CET6', 
    'TOEFL',
    'IELTS',
    'GRE',
    '自定义',
  ];
  
  // 学习模式
  static const List<String> studyModes = [
    '单词卡片',
    '选择题',
    '填空题',
    '听写',
  ];
  
  // 复习间隔（天）
  static const Map<String, int> reviewIntervals = {
    'beginner': 1,
    'intermediate': 3,
    'advanced': 7,
    'mastered': 30,
  };
  
  // 熟悉度等级
  static const Map<String, double> familiarityLevels = {
    'unfamiliar': 0.0,
    'learning': 0.3,
    'familiar': 0.6,
    'well_known': 0.8,
    'mastered': 1.0,
  };
  
  // 主题色彩
  static const Map<String, int> themeColors = {
    'primary': 0xFF6200EE,
    'primaryVariant': 0xFF3700B3,
    'secondary': 0xFF03DAC6,
    'secondaryVariant': 0xFF018786,
    'surface': 0xFFFFFFFF,
    'background': 0xFFF5F5F5,
    'error': 0xFFB00020,
  };
}