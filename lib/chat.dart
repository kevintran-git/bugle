import 'dart:convert';
import 'dart:math';

import 'package:bugle/api/palm_api.dart';
import 'package:bugle/firebase/firestore.dart';
import 'package:bugle/models/data_models.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// class ChatWidget extends StatefulWidget {
//   const ChatWidget({Key? key}) : super(key: key);
//   static const routeName = '/chat';

//   @override
//   State<ChatWidget> createState() => _ChatWidgetState();
// }

// class _ChatWidgetState extends State<ChatWidget> {
//   @override
//   void initState() {
//     super.initState();
//     OpenAI.apiKey = const String.fromEnvironment("OPENAI_KEY");
//   }

//   String randomString() {
//     final random = Random.secure();
//     final values = List<int>.generate(16, (i) => random.nextInt(255));
//     return base64UrlEncode(values);
//   }

//   final List<types.TextMessage> _messages = [];
//   final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
//   final _bot = const types.User(id: 'f6d7f1c0-3b9b-4b4f-8f0a-0e4f9aefbbd8');

//   @override
//   Widget build(BuildContext context) {
//     final ColorScheme themeColors = Theme.of(context).colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text('When am I free?'),
//       ),
//       body: Chat(
//         messages: _messages,
//         onSendPressed: _handleSendPressed,
//         user: _user,
//         //bubbleBuilder: _buildMessage,
//         theme: DefaultChatTheme(
//           inputBackgroundColor: themeColors.secondaryContainer,
//           inputTextColor: themeColors.onSecondaryContainer,
//           primaryColor: themeColors.primary,
//           backgroundColor: themeColors.background,
//         ),
//       ),
//     );
//   }

//   void _addMessage(types.TextMessage message) {
//     setState(() {
//       _messages.insert(0, message);
//     });
//   }

//   Future<void> _handleSendPressed(types.PartialText message) async {
//     final textMessage = types.TextMessage(
//       author: _user,
//       createdAt: DateTime.now().millisecondsSinceEpoch,
//       id: randomString(),
//       text: message.text,
//     );

//     _addMessage(textMessage);
//     var chatbotResponse = await sendToGPT(message.text);

//     _addMessage(types.TextMessage(
//       author: _bot,
//       createdAt: DateTime.now().millisecondsSinceEpoch,
//       id: randomString(),
//       text: chatbotResponse,
//     ));
//   }

//   Future<String> sendToGPT(String message) async {
//     // create a queue of chat choices and add the last 15 messages in _messages into it. if there were less than 15 messages, add all of them.
//     List<OpenAIChatCompletionChoiceMessageModel> previousMessages = [];
//     for (int i = min(15, _messages.length - 1); i >= 0; i--) {
//       previousMessages.add(OpenAIChatCompletionChoiceMessageModel(
//         content: _messages[i].text,
//         role: _messages[i].author.id == _user.id
//             ? OpenAIChatMessageRole.user
//             : OpenAIChatMessageRole.assistant,
//       ));
//     }
//     OpenAIChatCompletionModel chatCompletion =
//         await OpenAI.instance.chat.create(
//       model: "gpt-3.5-turbo",
//       messages: [
//         const OpenAIChatCompletionChoiceMessageModel(
//           content:
//               """You are an executive assistant helping your boss schedule an event. Your goal is to produce a list of times that work. Output the options in markdown. Your boss has limitations on their schedule, including existing calendar events and busy preferences. When you schedule, make sure you are cognizant of their limited availabilities — so schedule thoughtfully! Thankfully, you are a world class executive assistant, so you are sure to schedule smartly. Here’s an example of the output you might generate:

// 'Here are times that work for you based on your preferences:

// - Monday, May 15, 12 pm - 12:30 pm
// - Tuesday, May 18, 2 pm - 2:40 pm

// 'Make sure you always provide the day of the week, date, then times in the format above. Today, the boss has given you this query to schedule. They have this calendar for the next week. And, they prefer that you respect these constraints on their schedule. Output a list of possible times.""",
//           role: OpenAIChatMessageRole.system,
//         ),
//         ...previousMessages,
//       ],
//     );

//     if (kDebugMode) {
//       print(chatCompletion.choices.first.message.content);
//     }

//     return chatCompletion.choices.first.message.content;
//   }

//   Future<String> sendToPaLM(String message) async {
//     // Create a sample prompt using the Prompt class
//     PaLMPrompt samplePrompt = PaLMPrompt(
//         context: "",
//         //"You are a secretary robot that can help people schedule meetings. Your goal is to produce a list of times that work. Try not to ask for unnecessary information.",
//         //"You are a secretary robot that can help people schedule meetings. Your goal is to produce a list of times that work. Try not to ask for unnecessary information.",
//         examples: {},
//         messages: [...(_messages.reversed.map((e) => e.text).toList())],
//         temperature: 0.25,
//         topK: 40,
//         topP: 0.95,
//         candidateCount: 1);

//     return await PaLM().generateMessage(samplePrompt);
//   }
// }

// class BubbleWidget extends StatefulWidget {
//   final Widget child;
//   final types.TextMessage message;
//   final bool nextMessageInGroup;
//   final types.User user;

//   const BubbleWidget({
//     Key? key,
//     required this.child,
//     required this.message,
//     required this.nextMessageInGroup,
//     required this.user,
//   }) : super(key: key);

//   @override
//   State<BubbleWidget> createState() => _BubbleWidgetState();
// }

// class _BubbleWidgetState extends State<BubbleWidget> {
//   bool _isChecked = false;

//   @override
//   Widget build(BuildContext context) {
//     final isUserMessage = widget.message.author.id == widget.user.id;
//     final colorScheme = Theme.of(context).colorScheme;
//     final borderRadius = BorderRadius.circular(20);
//     final color = isUserMessage ? colorScheme.primary : colorScheme.secondary;

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: borderRadius,
//         color: color,
//       ),
//       margin: const EdgeInsets.all(4),
//       padding: const EdgeInsets.all(8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           widget.child,
//           // your existing child widget
//           Checkbox(
//             value: _isChecked,
//             onChanged: (bool? value) {
//               setState(() {
//                 _isChecked = value!;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

class ChatFriendWidget extends StatefulWidget {
  const ChatFriendWidget({Key? key}) : super(key: key);
  static const routeName = '/friendchat';

  @override
  State<ChatFriendWidget> createState() => _ChatFriendWidgetState();
}

class _ChatFriendWidgetState extends State<ChatFriendWidget> {
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

  var mySchedule = "";
  var friendsSchedule = "";

  @override
  Widget build(BuildContext context) {
    final friend = ModalRoute.of(context)!.settings.arguments as UserDataModel?;
    if (friend == null) {
      Navigator.pop(context);
      return Container(); // Return empty widget.
    }
    final ColorScheme themeColors = Theme.of(context).colorScheme;

    final database = Provider.of<FirestoreDatabase>(context, listen: false);
    fetchSchedules(database, friend);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
            "Schedule with ${friend.displayName}"), // this will be the title on top
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        //bubbleBuilder: _buildMessage,
        theme: DefaultChatTheme(
          inputBackgroundColor: themeColors.secondaryContainer,
          inputTextColor: themeColors.onSecondaryContainer,
          primaryColor: themeColors.primary,
          backgroundColor: themeColors.background,
        ),
      ),
    );
  }

  void fetchSchedules(
      FirestoreDatabase database, UserDataModel myFriend) async {
    var myUser = await database.getUser();
    mySchedule = myUser.availability;
    friendsSchedule = myFriend.availability;
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
    var chatbotResponse = await sendToGPT();

    _addMessage(types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: chatbotResponse,
    ));
  }

  Future<String> sendToGPT() async {
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

    print("My schedule: $mySchedule");
    print("Friend's schedule: $friendsSchedule");

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content:
              """You are an executive assistant helping your boss schedule an event. Your goal is to produce a list of times that work. Output the options in markdown. Your boss has limitations on their schedule, including existing calendar events and busy preferences. When you schedule, make sure you are cognizant of their limited availabilities — so schedule thoughtfully! Thankfully, you are a world class executive assistant, so you are sure to schedule smartly. Here’s an example of the output you might generate:

'Here are times that work for you based on your preferences:

- Monday, May 15, 12 pm - 12:30 pm
- Tuesday, May 18, 2 pm - 2:40 pm

'Make sure you always provide the day of the week, date, then times in the format above. Today, the boss has given you this query to schedule. They have this calendar for the next week: $mySchedule.

Here is their friend's calendar for the next week: $friendsSchedule.

Output a list of possible times. Here's their request for the event below.""",
          role: OpenAIChatMessageRole.system,
        ),
        ...previousMessages,
      ],
    );

    if (kDebugMode) {
      print(chatCompletion.choices.first.message.content);
    }

    return chatCompletion.choices.first.message.content;
  }

  Future<String> sendToPaLM(String message) async {
    // Create a sample prompt using the Prompt class
    PaLMPrompt samplePrompt = PaLMPrompt(
        context: "",
        //"You are a secretary robot that can help people schedule meetings. Your goal is to produce a list of times that work. Try not to ask for unnecessary information.",
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
