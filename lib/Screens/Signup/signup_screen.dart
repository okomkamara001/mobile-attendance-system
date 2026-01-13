import "package:flutter/material.dart";
import "package:flutter_application/Screens/Signup/components/sign_up_top_image.dart";
import "package:flutter_application/Screens/Signup/components/signup_form.dart";
import "package:flutter_application/components/background.dart";
import "package:flutter_application/constants.dart";
import "package:flutter_application/responsive.dart";

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
        child: Responsive(
          mobile: MobileSignupScreen(),
          desktop: Row(
            children: [
              Expanded(child: SignUpScreenTopImage()),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 450, child: SignUpForm()),
                    SizedBox(height: defaultPadding / 2),
                    // SocalSignUp()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileSignupScreen extends StatelessWidget {
  const MobileSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SignUpScreenTopImage(),
        Row(
          children: [
            Spacer(),
            Expanded(flex: 8, child: SignUpForm()),
            Spacer(),
          ],
        ),
        // const SocalSignUp()
      ],
    );
  }
}
