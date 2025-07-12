import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DaySelectionPage.dart';

class WeekSelectionPage extends StatefulWidget {
  final String selectedClass;
  final String selectedContentType;
  final String userEmail;
  final String courseName;

  const WeekSelectionPage({
    required this.selectedClass,
    required this.selectedContentType,
    required this.userEmail,
    required this.courseName,
    super.key,
  });

  @override
  State<WeekSelectionPage> createState() => _WeekSelectionPageState();
}

class _WeekSelectionPageState extends State<WeekSelectionPage> {
  List<String> weekKeys = [];
  int selectedIndex = 0;
  final FocusNode _keyboardFocusNode = FocusNode();
  final List<FocusNode> itemFocusNodes = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadWeeks();
  }

  String getFormattedWeek(String rawWeek) {
    final match = RegExp(r'(\d+)').firstMatch(rawWeek);
    if (match != null) {
      return 'Week - ${match.group(1)}';
    }
    return rawWeek; // fallback if format is unexpected
  }

  Future<void> _loadWeeks() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.userEmail)
          .get();
      final schoolName = userDoc.data()?['schoolName'];
      if (schoolName == null) return;

      final classDoc = await FirebaseFirestore.instance
          .collection("schools")
          .doc(schoolName)
          .collection("classes")
          .doc(widget.selectedClass)
          .get();
      final courseName = classDoc.data()?['courseName'];
      if (courseName == null) return;

      final courseDoc = await FirebaseFirestore.instance
          .collection("courses")
          .doc(courseName)
          .get();
      final content = courseDoc.data()?['content'] as Map<String, dynamic>?;

      if (content != null) {
        setState(() {
          weekKeys = content.keys.toList()..sort();
          itemFocusNodes
              .addAll(List.generate(weekKeys.length, (_) => FocusNode()));
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (weekKeys.isNotEmpty) {
            _keyboardFocusNode.requestFocus();
            _focusAndScrollTo(selectedIndex);
          }
        });
      }
    } catch (e) {
      print("Error loading weeks: $e");
    }
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
          selectedIndex < weekKeys.length - 1) {
        setState(() => selectedIndex++);
        _focusAndScrollTo(selectedIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
          selectedIndex > 0) {
        setState(() => selectedIndex--);
        _focusAndScrollTo(selectedIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        _onWeekSelected(weekKeys[selectedIndex]);
      }
    }
  }

  void _focusAndScrollTo(int index) {
    itemFocusNodes[index].requestFocus();
    final context = itemFocusNodes[index].context;
    if (context != null) {
      Scrollable.ensureVisible(context,
          duration: const Duration(milliseconds: 200), alignment: 0.5);
    }
  }

  void _onWeekSelected(String weekKey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DaySelectionPage(
          userEmail: widget.userEmail,
          className: widget.selectedClass,
          contentType: widget.selectedContentType,
          weekName: weekKey,
          courseName: widget.courseName,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var node in itemFocusNodes) {
      node.dispose();
    }
    _keyboardFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RawKeyboardListener(
        focusNode: _keyboardFocusNode,
        onKey: _handleKey,
        autofocus: true,
        child: weekKeys.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SizedBox.expand(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Select Week',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: weekKeys.length,
                              itemBuilder: (context, index) {
                                final week = weekKeys[index];
                                final isFocused = index == selectedIndex;

                                return Focus(
                                  focusNode: itemFocusNodes[index],
                                  child: GestureDetector(
                                    onTap: () => _onWeekSelected(week),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: isFocused
                                            ? Colors.orange.shade100
                                            : null,
                                        border: index < weekKeys.length - 1
                                            ? const Border(
                                                bottom: BorderSide(
                                                    color: Colors.black12))
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.radio_button_unchecked,
                                            size: 20,
                                            color: Colors.black26,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                              child: Text(
                                            getFormattedWeek(week),
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.black87),
                                          )),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.black45,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                              height: 100), // Padding above Resume button
                        ],
                      ),
                    ),

                    // Resume Button
                    // Positioned(
                    //   right: 30,
                    //   bottom: 30,
                    //   child: ElevatedButton.icon(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.orange,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(30),
                    //       ),
                    //     ),
                    //     onPressed: () {
                    //       print("Resume Previous clicked");
                    //     },
                    //     icon: const Icon(Icons.play_arrow, color: Colors.white),
                    //     label: const Text(
                    //       "Resume Previous",
                    //       style: TextStyle(color: Colors.white),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
      ),
    );
  }
}
