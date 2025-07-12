import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:v4c_app/User/ClassSelection.dart';
import 'package:v4c_app/utils/ForgotPassword.dart';
import 'package:v4c_app/utils/TextFieldPage.dart';
import 'package:v4c_app/utils/hexcolor.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode loginButtonFocus = FocusNode();
  final FocusNode forgotPasswordFocus = FocusNode();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailFocus.requestFocus();
      setState(() {});
    });
  }

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    loginButtonFocus.dispose();
    forgotPasswordFocus.dispose();
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClassSelectionPage()),
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

  void CheckUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password.")),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address.")),
      );
      return;
    }

    try {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('Admin').doc(email).get();

      if (docSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user found with this email.")),
        );
      } else {
        loginUser();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error checking user: $e")),
      );
    }
  }

  TextStyle _labelStyle() => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      );

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (event) async {
        if (event is KeyDownEvent) {
          if (emailFocus.hasFocus &&
              event.logicalKey == LogicalKeyboardKey.arrowDown) {
            passwordFocus.requestFocus();
          } else if (passwordFocus.hasFocus &&
              event.logicalKey == LogicalKeyboardKey.arrowUp) {
            emailFocus.requestFocus();
          } else if (passwordFocus.hasFocus &&
              event.logicalKey == LogicalKeyboardKey.arrowDown) {
            forgotPasswordFocus.requestFocus();
          } else if (forgotPasswordFocus.hasFocus &&
              event.logicalKey == LogicalKeyboardKey.arrowUp) {
            passwordFocus.requestFocus();
          } else if (forgotPasswordFocus.hasFocus &&
              event.logicalKey == LogicalKeyboardKey.arrowDown) {
            loginButtonFocus.requestFocus();
          } else if (loginButtonFocus.hasFocus &&
              event.logicalKey == LogicalKeyboardKey.arrowUp) {
            forgotPasswordFocus.requestFocus();
          } else if (passwordFocus.hasFocus &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            CheckUser(); // Trigger login from password field
          }
          setState(() {});
        }
      },
      child: Scaffold(
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
                          actions: {
                            ActivateIntent: CallbackAction<ActivateIntent>(
                              onInvoke: (intent) async {
                                emailController.text = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TextFieldPage(Type: "Email"),
                                  ),
                                );
                                setState(() {});
                                return null;
                              },
                            ),
                          },
                          child: buildInputBox(
                              emailFocus,
                              emailController.text.isNotEmpty
                                  ? emailController.text
                                  : 'Enter your Email'),
                        ),
                        const SizedBox(height: 20),
                        Text("Password", style: _labelStyle()),
                        const SizedBox(height: 8),
                        FocusableActionDetector(
                          focusNode: passwordFocus,
                          actions: {
                            ActivateIntent: CallbackAction<ActivateIntent>(
                              onInvoke: (intent) async {
                                passwordController.text = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TextFieldPage(Type: "Password"),
                                  ),
                                ) as String;
                                setState(() {});
                                return null;
                              },
                            ),
                          },
                          child: buildInputBox(
                              passwordFocus,
                              passwordController.text.isNotEmpty
                                  ? '${'*' * passwordController.text.length}'
                                  : 'Enter your Password'),
                        ),
                        const SizedBox(height: 5),
                        FocusableActionDetector(
                          focusNode: forgotPasswordFocus,
                          actions: {
                            ActivateIntent: CallbackAction<ActivateIntent>(
                              onInvoke: (intent) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPassword(),
                                    ));
                                return null;
                              },
                            ),
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: forgotPasswordFocus.hasFocus
                                      ? Colors.orange
                                      : Colors.blue,
                                ),
                              ),
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
                          onFocusChange: (_) => setState(() {}),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor("#F17E01"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                side: BorderSide(
                                  color: loginButtonFocus.hasFocus
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                elevation: loginButtonFocus.hasFocus ? 8 : 2,
                                shadowColor: loginButtonFocus.hasFocus
                                    ? Colors.cyan[200]
                                    : Colors.grey.withOpacity(0.5),
                              ),
                              onPressed: isLoading ? null : CheckUser,
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
      ),
    );
  }

  Widget buildInputBox(FocusNode focusNode, String text) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: focusNode.hasFocus
              ? Colors.blue.withOpacity(0.8)
              : Colors.grey.shade400,
        ),
        boxShadow: focusNode.hasFocus
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
        padding: const EdgeInsets.only(left: 10, top: 16, bottom: 16),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: focusNode.hasFocus ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }
}
