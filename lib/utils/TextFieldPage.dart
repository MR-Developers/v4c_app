import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextFieldPage extends StatefulWidget {
  final String Type;
  const TextFieldPage({super.key, required this.Type});

  @override
  State<TextFieldPage> createState() => _TextFieldPageState();
}

class _TextFieldPageState extends State<TextFieldPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Enter Your ${widget.Type}",
                  border: OutlineInputBorder(),
                  prefixIcon: widget.Type == "Password"
                      ? const Icon(Icons.lock)
                      : const Icon(Icons.mail),
                ),
                obscureText: widget.Type == "Password",
                onSubmitted: (value) {
                  Navigator.pop(context, value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
