import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:little_daffy/utils/app_colors.dart';
import 'package:little_daffy/utils/responsive.dart';

class RoundedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  const RoundedButton(
      {Key key,
      @required this.onPressed,
      @required this.label,
      this.backgroundColor})
      : assert(label != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Container(
        child: Text(
          this.label,
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'luxia',
              letterSpacing: 1,
              fontSize: responsive.ip(2)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
        decoration: BoxDecoration(
          color: this.backgroundColor ?? AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
            )
          ],
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: this.onPressed,
    );
  }
}
