import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gemini_chat_bot/providers/chat_provider.dart';
import 'package:gemini_chat_bot/utils/utilities.dart';
import 'package:gemini_chat_bot/widgets/preview_images_widget.dart';
import 'package:image_picker/image_picker.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({super.key, required this.chatProvider});

  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  //controller of the inpur field
  final TextEditingController textController = TextEditingController();

  //focus node of the input field
  final FocusNode textFieldFocus = FocusNode();

// initialize image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    textController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage(
      {required String message,
      required ChatProvider chatProvider,
      required bool isTextOnly}) async {
    try {
      await chatProvider.sentMessage(message: message, isTextOnly: isTextOnly);
    } catch (e) {
      log('error : $e');
    } finally {
      textController.clear();
      widget.chatProvider.setImagesFileList(listValue: []);
      textFieldFocus.unfocus();
    }
  }

//picker image
  void pickImage() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      widget.chatProvider.setImagesFileList(listValue: pickedImages);
    } catch (e) {
      log('error : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages = widget.chatProvider.imagesFileList != null &&
        widget.chatProvider.imagesFileList!.isNotEmpty;

    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border:
              Border.all(color: Theme.of(context).textTheme.titleLarge!.color!),
        ),
        child: Column(
          children: [
            if (hasImages) const PreviewImagesWidget(),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // pick image from gallery
                    if (hasImages) {
                      showMyAnimatedDialog(
                          context: context,
                          title: 'Delete Image',
                          content:
                              'Are you sure you want to delete the images?',
                          actionText: 'Delete',
                          onActionPressed: (value) {
                            if (value) {
                              widget.chatProvider
                                  .setImagesFileList(listValue: []);
                            }
                          });
                    } else {
                      pickImage();
                    }
                  },
                  icon: Icon(hasImages ? Icons.delete_forever : Icons.image),
                ),
                Expanded(
                  child: TextField(
                    focusNode: textFieldFocus,
                    controller: textController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (String value) {
                      if (value.isNotEmpty) {
                        sendChatMessage(
                          message: textController.text,
                          chatProvider: widget.chatProvider,
                          isTextOnly: hasImages ? false : true,
                        );
                      }
                    },
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
                    if (textController.text.isNotEmpty) {
                      sendChatMessage(
                        message: textController.text,
                        chatProvider: widget.chatProvider,
                        isTextOnly: hasImages ? false : true,
                      );
                    }
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
            ),
          ],
        ));
  }
}
