import 'package:flutter/material.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/admindashboard_page.dart';
import 'package:mobileapplication/authenticationpages/loginpage/login_page.dart';
import 'package:mobileapplication/reusable_widget/reusable_widget.dart';

class MySignin extends StatefulWidget {
  const MySignin({super.key});

  @override
  State<MySignin> createState() => _MySigninState();
}

class _MySigninState extends State<MySignin> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool showLogo =
              constraints.maxHeight > 600 && !isKeyboardVisible;

          final double screenWidth = constraints.maxWidth;

          final double logoSize =
              screenWidth * 0.6 > 325 ? 325 : screenWidth * 0.5;

          return Stack(
            fit: StackFit.expand,
            children: [
              const Image(
                image: AssetImage('assets/MarineGaurdBackground.jpg'),
                fit: BoxFit.cover,
              ),

              // Content
              SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (showLogo) ...[
                          Transform.translate(
                            offset: const Offset(0, -60),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: logoWidget(
                                'assets/MarineGuard-Logo-preview.png',
                                logoSize,
                                logoSize,
                              ),
                            ),
                          ),
                        ],

                        Transform.translate(
                          offset: const Offset(0, -80),
                          child: myText('Marine \n Guard'),
                        ),

                        Transform.translate(
                          offset: const Offset(0, -50),
                          child: myText(
                            'Mobile Service',
                            labelstyle: const TextStyle(
                                fontSize: 17,
                                height: 1,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w300),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Continue with Email Button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: myButton2(
                              context,
                              'Login',
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage())),
                              labelStyle: const TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Roboto',
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              isResponsive: false),
                        ),

                        // Sign in As Guest Button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: myButton2(
                              context,
                              'Sign in As Guest',
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AdmindashboardPage())),
                              labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  decoration: TextDecoration.none),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60),
                                color: Colors.transparent,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              isResponsive: false),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
