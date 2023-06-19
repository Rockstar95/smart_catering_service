import 'package:flutter/material.dart';

import '../../../configs/styles.dart';
import 'common_text.dart';

class CommonSubmitButton extends StatelessWidget {
  final Function onTap;
  final String text;
  final Widget? child;
  final double verticalPadding;
  final double horizontalPadding;
  final double fontSize, elevation;
  final double? height;
  final double borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSelected;

  const CommonSubmitButton({
    super.key,
    required this.onTap,
    this.text = "",
    this.child,
    this.height,
    this.elevation = 2,
    this.verticalPadding = 13,
    this.fontSize = 20,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8,
    this.horizontalPadding = 40,
    this.isSelected = true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: height,
      elevation: elevation,

      //splashColor: Colors.white,
      splashColor: Colors.black26,
      highlightColor: Colors.black26,
      padding: EdgeInsets.zero,
      //
      // padding: EdgeInsets.symmetric(vertical: verticalPadding,horizontal: horizontalPadding),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      onPressed: () {
        onTap();
      },
      child: Ink(
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: backgroundColor ?? Styles.themeBlue,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: prefixIcon!,
                    )
                  : Container(),
              Flexible(
                child: child != null ? child! : CommonText(
                  text: text,
                  color: textColor ?? Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.normal,
                  textAlign: TextAlign.center,
                ),
              ),
              suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: suffixIcon!,
                    )
                  : Container(),
            ],
          )),
    );
  }
}
