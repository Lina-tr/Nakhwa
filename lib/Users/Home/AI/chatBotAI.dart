import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:nakhwa/config/config.dart';

class DisasterChatbotPage extends StatefulWidget {
  const DisasterChatbotPage({super.key});

  @override
  State<DisasterChatbotPage> createState() => _DisasterChatbotPageState();
}

class _DisasterChatbotPageState extends State<DisasterChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Available Gemini models
  String _selectedModel = 'gemini-2.0-flash'; // Default model

  late GenerativeModel _model;
  late ChatSession _chatSession;

  final String _apiKey = 'AIzaSyBGsQdd7k4x96lN9AZh9fSdVS5PHlwZyqA';

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: _selectedModel,
      apiKey: _apiKey,
      systemInstruction: Content.text(
        'أنت مساعد ذكي متخصص في الكوارث الطبيعية والطوارئ. '
        'تقدم معلومات دقيقة ومفيدة حول الاستعداد للكوارث، والسلامة، والإسعافات الأولية. '
        'اجب باللغة العربية دائماً وكن مفيداً ومتفهماً.',
      ),
    );

    // Start a new chat session
    _chatSession = _model.startChat();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'user': text});
      _controller.clear();
      _isLoading = true;
    });

    try {
      String? botResponse;
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          // Send message to the chat session
          final response = await _chatSession.sendMessage(Content.text(text));

          botResponse = response.text ?? 'تعذر الحصول على الرد.';
          break; // Success, exit retry loop
        } catch (e) {
          retryCount++;
          print('Attempt $retryCount failed: $e');

          if (retryCount >= maxRetries) {
            if (e.toString().contains('503')) {
              botResponse = 'الخدمة غير متاحة حالياً. يرجى المحاولة لاحقاً.';
            } else if (e.toString().contains('429')) {
              botResponse =
                  'تم تجاوز الحد المسموح من الطلبات. يرجى الانتظار قليلاً.';
            } else if (e.toString().contains('401')) {
              botResponse = 'خطأ في مفتاح API. يرجى التحقق من صحة المفتاح.';
            } else {
              botResponse = 'حدث خطأ: ${e.toString()}';
            }
          } else {
            // Wait before retrying (exponential backoff)
            await Future.delayed(Duration(seconds: retryCount * 2));
          }
        }
      }

      setState(() {
        _messages.add({'bot': botResponse!});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'bot': 'حدث خطأ غير متوقع: ${e.toString()}'});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مساعد الكوارث الطبيعية',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Nakhwa.background,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white24, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'اسأل عن أي شيء متعلق بالكوارث الطبيعية',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg.containsKey('user');
                      return Align(
                        alignment: isUser == true
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser == true
                                ? Colors.blue
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            msg[isUser == true ? 'user' : 'bot']!,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading == true)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'جاري الكتابة...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'اكتب سؤالك حول الكوارث...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),

                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _isLoading ? Colors.grey : Nakhwa.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading == true ? null : _sendMessage,
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
