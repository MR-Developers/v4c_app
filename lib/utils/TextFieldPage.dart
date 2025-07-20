import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldPage extends StatefulWidget {
  final String Type;
  const TextFieldPage({super.key, required this.Type});

  @override
  State<TextFieldPage> createState() => _TextFieldPageState();
}

class _TextFieldPageState extends State<TextFieldPage> {
  String input = '';

  final List<String> keys = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '@',
    '_',
    '-',
    '.',
    'DEL',
    'OK'
  ];

  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(keys.length, (_) => FocusNode());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNodes[0]);
    });
  }

  @override
  void dispose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void handleKeyPress(String key) {
    if (key == 'DEL') {
      if (input.isNotEmpty) {
        setState(() {
          input = input.substring(0, input.length - 1);
        });
      }
    } else if (key == 'OK') {
      Navigator.pop(context, input);
    } else {
      setState(() {
        input += key.toLowerCase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 24),
            buildInputDisplay(),
            buildKeyboard(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildInputDisplay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          margin: const EdgeInsets.only(bottom: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(
            input,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildKeyboard() {
    const int columns = 10;

    return FocusTraversalGroup(
      child: SizedBox(
        height: 360,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: keys.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final key = keys[index];
            final node = focusNodes[index];

            final isSpecialKey = key == 'DEL' || key == 'OK';
            final isActionKey = key == 'OK';

            return Focus(
              focusNode: node,
              onKey: (node, event) {
                if (event is RawKeyDownEvent &&
                    (event.logicalKey == LogicalKeyboardKey.select ||
                        event.logicalKey == LogicalKeyboardKey.enter)) {
                  handleKeyPress(key);
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: InkWell(
                onTap: () => handleKeyPress(key),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedBuilder(
                  animation: node,
                  builder: (context, child) {
                    final isFocused = node.hasFocus;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      transform: isFocused
                          ? (Matrix4.identity()..scale(1.04))
                          : Matrix4.identity(),
                      decoration: BoxDecoration(
                        color:
                            isFocused ? Colors.orange.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isFocused
                              ? Colors.deepOrange
                              : Colors.grey.shade300,
                          width: isFocused ? 2.2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        key,
                        style: TextStyle(
                          fontSize: isSpecialKey ? 18 : 20,
                          fontWeight:
                              isActionKey ? FontWeight.bold : FontWeight.w500,
                          color: isActionKey || key == 'DEL'
                              ? Colors.deepOrange
                              : Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
