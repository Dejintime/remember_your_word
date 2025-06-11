import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../models/word.dart';
import '../utils/app_theme.dart';
import '../widgets/modern_components.dart';
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

          return CustomScrollView(
            slivers: [
              // 现代化的应用栏
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: AppTheme.background,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    '词汇表',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spaceMd),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.textLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: AppTheme.textLight),
                        onPressed: () => _showAddWordDialog(context),
                      ),
                    ),
                  ),
                ],
              ),
              
              // 统计信息
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceLg),
                  child: _buildStatistics(context, wordProvider),
                ),
              ),
              
              // 词汇表列表
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('词汇表'),
                      const SizedBox(height: AppTheme.spaceMd),
                      _buildWordListTabs(context, wordProvider),
                      const SizedBox(height: AppTheme.spaceXl),
                      _buildSectionTitle('单词列表'),
                      const SizedBox(height: AppTheme.spaceMd),
                    ],
                  ),
                ),
              ),
              
              // 单词列表或空状态
              wordProvider.words.isEmpty
                  ? SliverToBoxAdapter(
                      child: _buildEmptyState(context),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final word = wordProvider.words[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
                              child: GestureDetector(
                                onTap: () => _showWordDetailDialog(context, word),
                                child: WordCard(word: word),
                              ),
                            );
                          },
                          childCount: wordProvider.words.length,
                        ),
                      ),
                    ),
              
              // 底部间距
              const SliverToBoxAdapter(
                child: SizedBox(height: AppTheme.spaceXl),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatistics(BuildContext context, WordProvider wordProvider) {
    return Row(
      children: [
        Expanded(
          child: ModernStatsCard(
            title: '总单词',
            value: wordProvider.words.length.toString(),
            icon: Icons.library_books,
            gradient: AppTheme.primaryGradient,
          ),
        ),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: ModernStatsCard(
            title: '词汇表',
            value: wordProvider.wordLists.length.toString(),
            icon: Icons.folder,
            gradient: AppTheme.successGradient,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildWordListTabs(BuildContext context, WordProvider wordProvider) {
    if (wordProvider.wordLists.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: const [AppTheme.shadow],
        ),
        child: const Text(
          '暂无词汇表',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    return Wrap(
      spacing: AppTheme.spaceSm,
      runSpacing: AppTheme.spaceSm,
      children: wordProvider.wordLists.map((wordList) {
        return ModernBadge(
          text: '${wordList.name} (${wordList.wordIds.length})',
          color: AppTheme.primaryColor,
          isOutlined: true,
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceXl),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: const [AppTheme.shadow],
        ),
        child: Column(
          children: [
            Icon(
              Icons.library_books,
              color: AppTheme.textSecondary,
              size: 64,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            const Text(
              '还没有添加单词',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            const Text(
              '点击右上角的 + 按钮添加你的第一个单词',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            ModernActionButton(
              text: '添加单词',
              icon: Icons.add,
              gradient: AppTheme.primaryGradient,
              onPressed: () => _showAddWordDialog(context),
            ),
          ],
        ),
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

// 现代化的添加单词对话框
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: const [AppTheme.shadowLg],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spaceSm),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppTheme.textLight,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                const Text(
                  '添加新单词',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceXl),
            
            // 表单
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _englishController,
                        label: '英文单词',
                        icon: Icons.translate,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppTheme.spaceLg),
                      _buildTextField(
                        controller: _chineseController,
                        label: '中文意思',
                        icon: Icons.language,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppTheme.spaceLg),
                      _buildTextField(
                        controller: _pronunciationController,
                        label: '音标',
                        icon: Icons.volume_up,
                        hint: '例: /ˈæpəl/',
                      ),
                      const SizedBox(height: AppTheme.spaceLg),
                      _buildTextField(
                        controller: _exampleController,
                        label: '例句',
                        icon: Icons.format_quote,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppTheme.spaceLg),
                      _buildTextField(
                        controller: _tagsController,
                        label: '标签',
                        icon: Icons.tag,
                        hint: '用逗号分隔，例: 食物,水果',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spaceXl),
            
            // 按钮
            Row(
              children: [
                Expanded(
                  child: ModernActionButton(
                    text: '取消',
                    icon: Icons.close,
                    backgroundColor: AppTheme.surfaceVariant,
                    textColor: AppTheme.textSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: ModernActionButton(
                    text: '保存',
                    icon: Icons.check,
                    gradient: AppTheme.primaryGradient,
                    onPressed: _saveWord,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: const [AppTheme.shadowSm],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
          hintStyle: const TextStyle(color: AppTheme.textTertiary),
        ),
        validator: isRequired ? (value) {
          if (value == null || value.trim().isEmpty) {
            return '请输入$label';
          }
          return null;
        } : null,
      ),
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
        reviewCount: 0,
        correctCount: 0,
        familiarity: 0.0,
      );
      
      await wordProvider.addWord(word);
      
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已添加: ${word.english}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            margin: const EdgeInsets.all(AppTheme.spaceMd),
          ),
        );
      }
    }
  }
}

// 现代化的单词详情对话框
class WordDetailDialog extends StatefulWidget {
  final Word word;

  const WordDetailDialog({
    super.key,
    required this.word,
  });

  @override
  State<WordDetailDialog> createState() => _WordDetailDialogState();
}

class _WordDetailDialogState extends State<WordDetailDialog> {
  bool _isEditing = false;
  late TextEditingController _englishController;
  late TextEditingController _chineseController;
  late TextEditingController _pronunciationController;
  late TextEditingController _exampleController;
  late TextEditingController _tagsController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _englishController = TextEditingController(text: widget.word.english);
    _chineseController = TextEditingController(text: widget.word.chinese);
    _pronunciationController = TextEditingController(text: widget.word.pronunciation);
    _exampleController = TextEditingController(text: widget.word.example);
    _tagsController = TextEditingController(text: widget.word.tags.join(', '));
  }

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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: const [AppTheme.shadowLg],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            _buildHeader(),
            const SizedBox(height: AppTheme.spaceXl),
            
            // 内容区域
            Flexible(
              child: _isEditing ? _buildEditForm() : _buildViewContent(),
            ),
            
            const SizedBox(height: AppTheme.spaceXl),
            
            // 操作按钮
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spaceSm),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(
            _isEditing ? Icons.edit : Icons.visibility,
            color: AppTheme.textLight,
            size: 24,
          ),
        ),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: Text(
            _isEditing ? '编辑单词' : '单词详情',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (!_isEditing)
          IconButton(
            onPressed: () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
            tooltip: '编辑',
          ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: AppTheme.textSecondary),
          tooltip: '关闭',
        ),
      ],
    );
  }

  Widget _buildViewContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 英文单词
          _buildInfoCard(
            title: '英文单词',
            content: widget.word.english,
            icon: Icons.translate,
            gradient: AppTheme.primaryGradient,
          ),
          const SizedBox(height: AppTheme.spaceLg),
          
          // 中文意思
          _buildInfoCard(
            title: '中文意思',
            content: widget.word.chinese,
            icon: Icons.language,
            gradient: AppTheme.successGradient,
          ),
          const SizedBox(height: AppTheme.spaceLg),
          
          // 音标
          if (widget.word.pronunciation != null && widget.word.pronunciation!.isNotEmpty) ...[
            _buildInfoCard(
              title: '音标',
              content: widget.word.pronunciation!,
              icon: Icons.volume_up,
              gradient: AppTheme.warningGradient,
            ),
            const SizedBox(height: AppTheme.spaceLg),
          ],
          
          // 例句
          if (widget.word.example != null && widget.word.example!.isNotEmpty) ...[
            _buildInfoCard(
              title: '例句',
              content: widget.word.example!,
              icon: Icons.format_quote,
              gradient: AppTheme.infoGradient,
            ),
            const SizedBox(height: AppTheme.spaceLg),
          ],
          
          // 标签
          if (widget.word.tags.isNotEmpty) ...[
            _buildTagsSection(),
            const SizedBox(height: AppTheme.spaceLg),
          ],
          
          // 学习统计
          _buildStatsSection(),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField(
              controller: _englishController,
              label: '英文单词',
              icon: Icons.translate,
              isRequired: true,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            _buildTextField(
              controller: _chineseController,
              label: '中文意思',
              icon: Icons.language,
              isRequired: true,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            _buildTextField(
              controller: _pronunciationController,
              label: '音标',
              icon: Icons.volume_up,
              hint: '例: /ˈæpəl/',
            ),
            const SizedBox(height: AppTheme.spaceLg),
            _buildTextField(
              controller: _exampleController,
              label: '例句',
              icon: Icons.format_quote,
              maxLines: 2,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            _buildTextField(
              controller: _tagsController,
              label: '标签',
              icon: Icons.tag,
              hint: '用逗号分隔，例: 食物,水果',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: const [AppTheme.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceSm),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(icon, color: AppTheme.textLight, size: 16),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            content,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: const [AppTheme.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceSm),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(Icons.tag, color: AppTheme.textLight, size: 16),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              const Text(
                '标签',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Wrap(
            spacing: AppTheme.spaceSm,
            runSpacing: AppTheme.spaceSm,
            children: widget.word.tags.map((tag) {
              return ModernBadge(
                text: tag,
                color: AppTheme.primaryColor,
                isOutlined: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: const [AppTheme.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceSm),
                decoration: BoxDecoration(
                  gradient: AppTheme.infoGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(Icons.analytics, color: AppTheme.textLight, size: 16),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              const Text(
                '学习统计',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('复习次数', widget.word.reviewCount.toString()),
              ),
              Expanded(
                child: _buildStatItem('熟悉度', '${(widget.word.familiarity * 100).toInt()}%'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '创建时间',
                  _formatDate(widget.word.createdAt),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '最后复习',
                  _formatDate(widget.word.lastReviewedAt),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: const [AppTheme.shadowSm],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
          hintStyle: const TextStyle(color: AppTheme.textTertiary),
        ),
        validator: isRequired ? (value) {
          if (value == null || value.trim().isEmpty) {
            return '请输入$label';
          }
          return null;
        } : null,
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isEditing) {
      return Row(
        children: [
          Expanded(
            child: ModernActionButton(
              text: '取消',
              icon: Icons.close,
              backgroundColor: AppTheme.surfaceVariant,
              textColor: AppTheme.textSecondary,
              onPressed: () => setState(() => _isEditing = false),
            ),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: ModernActionButton(
              text: '保存',
              icon: Icons.check,
              gradient: AppTheme.primaryGradient,
              onPressed: _saveChanges,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: ModernActionButton(
            text: '删除',
            icon: Icons.delete,
            backgroundColor: AppTheme.errorColor,
            textColor: AppTheme.textLight,
            onPressed: _deleteWord,
          ),
        ),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: ModernActionButton(
            text: '开始学习',
            icon: Icons.school,
            gradient: AppTheme.primaryGradient,
            onPressed: _startLearning,
          ),
        ),
      ],
    );
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final wordProvider = Provider.of<WordProvider>(context, listen: false);
      
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
      
      final updatedWord = widget.word.copyWith(
        english: _englishController.text.trim(),
        chinese: _chineseController.text.trim(),
        pronunciation: _pronunciationController.text.trim(),
        example: _exampleController.text.trim(),
        tags: tags,
      );
      
      await wordProvider.updateWord(updatedWord);
      
      if (mounted) {
        setState(() => _isEditing = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已更新: ${updatedWord.english}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.successColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            margin: const EdgeInsets.all(AppTheme.spaceMd),
          ),
        );
      }
    }
  }

  void _deleteWord() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        title: const Text(
          '确认删除',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          '确定要删除单词 "${widget.word.english}" 吗？此操作无法撤销。',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final wordProvider = Provider.of<WordProvider>(context, listen: false);
              await wordProvider.deleteWord(widget.word.id);
              
              if (mounted) {
                Navigator.of(context).pop(); // 关闭确认对话框
                Navigator.of(context).pop(); // 关闭详情对话框
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已删除: ${widget.word.english}'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.errorColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    margin: const EdgeInsets.all(AppTheme.spaceMd),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: AppTheme.textLight,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _startLearning() {
    Navigator.of(context).pop(); // 关闭详情对话框
    // TODO: 导航到学习页面，传入当前单词
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('开始学习: ${widget.word.english}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        margin: const EdgeInsets.all(AppTheme.spaceMd),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    // 如果是未来时间，直接显示具体日期
    if (difference.isNegative) {
      return _formatFullDate(date);
    }
    
    final days = difference.inDays;
    final hours = difference.inHours;
    final minutes = difference.inMinutes;
    
    // 今天内的时间
    if (days == 0) {
      if (hours == 0) {
        if (minutes == 0) {
          return '刚刚';
        } else if (minutes < 5) {
          return '几分钟前';
        } else {
          return '${minutes}分钟前';
        }
      } else {
        return '${hours}小时前';
      }
    }
    // 昨天
    else if (days == 1) {
      return '昨天';
    }
    // 前天
    else if (days == 2) {
      return '前天';
    }
    // 一周内
    else if (days < 7) {
      return '${days}天前';
    }
    // 一个月内 (按周计算)
    else if (days < 30) {
      final weeks = (days / 7).floor();
      return '${weeks}周前';
    }
    // 一年内 (按月计算)
    else if (days < 365) {
      final months = (days / 30).floor();
      return '${months}个月前';
    }
    // 超过一年
    else {
      final years = (days / 365).floor();
      if (years == 1) {
        return '1年前';
      } else {
        return '${years}年前';
      }
    }
  }
  
  /// 格式化完整日期显示
  String _formatFullDate(DateTime date) {
    final now = DateTime.now();
    final isCurrentYear = date.year == now.year;
    
    // 当年的日期不显示年份
    if (isCurrentYear) {
      return '${date.month}月${date.day}日';
    } else {
      return '${date.year}年${date.month}月${date.day}日';
    }
  }
  
  /// 格式化详细时间（包含时分）
  String _formatDetailedDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && 
                   date.month == now.month && 
                   date.day == now.day;
    
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    
    if (isToday) {
      return '今天 $timeStr';
    } else {
      return '${_formatFullDate(date)} $timeStr';
    }
  }
}