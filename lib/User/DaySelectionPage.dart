import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v4c_app/User/Pdf_Viewer.dart';
import 'package:v4c_app/User/VideoList.dart';

class DaySelectionPage extends StatefulWidget {
  final String userEmail;
  final String className;
  final String courseName;
  final String contentType;
  final String weekName;

  const DaySelectionPage({
    super.key,
    required this.userEmail,
    required this.className,
    required this.courseName,
    required this.contentType,
    required this.weekName,
  });

  @override
  State<DaySelectionPage> createState() => _DaySelectionPageState();
}

class _DaySelectionPageState extends State<DaySelectionPage> {
  List<String> availableDays = [];
  int selectedIndex = 0;
  bool isLoading = true;

  final FocusNode _keyboardFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<FocusNode> itemFocusNodes = [];

  @override
  void initState() {
    super.initState();
    fetchAvailableDays();
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

  String getFormattedDay(String rawDay) {
    final match = RegExp(r'(\d+)').firstMatch(rawDay);
    if (match != null) {
      return 'Day - ${match.group(1)}';
    }
    return rawDay; // fallback if format is unexpected
  }

  Future<void> fetchAvailableDays() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseName)
          .get();

      final data = doc.data();
      if (data == null) return;

      final content = data['content'];
      if (content is! Map) return;

      final week = content[widget.weekName];
      if (week is! Map) return;

      List<String> days = [];

      week.forEach((dayKey, dayValue) {
        if (dayValue is Map && dayValue.containsKey(widget.contentType)) {
          days.add(dayKey);
        }
      });

      days.sort();

      setState(() {
        availableDays = days;
        itemFocusNodes.addAll(List.generate(days.length, (_) => FocusNode()));
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (availableDays.isNotEmpty) {
          _keyboardFocusNode.requestFocus();
          _focusAndScrollTo(selectedIndex);
        }
      });
    } catch (e) {
      print("Error fetching days: $e");
    }
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent && availableDays.isNotEmpty) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
          selectedIndex < availableDays.length - 1) {
        setState(() => selectedIndex++);
        _focusAndScrollTo(selectedIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
          selectedIndex > 0) {
        setState(() => selectedIndex--);
        _focusAndScrollTo(selectedIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        _onDaySelected(availableDays[selectedIndex]);
      }
    }
  }

  void _focusAndScrollTo(int index) {
    itemFocusNodes[index].requestFocus();
    final context = itemFocusNodes[index].context;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 250),
        alignment: 0.5,
      );
    }
  }

  void _onDaySelected(String dayName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseName)
        .get();

    final content = snapshot.data()?['content'];
    final dayData = content?[widget.weekName]?[dayName];

    if (dayData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No content found for $dayName')),
      );
      return;
    }

    final type = widget.contentType.toLowerCase();

    if (type == 'video') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoListPage(
            courseName: widget.courseName,
            weekName: widget.weekName,
            dayName: dayName,
          ),
        ),
      );
    } else if (type == 'pdf') {
      final pdfUrl = dayData['pdf']?['url'];
      if (pdfUrl == null || pdfUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF not available for $dayName')),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfFullScreenPage(pdfUrl: pdfUrl),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unsupported content type')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RawKeyboardListener(
        focusNode: _keyboardFocusNode,
        onKey: _handleKey,
        autofocus: true,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : availableDays.isEmpty
                ? const Center(child: Text("No days available"))
                : SizedBox.expand(
                    child: Stack(
                      children: [
                        // Decorative background image - bottom right
                        Positioned(
                          bottom: 0,
                          right: -100,
                          child: Opacity(
                            opacity: 0.3,
                            child: Transform.rotate(
                              angle: -0.5236, // -30 degrees
                              child: Image.asset(
                                'assets/images/Cloud.png',
                                width: MediaQuery.of(context).size.width * 0.25,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        // Foreground content
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Text(
                                  'Select Day',
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
                                  itemCount: availableDays.length,
                                  itemBuilder: (context, index) {
                                    final day = availableDays[index];
                                    final isFocused = index == selectedIndex;

                                    return Focus(
                                      focusNode: itemFocusNodes[index],
                                      child: GestureDetector(
                                        onTap: () => _onDaySelected(day),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: isFocused
                                                ? Colors.orange.shade100
                                                : null,
                                            border: index <
                                                    availableDays.length - 1
                                                ? const Border(
                                                    bottom: BorderSide(
                                                        color: Colors.black12),
                                                  )
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
                                                  getFormattedDay(day),
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
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
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
