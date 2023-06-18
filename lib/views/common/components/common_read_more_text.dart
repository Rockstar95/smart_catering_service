import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class CommonReadMoreTextWidget extends StatelessWidget {
  final String text;
  final int trimLines;
  final String trimCollapsedText;
  final String trimExpandedText;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextStyle? viewMoreTextStyle;
  final TextStyle? viewLessTextStyle;

  const CommonReadMoreTextWidget({
    Key? key,
    required this.text,
    this.trimLines = 6,
    this.trimCollapsedText = 'Read more.',
    this.trimExpandedText = 'Read less.',
    this.textStyle,
    this.textAlign,
    this.viewMoreTextStyle,
    this.viewLessTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return ReadMoreText(
      text,
      trimLines: trimLines,
      style: textStyle ?? themeData.textTheme.titleSmall?.copyWith(
        color: themeData.textTheme.titleSmall!.color?.withOpacity(0.8),
      ),
      textAlign: textAlign,
      colorClickableText: themeData.primaryColor,
      trimMode: TrimMode.Line,
      trimCollapsedText: trimCollapsedText,
      trimExpandedText: trimExpandedText,
      lessStyle: viewLessTextStyle ?? themeData.textTheme.titleSmall?.copyWith(
        color: themeData.primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
      ),
      moreStyle: viewMoreTextStyle ?? themeData.textTheme.titleSmall?.copyWith(
        color: themeData.primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
      ),
    );
  }
}
