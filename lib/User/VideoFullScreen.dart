import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VdoPlaybackView extends StatefulWidget {
  final String videoUrl;
  const VdoPlaybackView({super.key, required this.videoUrl});

  @override
  State<VdoPlaybackView> createState() => _VdoPlaybackViewState();
}

class _VdoPlaybackViewState extends State<VdoPlaybackView> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  bool _showReplay = false;
  Timer? _hideControlsTimer;

  final FocusNode _keyboardFocusNode = FocusNode();
  final FocusNode _pauseFocusNode = FocusNode();
  final FocusNode _rewindFocusNode = FocusNode();
  final FocusNode _forwardFocusNode = FocusNode();
  final FocusNode _replayFocusNode = FocusNode(); // NEW

  IconData _playPauseIcon = Icons.pause;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = VideoPlayerController.network(
      widget.videoUrl,
    )..initialize().then((_) {
        setState(() {});
        _controller.play();
        _showControlsTemporarily();
      });

    _controller.addListener(() {
      final isEnded =
          _controller.value.position >= _controller.value.duration &&
              !_controller.value.isPlaying;

      if (isEnded && !_showReplay) {
        setState(() {
          _showReplay = true;
          _showControls = false;
        });

        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _replayFocusNode.requestFocus();
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _playPauseIcon = Icons.play_arrow;
      } else {
        _controller.play();
        _playPauseIcon = Icons.pause;
        _showReplay = false;
      }
    });
  }

  void _seekBy(Duration offset) {
    final duration = _controller.value.duration;
    final position = _controller.value.position;
    Duration newPosition = position + offset;

    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    } else if (newPosition > duration) {
      newPosition = duration;
    }

    _controller.seekTo(newPosition);
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);

    if (!_pauseFocusNode.hasFocus &&
        !_rewindFocusNode.hasFocus &&
        !_forwardFocusNode.hasFocus) {
      _pauseFocusNode.requestFocus();
    }

    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (!_showReplay) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideControlsTimer?.cancel();
    _keyboardFocusNode.dispose();
    _pauseFocusNode.dispose();
    _rewindFocusNode.dispose();
    _forwardFocusNode.dispose();
    _replayFocusNode.dispose(); // NEW
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print("Popping video view...");
        return true; // allow pop
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: RawKeyboardListener(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          onKey: (RawKeyEvent event) {
            if (event.logicalKey != LogicalKeyboardKey.enter &&
                event.logicalKey != LogicalKeyboardKey.select &&
                !_showReplay) {
              _showControlsTemporarily();
            }
          },
          child: GestureDetector(
            onTap: _showControlsTemporarily,
            child: _controller.value.isInitialized
                ? Stack(
                    children: [
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
                      if (_showControls) ...[
                        _buildControlsOverlay(),
                        _buildProgressBar(),
                      ],
                      if (_showReplay) _buildReplayOverlay(),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: VideoProgressIndicator(
        _controller,
        allowScrubbing: true,
        padding: const EdgeInsets.all(8.0),
        colors: const VideoProgressColors(
          playedColor: Colors.red,
          backgroundColor: Colors.white30,
          bufferedColor: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      color: Colors.black38,
      child: Center(
        child: FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: Icons.replay_10,
                onPressed: () {
                  _seekBy(const Duration(seconds: -10));
                  _showControlsTemporarily();
                },
                focusNode: _rewindFocusNode,
              ),
              const SizedBox(width: 20),
              _buildControlButton(
                icon: _playPauseIcon,
                onPressed: () {
                  _togglePlayPause();
                  _showControlsTemporarily();
                },
                focusNode: _pauseFocusNode,
              ),
              const SizedBox(width: 20),
              _buildControlButton(
                icon: Icons.forward_10,
                onPressed: () {
                  _seekBy(const Duration(seconds: 10));
                  _showControlsTemporarily();
                },
                focusNode: _forwardFocusNode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplayOverlay() {
    void handleReplay() async {
      await _controller.seekTo(Duration.zero);
      await _controller.play();

      setState(() {
        _showReplay = false;
        _showControls = false;
        _playPauseIcon = Icons.pause;
      });

      _showControlsTemporarily();
    }

    return Center(
      child: Focus(
        focusNode: _replayFocusNode,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.replay),
          label: const Text("Replay"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white24,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
          onPressed: handleReplay,
        ),
        onKey: (node, event) {
          if (event is RawKeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.select)) {
            handleReplay();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required FocusNode focusNode,
  }) {
    return Focus(
      focusNode: focusNode,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(focusNode);
              onPressed();
            },
            child: Container(
              decoration: BoxDecoration(
                color: hasFocus ? Colors.white24 : Colors.transparent,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10.0),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
          );
        },
      ),
      onKey: (node, event) {
        if (event is RawKeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.select)) {
          onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );
  }
}
