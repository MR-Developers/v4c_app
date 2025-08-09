import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FocusNode _logoutButtonFocusNode = FocusNode();
  bool _isLoading = false;

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
    _logoutButtonFocusNode.dispose();
    super.dispose();
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      int maxIndex = classOptions.length - 1;
      if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          selectedIndex < maxIndex) {
        setState(() => selectedIndex++);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
          selectedIndex > 0) {
        setState(() => selectedIndex--);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        // Move focus to logout button
        _logoutButtonFocusNode.requestFocus();
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        if (selectedIndex <= maxIndex) {
          _onClassSelected(classOptions[selectedIndex].name);
        }
      }
    }
  }

  void _handleLogoutKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        // Move focus back to class cards
        _keyboardFocusNode.requestFocus();
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        _logout();
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _onClassSelected(String className) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userEmail = currentUser.email;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .get();

      if (!userDoc.exists) {
        _showMessage("User data not found");
        return;
      }

      final schoolName = userDoc.data()?['schoolName'];
      if (schoolName == null) {
        _showMessage("School not assigned to user");
        return;
      }

      final classDoc = await FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolName)
          .collection('classes')
          .doc(className)
          .get();

      if (!classDoc.exists) {
        _showMessage("Class data not found in school");
        return;
      }

      final courseName = classDoc.data()?['courseName'];
      if (courseName == null) {
        _showMessage("No course assigned to this class");
        return;
      }

      final courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseName)
          .get();

      if (!courseDoc.exists) {
        _showMessage("Course content not available");
        return;
      }

      setState(() {
        _isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileSelectionPage(
            courseName: courseName,
            className: className,
            userEmail: userEmail ?? '',
          ),
        ),
      );
    } catch (e) {
      _showMessage("Error fetching course data: $e");
    }
  }

  void _showMessage(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RawKeyboardListener(
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      RawKeyboardListener(
                        focusNode: _logoutButtonFocusNode,
                        onKey: _handleLogoutKey,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: _logout,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
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
