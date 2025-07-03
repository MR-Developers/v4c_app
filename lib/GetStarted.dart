import 'package:flutter/material.dart';
import 'package:v4c_app/utils/Login.dart';
import 'package:v4c_app/utils/hexcolor.dart';

class Getstarted extends StatefulWidget {
  @override
  _GetstartedState createState() => _GetstartedState();
}

class _GetstartedState extends State<Getstarted> {
  bool _isFocused = false;
  bool _isPressed = false;

  void _onPressed() {
    setState(() {
      _isPressed = true;
    });

    // Optional: Visual feedback for click (like a scale or short delay)
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _isPressed = false;
      });

      // Navigate or perform action
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
      // Navigator.push(...);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Cloud
          Positioned(
            top: -40,
            left: -55,
            child: Transform.rotate(
              angle: 1.3,
              child: Image.asset(
                'assets/images/Cloud.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 100.0, vertical: 50.0),
            child: Row(
              children: [
                // Left side
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Hi ! Welcome to V4C',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'V4C is a fun and easy app that helps your school work better! '
                          'It helps teachers plan lessons, and show cool videos in class. '
                          'With V4C, learning becomes smarter and more exciting for everyone!',
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),

                      // Focus + Action + Visual Feedback
                      FocusableActionDetector(
                        onFocusChange: (focus) {
                          setState(() => _isFocused = focus);
                        },
                        actions: {
                          ActivateIntent: CallbackAction<Intent>(
                            onInvoke: (intent) => _onPressed(),
                          ),
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 100),
                          transform: _isPressed
                              ? (Matrix4.identity()..scale(0.98)).clone()
                              : Matrix4.identity().clone(),
                          decoration: BoxDecoration(
                            border: _isFocused
                                ? Border.all(
                                    color: Colors.blue!,
                                    width: 2,
                                  )
                                : null,
                            color: _isFocused
                                ? Colors.amber[800]
                                : HexColor("#F17E01"),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 120.0),
                            child: Text(
                              "Get Started",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right side image
                Expanded(
                  child: Image.asset(
                    height: 445,
                    width: 457,
                    'assets/images/Avatar.png',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
