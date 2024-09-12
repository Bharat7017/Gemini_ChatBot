import 'dart:developer'; // Import the developer package for logging
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gemini_chat_bot/api/api_service.dart';
import 'package:gemini_chat_bot/constants.dart';
import 'package:gemini_chat_bot/hive/chat_history.dart';
import 'package:gemini_chat_bot/hive/settings.dart';
import 'package:gemini_chat_bot/hive/user_model.dart';
import 'package:gemini_chat_bot/model/message.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
// List of messages
  final List<Message> _inChatMessages = [];

// page controller
  final PageController _pageController = PageController();

// images file list
  List<XFile>? _imagesFileList = [];

//index of the current screen
  int _currentIndex = 0;

  //current chat id
  String _currentChatId = '';

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

  List<XFile>? get imagesFileList => _imagesFileList;

  int get currentScreenIndex => _currentIndex;

  String get currentChatId => _currentChatId;

  GenerativeModel? get model => _model;

  GenerativeModel? get textModel => _textModel;

  GenerativeModel? get visionModel => _visionModel;

  String get modelType => _modelType;

  bool get isLoading => _isLoading;

  // setters

  // set inchatmessages
  Future<void> setInChatMessages({required String chatId}) async {
    //get messages from hive database
    final messagesFromDB = await loadMessagesFromDB(chatId: chatId);

    for (var message in messagesFromDB) {
      if (_inChatMessages.contains(message)) {
        log('message already exist');
        continue;
      }
      _inChatMessages.add(message);
    }
    notifyListeners();
  }

  //load the messages from hive database
  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    // open the box of this chatID
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');

    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');

    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      final messageData = Message.fromMap(Map<String, dynamic>.from(message));
      return messageData;
    }).toList();
    notifyListeners();
    return newData;
  }

// set file list

  void setImageFileList(List<XFile> listValue) {
    _imagesFileList = listValue;
    notifyListeners();
  }

// set current module
  String setCurrentModel(String newModel) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  // functions to set the model based on bool - isTextOnly
  Future<void> setModel({required bool isTextOnly}) async {
    if (isTextOnly) {
      _model = _textModel ??
          GenerativeModel(
              model: setCurrentModel('gemini-pro'), apiKey: ApiService.apikey);
    } else {
      _model = _visionModel ??
          GenerativeModel(
              model: setCurrentModel('gemini-pro-vision'),
              apiKey: ApiService.apikey);
    }
    notifyListeners();
  }

// set current page id
  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  // set current chat Id

  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  //set lodading
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

// send message to gemini and get the streamed resposne
  Future<void> sentMessage(
      {required String message, required bool isTextOnly}) async {
// set the model
    await setModel(isTextOnly: isTextOnly);

    // set loading
    setLoading(value: true);

    // get the chatId
    String chatId = getChatId();

    // list of history messages
    List<Content> history = [];

    // get the chat history
    history = await getHistory(chatId: chatId);

    // get the ImagesUrls
    List<String> imagesUrls = getImagesUrls(isTextOnly: isTextOnly);

//user message
    final userMessage = Message(
      messageId: '',
      chatId: chatId,
      message: StringBuffer(message),
      role: Role.user,
      imagesUrls: imagesUrls,
      timeSent: DateTime.now(),
    );

// add this message to the list on inchatMessages
    _inChatMessages.add(userMessage);
    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }

    // send the message to the model wait for the respomnse
    await sendMessageAndWaitForResponse(
      message: message,
      chatId: chatId,
      history: history,
      isTextOnly: isTextOnly,
      userMessage: userMessage,
    );
  }

  // send the message to the model wait for the respomnse
  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required List<Content> history,
    required bool isTextOnly,
    required Message userMessage,
  }) async {
    final ChatSession = _model!.startChat(
      history: history.isEmpty || !isTextOnly ? null : history,
    );

    // get content
    final content = await getContent(message: message, isTextOnly: isTextOnly);

// assistant message
    final assistantMessage = userMessage.copyWith(
        role: Role.assistant,
        message: StringBuffer(),
        timeSent: DateTime.now());
  }

  Future<Content> getContent(
      {required message, required bool isTextOnly}) async {
    if (isTextOnly) {
      return Content.text(message);
    } else {
      //generate text from text only input
      final imageFutures = _imagesFileList
          ?.map((imageFIle) => imageFIle.readAsBytes())
          .toList(growable: false);
      final imageBytes = await Future.wait(imageFutures!);
      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpg', Uint8List.fromList(bytes)))
          .toList();
      return Content.model([prompt, ...imageParts]);
    }
  }

// get the ImagesUrls
  List<String> getImagesUrls({
    required bool isTextOnly,
  }) {
    List<String> imagesUrls = [];
    if (!isTextOnly && imagesFileList != null) {
      for (var image in imagesFileList!) {
        imagesUrls.add(image.path);
      }
    }
    return imagesUrls;
  }

  Future<List<Content>> getHistory({required String chatId}) async {
    List<Content> history = [];
    if (currentChatId.isNotEmpty) {
      await setInChatMessages(chatId: chatId);
      for (var message in _inChatMessages) {
        if (message.role == Role.user) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }
    return history;
  }

  String getChatId() {
    if (currentChatId.isEmpty) {
      return const Uuid().v4();
    } else {
      return currentChatId;
    }
  }

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
