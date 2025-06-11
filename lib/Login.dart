import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:v4c_app/hexcolor.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode loginButtonFocus = FocusNode();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorText;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailFocus.requestFocus();
      setState(() {});
    });

    emailFocus.addListener(() {
      if (!emailFocus.hasFocus) {
        passwordFocus.requestFocus();
        setState(() {});
      }
    });

    passwordFocus.addListener(() {
      if (!passwordFocus.hasFocus) {
        loginButtonFocus.requestFocus();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    loginButtonFocus.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorText = e.message ?? "Authentication failed";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Log In To Your Account",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Welcome back! Login Using Your Credentials.",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text("Email", style: _labelStyle()),
                      const SizedBox(height: 8),
                      FocusableActionDetector(
                        focusNode: emailFocus,
                        autofocus: false,
                        actions: {
                          ActivateIntent: CallbackAction<ActivateIntent>(
                            onInvoke: (intent) {
                              print("OK");
                              return null;
                            },
                          ),
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: emailFocus.hasFocus
                                  ? Colors.blue.withOpacity(0.8)
                                  : Colors.grey.shade400,
                            ),
                            boxShadow: emailFocus.hasFocus
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.5),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : [],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 268, top: 16, bottom: 16),
                            child: Text(
                              'Enter your Email',
                              style: TextStyle(
                                fontSize: 18,
                                color: emailFocus.hasFocus
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text("Password", style: _labelStyle()),
                      const SizedBox(height: 8),
                      FocusableActionDetector(
                        focusNode: passwordFocus,
                        autofocus: false,
                        actions: {
                          ActivateIntent: CallbackAction<ActivateIntent>(
                            onInvoke: (intent) {
                              print("OK Password");
                              loginButtonFocus.requestFocus();
                              return null;
                            },
                          ),
                        },
                        child: GestureDetector(
                          onTap: () {
                            passwordFocus.requestFocus();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: passwordFocus.hasFocus
                                    ? Colors.blue.withOpacity(0.8)
                                    : Colors.grey.shade400,
                              ),
                              boxShadow: passwordFocus.hasFocus
                                  ? [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.5),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 230, top: 16, bottom: 16),
                              child: Text(
                                'Enter your Password',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: passwordFocus.hasFocus
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Focus(
                        focusNode: loginButtonFocus,
                        onFocusChange: (hasFocus) {
                          setState(() {});
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HexColor("#F17E01"),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              elevation: loginButtonFocus.hasFocus ? 10 : 2,
                              animationDuration: Duration.zero,
                            ),
                            onPressed: isLoading ? null : loginUser,
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Text(
                                    "Log In",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: HexColor("#64B1B9"),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Container(
                    color: Colors.white,
                    child: Image.asset(
                      'assets/images/V4CLogo(Landscape).png',
                      fit: BoxFit.contain,
                      width: 350,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _labelStyle() => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      );
}
