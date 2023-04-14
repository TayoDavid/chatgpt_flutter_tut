import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage({super.key, required this.chat});

  final Chat chat;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final author = widget.chat.role == "user" ? "User:" : "AI:";
    super.build(context);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.chat.role == "user" ? Colors.transparent : Colors.white12,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            padding: EdgeInsets.only(top: 4),
            child: Text(
              author,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: AnimatedTextKit(
              isRepeatingAnimation: false,
              totalRepeatCount: 0,
              repeatForever: false,
              animatedTexts: [
                TypewriterAnimatedText(
                  widget.chat.content,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum Author { human, ai }

extension AuthorExt on Author {
  String get value {
    switch (this) {
      case Author.human:
        return "Human";
      case Author.ai:
        return "AI";
    }
  }
}

extension StringExt on String? {
  String get value {
    return this ?? "";
  }
}

class Chat {
  String role;
  String content;

  Chat({required this.role, required this.content});

  Map<String, String> toJson() => {"role": role, "content": content};
}
