import 'package:flutter/material.dart';
import 'package:vdocipher_flutter/vdocipher_flutter.dart';

class VdoPlaybackView extends StatefulWidget {
  const VdoPlaybackView({super.key});

  @override
  _VdoPlaybackViewState createState() => _VdoPlaybackViewState();
}

class _VdoPlaybackViewState extends State<VdoPlaybackView> {
  VdoPlayerController? _controller;
  final ValueNotifier<bool> _isFullScreen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    const EmbedInfo sample1 = EmbedInfo.streaming(
        otp: '20160313versASE313N2GIgnZjjFKOYWXnZY1ms8Y5YmvgJnt3v2phvCl7G9BsrJ',
        playbackInfo:
            'eyJ2aWRlb0lkIjoiYTllYWUwOTZjZDg4NGRiYmEzNTE1M2VlNDJhNTA0YTgifQ==',
        embedInfoOptions: EmbedInfoOptions(autoplay: true));
    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Flexible(
          child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: _isFullScreen.value
            ? MediaQuery.of(context).size.height
            : _getHeightForWidth(MediaQuery.of(context).size.width),
        child: VdoPlayer(
          embedInfo: sample1,
          onPlayerCreated: (controller) => _onPlayerCreated(controller),
          onFullscreenChange: _onFullscreenChange,
          onError: _onVdoError,
          controls: true, //optional, set false to disable player controls
        ),
      )),
      ValueListenableBuilder(
          valueListenable: _isFullScreen,
          builder: (context, dynamic value, child) {
            return value ? const SizedBox.shrink() : _nonFullScreenContent();
          }),
    ]));
  }

  _onVdoError(VdoError vdoError) {
    print("Oops, the system encountered a problem: ${vdoError.message}");
  }

  _onPlayerCreated(VdoPlayerController? controller) {
    setState(() {
      _controller = controller;
      _onEventChange(_controller);
    });
  }

  _onEventChange(VdoPlayerController? controller) {
    controller!.addListener(() {
      VdoPlayerValue value = controller.value;

      print("VdoControllerListner"
          "\nloading: ${value.isLoading} "
          "\nplaying: ${value.isPlaying} "
          "\nbuffering: ${value.isBuffering} "
          "\nended: ${value.isEnded}");
    });
  }

  _onFullscreenChange(isFullscreen) {
    setState(() {
      _isFullScreen.value = isFullscreen;
    });
  }

  _nonFullScreenContent() {
    return const Column(children: [
      Text(
        'Sample Playback',
        style: TextStyle(fontSize: 20.0),
      )
    ]);
  }

  double _getHeightForWidth(double width) {
    return width;
  }
}
