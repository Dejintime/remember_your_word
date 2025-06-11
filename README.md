# 单词记忆助手 📚

一个基于Flutter开发的智能单词记忆应用，采用间隔重复算法帮助用户高效记忆英语单词。

## ✨ 功能特性

### 📖 单词管理
- **添加单词**: 支持添加英文单词、中文释义、音标、例句和标签
- **单词详情**: 查看单词的完整信息和学习统计
- **删除管理**: 可以删除不需要的单词
- **搜索功能**: 快速搜索已添加的单词

### 🎯 智能学习
- **单词卡片**: 经典的卡片式学习模式
- **间隔重复**: 基于遗忘曲线的智能复习算法
- **熟悉度跟踪**: 自动记录每个单词的熟悉程度
- **学习统计**: 实时显示学习进度和准确率

### 📊 数据可视化
- **学习统计**: 总单词数、待复习数、已掌握数一目了然
- **进度条**: 直观显示平均熟悉度
- **熟悉度标识**: 颜色标签区分单词掌握程度

### 💾 数据持久化
- **本地存储**: 使用SharedPreferences保存数据
- **离线使用**: 无需网络连接即可使用
- **数据安全**: 本地存储保护用户隐私

## 🏗️ 架构设计

### 技术栈
- **框架**: Flutter 3.7+
- **状态管理**: Provider
- **本地存储**: SharedPreferences
- **设计**: Material Design 3

### 项目结构
```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型层
│   ├── word.dart            # 单词数据模型
│   └── word_list.dart       # 词汇表数据模型
├── screens/                  # 页面层
│   ├── home_screen.dart     # 主页面（包含统计和导航）
│   ├── word_list_screen.dart # 单词列表管理页面
│   └── study_screen.dart    # 学习页面
├── widgets/                  # 组件层
│   └── word_card.dart       # 可复用的单词卡片组件
├── providers/               # 状态管理层
│   └── word_provider.dart   # 单词数据状态管理
├── services/                # 业务逻辑层
│   ├── storage_service.dart # 本地存储服务
│   └── word_service.dart    # 单词业务逻辑服务
└── utils/                   # 工具类
    └── constants.dart       # 应用常量定义
```

### 核心算法

**间隔重复算法（简化版）**
```dart
// 根据熟悉度计算复习间隔
int calculateReviewInterval() {
  if (familiarity < 0.3) return 1;  // 不熟悉：1天后复习
  if (familiarity < 0.6) return 3;  // 一般熟悉：3天后复习
  if (familiarity < 0.8) return 7;  // 比较熟悉：1周后复习
  return 30;                         // 很熟悉：1个月后复习
}
```

## 🚀 快速开始

### 环境要求
- Flutter SDK 3.7.0 或更高版本
- Dart SDK 2.19.0 或更高版本

### 安装依赖
```bash
flutter pub get
```

### 运行应用
```bash
# 在Chrome浏览器中运行
flutter run -d chrome

# 在iOS模拟器中运行
flutter run -d ios

# 在Android设备/模拟器中运行
flutter run -d android
```

### 构建应用
```bash
# 构建Web版本
flutter build web

# 构建Android APK
flutter build apk

# 构建iOS应用
flutter build ios
```

## 📱 使用说明

### 首次使用
1. 启动应用后会自动创建示例单词
2. 可以在"词汇表"页面添加新单词
3. 在"学习"页面开始记忆单词

### 添加单词
1. 点击词汇表页面右上角的"+"按钮
2. 填写单词信息（英文和中文为必填项）
3. 可选填写音标、例句和标签
4. 点击"保存"完成添加

### 学习模式
1. 进入学习页面查看当前单词
2. 思考单词含义后点击"查看答案"
3. 根据掌握情况选择"认识"或"不认识"
4. 系统会自动调整该单词的复习计划

## 🔮 功能规划

### 近期计划
- [ ] 词汇表分类管理
- [ ] 多种学习模式（选择题、填空题、听写）
- [ ] 学习提醒功能
- [ ] 单词导入/导出功能

### 长期规划
- [ ] 用户账号系统
- [ ] 云端数据同步
- [ ] 语音播放功能
- [ ] 社区分享功能
- [ ] AI智能推荐

## 🤝 贡献指南

欢迎提交Issue和Pull Request来改进这个项目！

### 开发环境设置
1. Fork本项目
2. 创建功能分支: `git checkout -b feature/新功能`
3. 提交更改: `git commit -am '添加新功能'`
4. 推送分支: `git push origin feature/新功能`
5. 提交Pull Request

## 📄 许可证

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者！

---

⭐ 如果这个项目对你有帮助，请给它一个星标！
