import 'package:flutter/material.dart';
import 'package:gemini_chat_bot/model/message.dart';
import 'package:gemini_chat_bot/providers/chat_provider.dart';
import 'package:gemini_chat_bot/widgets/assistant_message_widget.dart';
import 'package:gemini_chat_bot/widgets/my_message_widget.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({
    super.key,
    required this.scrollController,
    required this.chatProvider,
  });

  final ScrollController scrollController;
  final ChatProvider chatProvider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: chatProvider.inChatMessages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.inChatMessages[index];
        return message.role == Role.user
            ? MyMessageWidget(message: message)
            : AssistantMessageWidget(message: message.message.toString());
      },
    );
  }
}
