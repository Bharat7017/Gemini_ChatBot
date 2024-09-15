import 'package:flutter/material.dart';
import 'package:gemini_chat_bot/providers/chat_provider.dart';
import 'package:gemini_chat_bot/widgets/bottom_chat_field.dart';
import 'package:gemini_chat_bot/widgets/chat_messages.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      if (chatProvider.inChatMessages.isNotEmpty) {
        _scrollToBottom();
      }

      // auto scroll to bottom on new message
      chatProvider.addListener(() {
        if (chatProvider.inChatMessages.isNotEmpty) {
          _scrollToBottom();
        }
      });

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          centerTitle: true,
          title: const Text('Chat with Gemini'),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: chatProvider.inChatMessages.isEmpty
                    ? const Center(
                        child: Text('No messages yet'),
                      )
                    : ChatMessages(
                        scrollController: _scrollController,
                        chatProvider: chatProvider,
                      ),
              ),
              BottomChatField(
                chatProvider: chatProvider,
              )
            ],
          ),
        )),
      );
    });
  }
}
