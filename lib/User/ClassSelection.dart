import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:v4c_app/User/FileSelection.dart';

class ClassSelectionPage extends StatefulWidget {
  const ClassSelectionPage({super.key});

  @override
  State<ClassSelectionPage> createState() => _ClassSelectionPageState();
}

class _ClassSelectionPageState extends State<ClassSelectionPage> {
  int selectedIndex = 0;
  final FocusNode _keyboardFocusNode = FocusNode();

  final List<_ClassItem> classOptions = [
    _ClassItem(
      name: "Nursery",
      imagePath: "assets/images/Seed.png",
      gradient: [Color(0xFFFFD7FC), Color(0xFFC5C9FF)],
    ),
    _ClassItem(
      name: "LKG",
      imagePath: "assets/images/Sapling.png",
      gradient: [Color(0xFFFFDCB6), Color(0xFFA5F7FF)],
    ),
    _ClassItem(
      name: "UKG",
      imagePath: "assets/images/Plant.png",
      gradient: [Color(0xFFFF9929), Color(0xFFFEFEFE)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      int maxIndex = classOptions.length; // last index is resume button
      if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          selectedIndex < maxIndex) {
        setState(() => selectedIndex++);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
          selectedIndex > 0) {
        setState(() => selectedIndex--);
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        if (selectedIndex < classOptions.length) {
          _onClassSelected(classOptions[selectedIndex].name);
        } else {
          _onResumePressed();
        }
      }
    }
  }

  void _onClassSelected(String className) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FileSelectionPage()),
    );
  }

  void _onResumePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resumed Previous')),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FileSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RawKeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKey: _handleKey,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: classOptions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return GestureDetector(
                        onTap: () => _onClassSelected(item.name),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          width: 250,
                          height: 223,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: item.gradient,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: index == selectedIndex
                                  ? Colors.blue.withOpacity(0.8)
                                  : Colors.grey.shade400,
                            ),
                            boxShadow: index == selectedIndex
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.5),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(item.imagePath,
                                  height: 100, width: 100),
                              const SizedBox(height: 8),
                              Text(
                                item.name,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // Bottom Bar
            Positioned(
              bottom: 30,
              left: 30,
              right: 30,
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/Avatar.png",
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Text(
                      "What Are You Teaching Now?",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _onResumePressed,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: selectedIndex == classOptions.length
                              ? Colors.blue.withOpacity(0.8)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.play_arrow, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Resume Previous",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ClassItem {
  final String name;
  final String imagePath;
  final List<Color> gradient;

  _ClassItem({
    required this.name,
    required this.imagePath,
    required this.gradient,
  });
}
