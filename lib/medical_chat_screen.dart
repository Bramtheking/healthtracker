import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MedicalChatScreen extends StatefulWidget {
  @override
  _MedicalChatScreenState createState() => _MedicalChatScreenState();
}

class _MedicalChatScreenState extends State<MedicalChatScreen> {
  TextEditingController _questionController = TextEditingController();
  List<Map<String, String>> chatMessages = [];
  bool isLoading = false;

  final String apiKey = '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';

  Future<void> fetchMedicalResponse(String question) async {
    setState(() {
      isLoading = true;
    });

    final url = "https://api-inference.huggingface.co/models/distilbert-base-uncased-distilled-squad";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "inputs": {
          "question": question,
          "context": "Provide a medically relevant response based on general health knowledge."
        },
        "parameters": {"max_answer_len": 50},
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String answer = data[0]["answer"];
      setState(() {
        chatMessages.add({"sender": "AI", "message": answer});
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.statusCode} - ${response.body}')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Chat Assistant'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final message = chatMessages[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: message["sender"] == "User"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: message["sender"] == "User"
                            ? Colors.green[200]
                            : Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message["message"]!,
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
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Ask a medical question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String userQuestion = _questionController.text.trim();
                    if (userQuestion.isNotEmpty) {
                      setState(() {
                        chatMessages.add({"sender": "User", "message": userQuestion});
                        _questionController.clear();
                      });
                      fetchMedicalResponse(userQuestion);
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
