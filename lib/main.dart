import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  int questionCount = 0;
  int maxLimit = 90;

  final String apiKey = "YOUR_API_KEY"; // 👈 apni key daal

  Future<String> getAIResponse(String message) async {
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": message}
              ]
            }
          ]
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      // ✅ SAFE PARSING
      if (data.containsKey("candidates") &&
          data["candidates"] != null &&
          data["candidates"].length > 0) {
        var parts = data["candidates"][0]["content"]["parts"];

        if (parts != null &&
            parts.length > 0 &&
            parts[0]["text"] != null) {
          questionCount++;
          return parts[0]["text"];
        }
      }

      if (data.containsKey("error")) {
        return "❌ ${data["error"]["message"]}";
      }

      return "⚠️ No response from AI";
    } catch (e) {
      return "❌ Error: $e";
    }
  }

  void sendMessage() async {
    if (controller.text.isEmpty) return;

    if (questionCount >= maxLimit) {
      setState(() {
        messages.add({"text": "❌ Daily limit reached", "isUser": false});
      });
      return;
    }

    String userMessage = controller.text;

    setState(() {
      messages.add({"text": userMessage, "isUser": true});
    });

    controller.clear();

    String aiResponse = await getAIResponse(userMessage);

    setState(() {
      messages.add({"text": aiResponse, "isUser": false});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("AI Chatbot 🤖"),
            Text(
              "✨ Developed by Ratan 🔥",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Hello 👋 Ratan! Ask me anything 🤖",
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: messages[index]["isUser"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: messages[index]["isUser"]
                          ? Colors.blue
                          : Colors.grey[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      messages[index]["text"],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    controller: controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ask anything...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Colors.blue),
                onPressed: sendMessage,
              )
            ],
          )
        ],
      ),
    );
  }
}
