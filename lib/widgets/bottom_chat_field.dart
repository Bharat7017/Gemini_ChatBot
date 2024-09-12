import 'package:flutter/material.dart';
import 'package:gemini_chat_bot/providers/chat_provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({super.key, required this.chatProvider});

  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  //controller of the inpur field
  final TextEditingController _messageController = TextEditingController();

  //focus node of the input field
  final FocusNode textFieldFocus = FocusNode();

  @override
  // void initSateState() {
  //   super.initState();
  // }

  void dispose() {
    _messageController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border:
              Border.all(color: Theme.of(context).textTheme.titleLarge!.color!),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                // pick image from gallery
              },
              icon: const Icon(Icons.image),
            ),
            Expanded(
              child: TextField(
                focusNode: textFieldFocus,
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: (String value) {},
                decoration: const InputDecoration.collapsed(
                    hintText: 'Enter a prompt...',
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    )),
              ),
            ),
            GestureDetector(
              onTap: () {
                // send the messgae
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.all(5.0),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
