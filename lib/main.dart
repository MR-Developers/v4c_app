import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v4c_app/User/ClassSelection.dart';

import 'firebase_options.dart';
import 'package:v4c_app/GetStarted.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final User? user = FirebaseAuth.instance.currentUser;

  runApp(MyApp(isLoggedIn: user != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor:
              Colors.orange.shade50, // Light orange background
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.all(Colors.orange),
          ),
          radioTheme: RadioThemeData(
            fillColor: MaterialStateProperty.all(Colors.orange),
          ),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.all(Colors.orange),
            trackColor: MaterialStateProperty.all(Colors.orange.shade200),
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.orange,
          ).copyWith(
            secondary: Colors.orangeAccent,
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.orange,
            selectionColor: Colors.orange.shade200,
            selectionHandleColor: Colors.orange,
          ),
        ),
        home: isLoggedIn ? const ClassSelectionPage() : Getstarted(),
      ),
    );
  }
}
