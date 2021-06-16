import 'package:flutter/material.dart';
import 'package:little_daffy/utils/app_colors.dart';
import 'package:little_daffy/utils/responsive.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);  
    return Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: responsive.ip(14.78),
              color: Colors.white,
            ),
          AspectRatio(
          aspectRatio: 18/18,
          child: LayoutBuilder(
            builder: (_,contraints){
              return Container(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: contraints.maxHeight * 0.33,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: responsive.ip(0.2),
                          width: contraints.maxWidth,
                          color: AppColors.gray,
                        ),
                        SizedBox(
                          height: responsive.ip(2),
                        ),
                        Text(
                          "BIENVENIDO A LITTLE DAFFY",
                          style:TextStyle(
                            color: Color(0xff818286),
                            fontSize: responsive.ip(2.5),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: contraints.maxHeight * 0.52,
                    right: responsive.ip(16.8),
                    child: Image.asset(
                      'assets/pages/login/logo.png',
                      width: contraints.maxWidth * 0.28,
                    ),
                  ),
                  Positioned(
                    top: contraints.maxHeight * 0.12,
                    right: responsive.ip(18.2),
                    child: Image.asset(
                      'assets/pages/login/as.png',
                      width: contraints.maxWidth * 0.20,
                    ),
                  ),
                ],
              ),
            );
          },
          ),
      ), 
      ],
    );
  }
}
