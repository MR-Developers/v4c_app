import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:v4c_app/User/WeekSelectionPage.dart';

class FileSelectionPage extends StatefulWidget {
  final String className;
  final String courseName;
  final String userEmail;

  const FileSelectionPage({
    required this.className,
    required this.courseName,
    required this.userEmail,
    super.key,
  });

  @override
  State<FileSelectionPage> createState() => _FileSelectionPageState();
}

class _FileSelectionPageState extends State<FileSelectionPage> {
  int selectedIndex = 0;
  final FocusNode _keyboardFocusNode = FocusNode();

  final List<_ClassItem> classOptions = [
    _ClassItem(
      name: "Videos",
      iconData: Icons.play_circle_fill,
      gradient: [Color(0xFFFFD7FC), Color(0xFFC5C9FF)],
    ),
    _ClassItem(
      name: "Lesson Plans",
      iconData: Icons.description,
      gradient: [Color(0xFFFFDCB6), Color(0xFFA5F7FF)],
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
      int maxIndex = classOptions.length;
      if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          selectedIndex < maxIndex - 1) {
        setState(() => selectedIndex++);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
          selectedIndex > 0) {
        setState(() => selectedIndex--);
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        _onContentTypeSelected(classOptions[selectedIndex].name);
      }
    }
  }

  void _onContentTypeSelected(String contentType) {
    String content = contentType == "Videos"
        ? "video"
        : contentType == "Lesson Plans"
            ? "pdf"
            : "flipBook";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeekSelectionPage(
          selectedClass: widget.className,
          courseName: widget.courseName,
          selectedContentType: content,
          userEmail: widget.userEmail,
        ),
      ),
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
                        onTap: () => _onContentTypeSelected(item.name),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 100),
                          margin: EdgeInsets.symmetric(horizontal: 16),
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
                              Icon(item.iconData,
                                  size: 100, color: Colors.black87),
                              SizedBox(height: 8),
                              Text(
                                item.name,
                                style: TextStyle(
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
            // Bottom bar
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
                      "Videos Or Lesson Plans?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  // You can skip Resume button for now or pass data as needed
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
  final IconData iconData;
  final List<Color> gradient;

  _ClassItem({
    required this.name,
    required this.iconData,
    required this.gradient,
  });
}
