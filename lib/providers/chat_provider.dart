import 'package:flutter/material.dart';
import 'package:gemini_chat_bot/constants.dart';
import 'package:gemini_chat_bot/hive/chat_history.dart';
import 'package:gemini_chat_bot/hive/settings.dart';
import 'package:gemini_chat_bot/hive/user_model.dart';
import 'package:gemini_chat_bot/model/message.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path;

class ChatProvider extends ChangeNotifier {
// List of messages
  List<Message> _inChatMessages = [];

// page controller
  final PageController _pageController = PageController();

// images file list
  List<XFile>? _imageFileList = [];

//index of the current screen
  int _currentScreenIndex = 0;

// initialize generative model
  GenerativeModel? _model;

  // initialize text model
  GenerativeModel? _textModel;

// initialize vision model
  GenerativeModel? _visionModel;

// current mode
  String _modelType = 'gemini_pro';

// loading bool
  bool _isLoading = false;

// getters
  List<Message> get inChatMessages => _inChatMessages;

  PageController get pageController => _pageController;

  List<XFile>? get imageFileList => _imageFileList;

  int get currentScreenIndex => _currentScreenIndex;

  GenerativeModel? get model => _model;

  GenerativeModel? get textModel => _textModel;

  GenerativeModel? get visionModel => _visionModel;

  String get modelType => _modelType;

  bool get isLoading => _isLoading;

// init Hive box
  static initHive() async {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.initFlutter(Constants.geminiDB);

    // register adapters
    if (Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());

      // open the chat history chat box
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }

    if (Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
      await Hive.openBox<UserModel>(Constants.userBox);
    }

    if (Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      await Hive.openBox<Settings>(Constants.settingBox);
    }
  }
}
