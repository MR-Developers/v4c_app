import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:v4c_app/User/VideoFullScree.dart';

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
    } catch (e) {
      debugPrint('Error fetching videos: $e');
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

  void _handleKey(RawKeyEvent event) {
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoFullScreen(
              videoUrl: videos[selectedIndex].value,
            ),
          ),
        );
      }
    }
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

                              return Focus(
                                focusNode: itemFocusNodes[index],
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VideoFullScreen(
                                          videoUrl: video.value,
                                        ),
                                      ),
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
                                        const Icon(Icons.radio_button_unchecked,
                                            size: 20, color: Colors.black26),
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
