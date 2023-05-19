import 'dart:convert';
import 'dart:math';

import 'package:bugle/palm_api.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter/material.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {

  @override
  void initState() {
    super.initState();
    OpenAI.apiKey = const String.fromEnvironment("OPENAI_KEY");
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  final List<types.TextMessage> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  final _bot = const types.User(id: 'f6d7f1c0-3b9b-4b4f-8f0a-0e4f9aefbbd8');

  @override
  Widget build(BuildContext context) {
    final ColorScheme themeColors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        theme: DefaultChatTheme(
          inputBackgroundColor: themeColors.secondaryContainer,
          inputTextColor: themeColors.onSurface,
          primaryColor: themeColors.primary,
        ),
      ),
    );
  }

  void _addMessage(types.TextMessage message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);
    var chatbotResponse = await sendToGPT(message.text);
    
    _addMessage(types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(), // TODO: Replace with UID
      text: chatbotResponse,
    ));
  }

  Future<String> sendToGPT(String message) async {
    // create a queue of chat choices and add the last 15 messages in _messages into it. if there were less than 15 messages, add all of them.
    List<OpenAIChatCompletionChoiceMessageModel> previousMessages = [];
    for (int i = min(15, _messages.length - 1); i >= 0; i--) {
      previousMessages.add(OpenAIChatCompletionChoiceMessageModel(
        content: _messages[i].text,
        role: _messages[i].author.id == _user.id
            ? OpenAIChatMessageRole.user
            : OpenAIChatMessageRole.assistant,
      ));
    }

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        const OpenAIChatCompletionChoiceMessageModel(
          content:
              "You are a secretary robot that can help people schedule meetings. Your goal is to produce a list of times that work.", // TODO: Prompt engineer this!
          role: OpenAIChatMessageRole.system,
        ),
        ...previousMessages,
      ],
    );

    return chatCompletion.choices.first.message.content;
  }

  Future<String> sendToPaLM(String message) async {
    // Create a sample prompt using the Prompt class
    PaLMPrompt samplePrompt = PaLMPrompt(
        context: "",
            //"You are a secretary robot that can help people schedule meetings. Your goal is to produce a list of times that work. Try not to ask for unnecessary information.",
        examples: {},
        messages: [...(_messages.reversed.map((e) => e.text).toList())],
        temperature: 0.25,
        topK: 40,
        topP: 0.95,
        candidateCount: 1);

    return await PaLM().generateMessage(samplePrompt);
  }
}
