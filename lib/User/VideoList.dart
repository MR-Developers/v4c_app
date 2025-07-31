import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:v4c_app/User/VideoFullScreen.dart';

class VideoListPage extends StatefulWidget {
  final String courseName;
  final String weekName;
  final String dayName;

  const VideoListPage({
    super.key,
    required this.courseName,
    required this.weekName,
    required this.dayName,
  });

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  int selectedIndex = 0;
  final List<FocusNode> itemFocusNodes = [];
  final ScrollController _scrollController = ScrollController();
  final FocusNode _keyboardFocusNode = FocusNode();
  Map<String, dynamic> progressMap = {};

  List<MapEntry<String, String>> videos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseName)
          .get();

      final data = doc.data();
      if (data != null) {
        final content = data['content'] ?? {};
        final week = content[widget.weekName] ?? {};
        final day = week[widget.dayName] ?? {};
        final videoMap = Map<String, dynamic>.from(day['video'] ?? {});

        videos = videoMap.entries
            .map((e) => MapEntry(e.key.toString(), e.value.toString()))
            .toList();

        itemFocusNodes.addAll(List.generate(videos.length, (_) => FocusNode()));
      }
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final progressDoc = await FirebaseFirestore.instance
          .collection('Courseprogress')
          .doc(userId)
          .collection('courseProgress')
          .doc(widget.courseName)
          .get();

      if (progressDoc.exists) {
        print('Progress document exists');
        progressMap = progressDoc.data()?['completedContent'] ?? {};
      }
      print(progressMap);
    } catch (e) {
      debugPrint('Error fetching videos or progress: $e');
    }

    setState(() {
      isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (videos.isNotEmpty) {
        _keyboardFocusNode.requestFocus();
        _focusAndScrollTo(selectedIndex);
      }
    });
  }

  bool isVideoCompleted(String videoKey) {
    return progressMap[widget.weekName]?[widget.dayName]?['video']?[videoKey] ==
        true;
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

  Future<void> _handleKey(RawKeyEvent event) async {
    try {
      if (event is RawKeyDownEvent && videos.isNotEmpty) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
            selectedIndex < videos.length - 1) {
          setState(() => selectedIndex++);
          _focusAndScrollTo(selectedIndex);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
            selectedIndex > 0) {
          setState(() => selectedIndex--);
          _focusAndScrollTo(selectedIndex);
        } else if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.select) {
          final userId = FirebaseAuth.instance.currentUser!.uid;
          final videoKey = videos[selectedIndex].key;

          await FirebaseFirestore.instance
              .collection('Courseprogress')
              .doc(userId)
              .collection('courseProgress')
              .doc(widget.courseName)
              .set({
            'completedContent': {
              widget.weekName: {
                widget.dayName: {
                  'video': {videoKey: true}
                }
              }
            },
            'lastAccessed': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  VdoPlaybackView(videoUrl: videos[selectedIndex].value),
            ),
          );
          setState(() {
            isLoading = true;
          });
          // Refresh the progress map after playback
          final progressDoc = await FirebaseFirestore.instance
              .collection('Courseprogress')
              .doc(userId)
              .collection('courseProgress')
              .doc(widget.courseName)
              .get();
          await checkAndMarkDayWeekCourseCompletion();
          if (progressDoc.exists) {
            progressMap = progressDoc.data()?['completedContent'] ?? {};
          }
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error handling key event: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkAndMarkDayWeekCourseCompletion() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final courseSnap = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseName)
        .get();

    final courseContent = courseSnap.data()?['content'];
    final progressSnap = await FirebaseFirestore.instance
        .collection('Courseprogress')
        .doc(userId)
        .collection('courseProgress')
        .doc(widget.courseName)
        .get();

    final progress = progressSnap.data()?['completedContent'] ?? {};

    bool isDayComplete(String week, String day) {
      final courseDay = courseContent[week]?[day] ?? {};
      final userDayProgress = progress[week]?[day] ?? {};

      for (final type in courseDay.keys) {
        if (type == 'pdf') {
          if (userDayProgress['pdf'] != true) return false;
        } else if (type == 'video') {
          final videos = courseDay['video'] ?? {};
          for (final key in videos.keys) {
            if (userDayProgress['video']?[key] != true) return false;
          }
        }
      }
      return true;
    }

    final dayCompleted = isDayComplete(widget.weekName, widget.dayName);

    await FirebaseFirestore.instance
        .collection('Courseprogress')
        .doc(userId)
        .collection('courseProgress')
        .doc(widget.courseName)
        .set({
      'dayCompletion': {
        widget.weekName: {
          widget.dayName: dayCompleted,
        }
      },
    }, SetOptions(merge: true));

    /// Optional: Check if week complete
    final weekDays = courseContent[widget.weekName]?.keys ?? [];
    bool weekDone = true;
    for (final day in weekDays) {
      if (!(progressSnap.data()?['dayCompletion'][widget.weekName]?[day] ??
          false)) {
        weekDone = false;
        break;
      }
    }

    await FirebaseFirestore.instance
        .collection('Courseprogress')
        .doc(userId)
        .collection('courseProgress')
        .doc(widget.courseName)
        .set({
      'weekCompletion': {
        widget.weekName: weekDone,
      },
    }, SetOptions(merge: true));

    /// Optional: Check if course complete
    final allWeeks = courseContent.keys;
    bool courseDone = true;
    for (final week in allWeeks) {
      if (!(progressSnap.data()?['weekCompletion'][week] ?? false)) {
        courseDone = false;
        break;
      }
    }

    await FirebaseFirestore.instance
        .collection('Courseprogress')
        .doc(userId)
        .collection('courseProgress')
        .doc(widget.courseName)
        .set({
      'courseCompleted': courseDone,
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    for (var node in itemFocusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    _keyboardFocusNode.dispose();
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : videos.isEmpty
                ? const Center(child: Text("No videos available"))
                : Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Videos',
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
                            itemCount: videos.length,
                            itemBuilder: (context, index) {
                              final video = videos[index];
                              final isFocused = index == selectedIndex;
                              final isCompleted = isVideoCompleted(video.key);
                              return Focus(
                                focusNode: itemFocusNodes[index],
                                child: GestureDetector(
                                  onTap: () async {
                                    final userId =
                                        FirebaseAuth.instance.currentUser!.uid;
                                    final videoKey = videos[selectedIndex].key;

                                    await FirebaseFirestore.instance
                                        .collection('Courseprogress')
                                        .doc(userId)
                                        .collection('courseProgress')
                                        .doc(widget.courseName)
                                        .set({
                                      'completedContent.${widget.weekName}.${widget.dayName}.video.$videoKey':
                                          true,
                                      'lastAccessed':
                                          FieldValue.serverTimestamp(),
                                    }, SetOptions(merge: true));

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => VdoPlaybackView(
                                              videoUrl:
                                                  videos[selectedIndex].value)),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: isFocused
                                          ? Colors.orange.shade100
                                          : null,
                                      border: index < videos.length - 1
                                          ? const Border(
                                              bottom: BorderSide(
                                                  color: Colors.black12),
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCompleted
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          size: 20,
                                          color: isCompleted
                                              ? Colors.green
                                              : Colors.black26,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            video.key,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios,
                                            size: 16, color: Colors.black45),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
