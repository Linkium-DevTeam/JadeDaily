import 'package:flutter/material.dart';

/// 竖排文字：逐字向下排布，标点自动靠右上（仿古籍排版）。
/// 超长时可在给定高度内滚动（如展卷）。
class VerticalText extends StatelessWidget {
  const VerticalText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
    this.fontFamily,
    this.letterSpacing = 8,
  });

  final String text;
  final double fontSize;
  final Color color;
  final String? fontFamily;
  final double letterSpacing;

  static const _punctuation = '，。、；：？！';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fontSize * 1.6,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final ch in text.split(''))
              Container(
                margin: EdgeInsets.only(bottom: letterSpacing),
                alignment:
                    _punctuation.contains(ch) ? Alignment.topRight : Alignment.center,
                child: Text(
                  ch,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: color,
                    fontFamily: fontFamily,
                    height: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
