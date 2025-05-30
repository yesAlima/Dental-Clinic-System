import 'package:flutter/material.dart';
import '../../../const/app_colors.dart';
import '../../../functions/auth/googlesignin.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Googlelog extends StatelessWidget {
  const Googlelog({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 50.0,
        width: 50.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: AppColors.mainBlueColor,
        ),
        child: IconButton(
          onPressed: () => signInWithGoogle(context),
          icon: SvgPicture.asset(
            'assets/svgs/g_logo.svg',
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
