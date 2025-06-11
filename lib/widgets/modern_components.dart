import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// 现代化统计卡片
class ModernStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const ModernStatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: const [AppTheme.shadowMd],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: AppTheme.textLight,
                  size: 24,
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textLight,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spaceXs),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 现代化进度指示器
class ModernProgressIndicator extends StatelessWidget {
  final double progress;
  final String label;
  final Color? color;

  const ModernProgressIndicator({
    Key? key,
    required this.progress,
    required this.label,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: const [AppTheme.shadow],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppTheme.primaryColor,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// 现代化操作按钮
class ModernActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback onPressed;
  final bool isLarge;

  const ModernActionButton({
    Key? key,
    required this.text,
    required this.icon,
    this.gradient,
    this.backgroundColor,
    this.textColor,
    required this.onPressed,
    this.isLarge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final finalTextColor = textColor ?? 
        (gradient != null ? AppTheme.textLight : AppTheme.textPrimary);
    
    return Container(
      width: double.infinity,
      height: isLarge ? 56 : 48,
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: const [AppTheme.shadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: finalTextColor,
                  size: isLarge ? 24 : 20,
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Text(
                  text,
                  style: TextStyle(
                    color: finalTextColor,
                    fontSize: isLarge ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 现代化列表项
class ModernListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const ModernListTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: const [AppTheme.shadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spaceSm),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Icon(
                      leadingIcon,
                      color: iconColor ?? AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppTheme.spaceXs),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppTheme.spaceMd),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 现代化选择题卡片
class ModernQuestionCard extends StatelessWidget {
  final String word;
  final String definition;
  final List<String> options;
  final int? selectedIndex;
  final int? correctIndex;
  final bool showResult;
  final Function(int) onOptionSelected;

  const ModernQuestionCard({
    Key? key,
    required this.word,
    required this.definition,
    required this.options,
    this.selectedIndex,
    this.correctIndex,
    this.showResult = false,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceXl),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: const [AppTheme.shadowLg],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 单词显示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Text(
              word,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: AppTheme.spaceXl),
          
          // 题目说明
          Text(
            '请选择正确的翻译：',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: AppTheme.spaceLg),
          
          // 选项列表
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedIndex == index;
            final isCorrect = correctIndex == index;
            final isWrong = showResult && isSelected && !isCorrect;
            
            Color backgroundColor;
            Color textColor;
            Color borderColor;
            
            if (showResult) {
              if (isCorrect) {
                backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
                textColor = const Color(0xFF10B981);
                borderColor = const Color(0xFF10B981);
              } else if (isWrong) {
                backgroundColor = const Color(0xFFEF4444).withOpacity(0.1);
                textColor = const Color(0xFFEF4444);
                borderColor = const Color(0xFFEF4444);
              } else {
                backgroundColor = AppTheme.surface;
                textColor = AppTheme.textSecondary;
                borderColor = AppTheme.surfaceVariant;
              }
            } else if (isSelected) {
              backgroundColor = AppTheme.primaryColor.withOpacity(0.1);
              textColor = AppTheme.primaryColor;
              borderColor = AppTheme.primaryColor;
            } else {
              backgroundColor = AppTheme.surface;
              textColor = AppTheme.textPrimary;
              borderColor = AppTheme.surfaceVariant;
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: showResult ? null : () => onOptionSelected(index),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spaceLg),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected || (showResult && isCorrect) 
                                ? borderColor 
                                : Colors.transparent,
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: isSelected || (showResult && isCorrect)
                              ? Icon(
                                  showResult && isCorrect 
                                      ? Icons.check 
                                      : showResult && isWrong
                                          ? Icons.close
                                          : Icons.circle,
                                  color: AppTheme.textLight,
                                  size: 12,
                                )
                              : null,
                        ),
                        const SizedBox(width: AppTheme.spaceMd),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// 现代化徽章
class ModernBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool isOutlined;

  const ModernBadge({
    Key? key,
    required this.text,
    required this.color,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceSm,
        vertical: AppTheme.spaceXs,
      ),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color.withOpacity(0.1),
        border: isOutlined ? Border.all(color: color) : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
