import 'dart:convert';

import 'package:chat_gtp_flutter_tut/chat_response/chat_response.dart';
import 'package:chat_gtp_flutter_tut/chat_response/choice.dart';
import 'package:chat_gtp_flutter_tut/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController chatController = TextEditingController();
  ValueNotifier chats = ValueNotifier<List<Chat>>([]);
  ValueNotifier messages = ValueNotifier<List<Map<String, String>>>([]);

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: const Text("Chat"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _clear,
            icon: Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(CupertinoIcons.delete, size: 18),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: ListView.builder(
                addAutomaticKeepAlives: true,
                itemCount: chats.value.length,
                itemBuilder: (ctx, index) => ChatMessage(chat: chats.value[index]),
              ),
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: chatController,
                      onFieldSubmitted: (value) => _doneTypinig(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintText: "Ask me anything",
                        hintStyle: TextStyle(color: Colors.white38),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4, left: 8),
                  decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                  child: loading
                      ? Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)))
                      : IconButton(
                          onPressed: _doneTypinig,
                          icon: Icon(CupertinoIcons.paperplane, color: Colors.white),
                        ),
                )
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  _doneTypinig() async {
    final apiKey = "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";
    FocusScope.of(context).unfocus();
    final message = chatController.text.trim();

    if (message.isEmpty) return;

    try {
      final url = Uri.https('api.openai.com', '/v1/chat/completions');
      final chat = Chat(role: "user", content: message);

      setState(() {
        chats.value.add(chat);
        messages.value.add(chat.toJson());
        chatController.clear();
        loading = true;
      });

      final body = {
        "model": "gpt-3.5-turbo",
        "messages": messages.value,
      };

      final response = await post(
        url,
        body: jsonEncode(body),
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $apiKey",
        },
      );

      if (response.statusCode == 200) {
        ChatResponse chatResponse = ChatResponse.fromJson(jsonDecode(response.body));
        setState(() {
          chatController.clear();
          List<Choice> choices = chatResponse.choices ?? [];
          final role = choices.first.message?.role.value;
          final content = choices.map((choice) => choice.message?.content ?? "").toList().join(" ");
          final chat = Chat(role: role.value, content: content);

          chats.value.add(chat);
          messages.value.add(chat.toJson());
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error getting a response.")),
          );
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error getting a response.")),
        );
      }
    } finally {
      setState(() => loading = false);
    }
  }

  void _clear() {
    HapticFeedback.mediumImpact();
    setState(() {
      chatController.clear();
      messages.value.clear();
      chats.value.clear();
    });
  }
}
