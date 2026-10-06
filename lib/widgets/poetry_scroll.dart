import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/daily_content.dart';
import '../theme/jade_theme.dart';
import 'porcelain_panel.dart';
import 'vertical_text.dart';

/// 右侧诗词玉简：竖排正文 + 落款 + 朱砂「雅趣」章。
class PoetryScroll extends StatelessWidget {
  const PoetryScroll({super.key, required this.quote});

  final DailyQuote quote;

  @override
  Widget build(BuildContext context) {
    final palette = jadePalette(context);
    final serif = GoogleFonts.notoSerifSc().fontFamily;
    return PorcelainPanel(
      vertical: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 560),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 80),
                  VerticalText(
                    text: quote.source,
                    fontSize: 16,
                    color: palette.inkFaint,
                    fontFamily: serif,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: JadeColors.seal.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '雅趣',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 36),
          Flexible(
            child: VerticalText(
              text: quote.text,
              fontSize: 34,
              color: palette.textPoem,
              fontFamily: serif,
              letterSpacing: 10,
            ),
          ),
        ],
      ),
    );
  }
}
