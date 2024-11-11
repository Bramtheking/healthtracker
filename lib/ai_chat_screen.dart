import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HealthAiChatScreen extends StatefulWidget {
  @override
  _HealthAiChatScreenState createState() => _HealthAiChatScreenState();
}

class _HealthAiChatScreenState extends State<HealthAiChatScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  // Hugging Face API key
  final String apiKey = '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';

  Future<void> getMedicalResponse(String question) async {
    setState(() {
      isLoading = true;
    });

    final apiUrl = "https://api-inference.huggingface.co/models/dmis-lab/biobert-base-cased-v1.1";
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "inputs": {
          "question": question,
          "context": "Provide a medically relevant response based on general health knowledge." // Placeholder context
        },
        "parameters": {"max_answer_len": 50},
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String medicalResponse = data["answer"].toString().trim();
      setState(() {
        messages.add({"sender": "AI", "text": medicalResponse});
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get response from the medical AI model')));
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
                      hintText: 'Ask me a health question...',
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
                      getMedicalResponse(userMessage);
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
