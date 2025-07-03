import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoFullScreen extends StatefulWidget {
  final String videoUrl;

  const VideoFullScreen({super.key, required this.videoUrl});

  @override
  State<VideoFullScreen> createState() => _VideoFullScreenState();
}

class _VideoFullScreenState extends State<VideoFullScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final String autoplayUrl = widget.videoUrl.contains('?')
        ? '${widget.videoUrl}&autoplay=1'
        : '${widget.videoUrl}?autoplay=1';

    final String htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        html, body {
          margin: 0;
          padding: 0;
          background-color: black;
          height: 100%;
          overflow: hidden;
        }
        .video-container {
          position: relative;
          padding-bottom: 56.25%;
          height: 0;
        }
        .video-container iframe {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          border: none;
        }
      </style>
    </head>
    <body>
      <div class="video-container">
        <iframe 
          src="$autoplayUrl"
          allow="autoplay; fullscreen; picture-in-picture"
          allowfullscreen
          title="Video Player">
        </iframe>
      </div>
    </body>
    </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WebViewWidget(controller: _controller),
    );
  }
}
