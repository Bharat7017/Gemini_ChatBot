import 'package:gemini_chat_bot/constants.dart';
import 'package:gemini_chat_bot/hive/chat_history.dart';
import 'package:gemini_chat_bot/hive/settings.dart';
import 'package:gemini_chat_bot/hive/user_model.dart';
import 'package:hive/hive.dart';

class Boxes {
  // get the caht history box
  static Box<ChatHistory> getChatHistory() =>
      Hive.box<ChatHistory>(Constants.chatHistoryBox);

  // get user box
  static Box<UserModel> getUser() => Hive.box<UserModel>(Constants.userBox);

  // get settings box
  static Box<Settings> getSettings() =>
      Hive.box<Settings>(Constants.settingsBox);
}
