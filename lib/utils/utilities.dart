// animated dialog
import 'package:flutter/material.dart';

void showMyAnimatedDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String actionText,
  required Function(bool) onActionPressed,
}) async {
  showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, seconderyAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, seconderyAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              title: Column(
                children: [
                  const Text(
                    "Alert!!!",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: Text(
                content,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    onActionPressed(false);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onActionPressed(true);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    actionText,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      });
}
