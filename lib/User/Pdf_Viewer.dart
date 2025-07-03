import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfFullScreenPage extends StatefulWidget {
  final String pdfUrl;
  const PdfFullScreenPage({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  State<PdfFullScreenPage> createState() => _PdfFullScreenPageState();
}

class _PdfFullScreenPageState extends State<PdfFullScreenPage> {
  late final PdfViewerController _pdfCtrl;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _pdfCtrl = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.pageDown) {
      _pdfCtrl.nextPage();
    }

    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.pageUp) {
      _pdfCtrl.previousPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: _handleKey,
        child: SfPdfViewer.network(
          widget.pdfUrl,
          controller: _pdfCtrl,
          scrollDirection: PdfScrollDirection.vertical,
          canShowScrollStatus: true,
        ),
      ),
    );
  }
}
