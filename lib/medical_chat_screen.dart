import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MedicalChatScreen extends StatefulWidget {
  const MedicalChatScreen({super.key});

  @override
  _MedicalChatScreenState createState() => _MedicalChatScreenState();
}

class _MedicalChatScreenState extends State<MedicalChatScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, String>> chatMessages = [];
  bool isLoading = false;
  final String apiKey = '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';
  final Logger _logger = Logger('MedicalChatScreen');
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _setupLogger();
  }

  void _setupLogger() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<void> sendErrorLogByEmail(String error) async {
    String username = 'abramwel3@gmail.com';
    String password = 'bmbr cuvt zmjp rnsm';

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Medical Chat App')
      ..recipients.add('bramwela8@gmail.com')
      ..subject = 'Error Log from Medical Chat App'
      ..text = error;

    try {
      await send(message, smtpServer);
      print('Error log sent via email.');
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  Future<void> fetchMedicalResponse(String question) async {
    setState(() {
      isLoading = true;
    });

    _loadingTimer = Timer(const Duration(seconds: 10), () {
      if (isLoading) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request timed out. Please try again.')),
        );
        _logger.warning('Request timed out.');
      }
    });

    final url = "https://api-inference.huggingface.co/models/distilbert-base-uncased-distilled-squad";
    try {
      final response = await http
          .post(
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
          )
          .timeout(const Duration(seconds: 10));

      // Cancel the timer if the response is received within time
      _loadingTimer?.cancel();

      _logger.info('Response status: ${response.statusCode}');
      _logger.info('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String answer = data[0]["answer"];
        setState(() {
          chatMessages.add({"sender": "AI", "message": answer});
        });
        _logger.info('Received response: $answer');
      } else {
        final errorLog = 'Error: ${response.statusCode} - ${response.body}';
        _logger.severe(errorLog);
        sendErrorLogByEmail(errorLog);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorLog)),
        );
      }
    } catch (e) {
      final errorLog = 'Exception occurred: $e';
      _logger.severe(errorLog);
      sendErrorLogByEmail(errorLog);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Chat Assistant'),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: message["sender"] == "User"
                            ? Colors.green[200]
                            : Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message["message"]!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
