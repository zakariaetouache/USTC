import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InitialPageScreen extends StatefulWidget {
  @override
  State<InitialPageScreen> createState() => _InitialPageScreenState();
}

class _InitialPageScreenState extends State<InitialPageScreen> {
  String message = '';
  int messageLen = 0;
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _urlController =
      TextEditingController(); // No default value

  List<TextMessage> list = [];
  ScrollController _scrollController = ScrollController();

  Future<String> sendMessageToServer(String message) async {
    Map classLabels = {0: 'Negative 😔', 1: 'Neutral 😐', 2: 'Positive 😊'};

    final url = Uri.parse(_urlController.text.trim());
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'review_text': message,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return classLabels[responseData['predicted_class']];
    } else {
      throw Exception('Failed to send message to the server');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage('images/sh.jpeg'),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              "USTC",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: _urlController,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade700,
                    hintText: "Paste your backend URL here",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              list = [];
              setState(() {});
            },
            child: Text(
              'Reset Chat',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade300,
        child: Padding(
          padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return TextMessage(
                        message: list[index].message,
                        sender: list[index].sender);
                  },
                ),
              ),
              Row(children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      minLines: 1,
                      maxLines: 6,
                      controller: _textEditingController,
                      onChanged: (value) {
                        setState(() {
                          message = _textEditingController.text.trim();
                          messageLen = message.length;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.green.shade700,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.black45,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    color:
                        (messageLen == 0) ? Colors.grey : Colors.green.shade900,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      if (messageLen > 0) {
                        list.add(TextMessage(message: message, sender: true));
                        _textEditingController.clear();
                        messageLen = 0;
                        setState(() {});
                        _scrollToBottom();

                        try {
                          String serverResponse =
                              await sendMessageToServer(message);

                          list.add(TextMessage(
                              message: serverResponse, sender: false));
                          setState(() {});
                          _scrollToBottom();
                        } catch (e) {
                          list.add(
                              TextMessage(message: 'Error: $e', sender: false));
                          setState(() {});
                          _scrollToBottom();
                        }
                        message = "";
                      }
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class TextMessage extends StatelessWidget {
  final String message;
  final bool sender;

  const TextMessage({super.key, required this.message, required this.sender});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment:
            sender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (sender) SizedBox(width: 60),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color:
                    sender ? Color.fromARGB(255, 149, 214, 152) : Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topLeft: sender ? Radius.circular(15) : Radius.circular(0),
                  topRight: sender ? Radius.circular(0) : Radius.circular(15),
                ),
              ),
              padding: EdgeInsets.all(10),
              child: Text(
                message,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          if (!sender) SizedBox(width: 60),
        ],
      ),
    );
  }
}
