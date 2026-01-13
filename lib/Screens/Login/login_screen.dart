import "package:flutter/material.dart";
import "package:flutter_application/Screens/Login/components/login_form.dart";
import "package:flutter_application/Screens/Login/components/login_screen_top_image.dart";
import "package:flutter_application/components/background.dart";
import "package:flutter_application/responsive.dart";

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Responsive(
          mobile: MobileLoginScreen(),
          desktop: Row(
            children: [
              Expanded(child: LoginScreenTopImage()),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [SizedBox(width: 450, child: LoginForm())],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        LoginScreenTopImage(),
        Row(
          children: [
            Spacer(),
            Expanded(flex: 8, child: LoginForm()),
            Spacer(),
          ],
        ),
      ],
    );
  }
}
