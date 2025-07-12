import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class VideoFullScreen extends StatefulWidget {
  final String videoUrl; // e.g. https://player.vimeo.com/video/VIDEO_ID

  const VideoFullScreen({super.key, required this.videoUrl});

  @override
  State<VideoFullScreen> createState() => _VideoFullScreenState();
}

class _VideoFullScreenState extends State<VideoFullScreen> {
  InAppWebViewController? _webViewController;

  String getHtml(String videoUrl) {
    final safeUrl = videoUrl.contains('?') ? videoUrl : '$videoUrl';

    return '''
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
          display: flex;
          justify-content: center;
          align-items: center;
        }
        iframe {
          width: 100vw;
          height: 100vh;
          border: none;
        }
      </style>
    </head>
    <body>
      <iframe
        id="vimeoFrame"
        src="$safeUrl"
        allow="autoplay; fullscreen; picture-in-picture"
        allowfullscreen
        frameborder="0"
      ></iframe>

      <script>
        window.onload = function () {
          const iframe = document.getElementById('vimeoFrame');
          iframe.focus();
        };
      </script>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: InAppWebView(
        initialData: InAppWebViewInitialData(
          data: getHtml(widget.videoUrl),
          baseUrl: WebUri("https://player.vimeo.com"),
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: true,
            supportZoom: false,
          ),
          android: AndroidInAppWebViewOptions(
            useWideViewPort: true,
            builtInZoomControls: false,
          ),
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onConsoleMessage: (controller, msg) {
          print("Web Console: ${msg.message}");
        },
      ),
    );
  }
}
