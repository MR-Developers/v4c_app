import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:v4c_app/utils/ResetEmailScreen.dart';
import 'package:v4c_app/utils/TextFieldPage.dart';
import 'package:v4c_app/utils/hexcolor.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final FocusNode emailFocus = FocusNode();
  final FocusNode buttonFocus = FocusNode();
  final TextEditingController emailController = TextEditingController();
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
    buttonFocus.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: KeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              if (emailFocus.hasFocus &&
                  event.logicalKey == LogicalKeyboardKey.arrowDown) {
                buttonFocus.requestFocus();
                setState(() {});
                Future.delayed(Duration(milliseconds: 100));
                return;
              }
            }
            if (event is KeyDownEvent) {
              if (buttonFocus.hasFocus &&
                  event.logicalKey == LogicalKeyboardKey.arrowUp) {
                emailFocus.requestFocus();
                setState(() {});
                Future.delayed(Duration(milliseconds: 100));
                return;
              }
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Forgot Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FocusableActionDetector(
                focusNode: emailFocus,
                autofocus: false,
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30),
                  child: Container(
                    width: double.infinity,
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
                      padding:
                          const EdgeInsets.only(left: 10, top: 16, bottom: 16),
                      child: Text(
                        emailController.text.isNotEmpty
                            ? emailController.text
                            : 'Enter your Email',
                        style: TextStyle(
                          fontSize: 18,
                          color:
                              emailFocus.hasFocus ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FocusableActionDetector(
                focusNode: buttonFocus,
                autofocus: false,
                onFocusChange: (hasFocus) => setState(() {}),
                actions: {
                  ActivateIntent: CallbackAction<ActivateIntent>(
                    onInvoke: (intent) {
                      sendResetEmail();
                      return null;
                    },
                  ),
                },
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonFocus.hasFocus
                          ? Colors.blue
                          : HexColor("#F17E01"),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: buttonFocus.hasFocus ? 10 : 2,
                      animationDuration: Duration.zero,
                    ),
                    onPressed: sendResetEmail,
                    child: const Text(
                      "Reset Password",
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
    );
  }

  Future<void> sendResetEmail() async {
    String email = emailController.text.trim();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset link sent to ${emailController.text}')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetEmailScreen(email: emailController.text),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error sending reset link')),
      );
    } catch (e) {
      // Handle any unknown errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error occurred')),
      );
    }
  }
}
