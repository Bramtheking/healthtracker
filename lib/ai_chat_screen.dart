import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiChatScreen extends StatefulWidget {
  @override
  _AiChatScreenState createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  // Replace this with your actual Hugging Face API key
  final String apiKey = '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';

  // The prompt that sets the context for the GPT-2 model
  final String promptPrefix = "You are a helpful AI assistant specializing in answering medical-related questions.";

  Future<void> getGPT2Response(String message) async {
    setState(() {
      isLoading = true;
    });

    final apiUrl = "https://api-inference.huggingface.co/models/gpt2";
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "inputs": "$promptPrefix\n$message",
        "parameters": {"max_length": 100},
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String gpt2Response = data[0]["generated_text"].toString().replaceFirst(promptPrefix, "").trim();
      setState(() {
        messages.add({"sender": "AI", "text": gpt2Response});
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle API failure
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get response from GPT-2')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical AI Assistant'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: message["sender"] == "AI" ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: message["sender"] == "AI" ? Colors.blue[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message["text"]!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask me a medical question...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String userMessage = _controller.text.trim();
                    if (userMessage.isNotEmpty) {
                      setState(() {
                        messages.add({"sender": "User", "text": userMessage});
                      });
                      _controller.clear();
                      getGPT2Response(userMessage);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
