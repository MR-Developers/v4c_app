import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:v4c_app/User/Pdf_Viewer.dart';
import 'package:v4c_app/User/VideoFullScree.dart';

class PdfListPage extends StatefulWidget {
  const PdfListPage({super.key});

  @override
  State<PdfListPage> createState() => _PdfListPageState();
}

class _PdfListPageState extends State<PdfListPage> {
  int selectedIndex = 0;
  final List<String> titles = List.generate(50, (index) => 'FlipBook ${index + 1}');
  final List<FocusNode> itemFocusNodes = [];
  final ScrollController _scrollController = ScrollController();
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    for (var _ in titles) {
      itemFocusNodes.add(FocusNode());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
      _focusAndScrollTo(selectedIndex);
    });
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

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
          selectedIndex < titles.length - 1) {
        setState(() => selectedIndex++);
        _focusAndScrollTo(selectedIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
          selectedIndex > 0) {
        setState(() => selectedIndex--);
        _focusAndScrollTo(selectedIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        // Navigate to detail page
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PdfFullScreenPage(
                  pdfUrl:
                      "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")),
        );
      }
    }
  }

  void _focusAndScrollTo(int index) {
    itemFocusNodes[index].requestFocus();
    final context = itemFocusNodes[index].context;

    if (context != null) {
      _scrollToContext(context);
    } else {
      // Wait until after layout to retry
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final retryContext = itemFocusNodes[index].context;
        if (retryContext != null) {
          _scrollToContext(retryContext);
        }
      });
    }
  }

  void _scrollToContext(BuildContext context) {
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      alignment: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      onKey: _handleKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('PDF List')),
        body: ListView.builder(
          controller: _scrollController,
          itemCount: titles.length,
          itemBuilder: (context, index) {
            return Focus(
              focusNode: itemFocusNodes[index],
              child: Builder(
                builder: (context) {
                  final hasFocus = Focus.of(context).hasFocus;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: hasFocus ? Colors.orangeAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      titles[index],
                      style: TextStyle(
                        fontSize: 18,
                        color: hasFocus ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
