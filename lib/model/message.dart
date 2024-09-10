class Message {
  String messageId;
  String chatId;
  Role role;
  StringBuffer message;
  List<String> imagesUrrls;
  DateTime timeSent;

// contructor
  Message({
    required this.messageId,
    required this.chatId,
    required this.role,
    required this.message,
    required this.imagesUrrls,
    required this.timeSent,
  });

  //toMap
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'role': role.index,
      'message': message.toString(),
      'imagesUrrls': imagesUrrls,
      'timeSent': timeSent.toIso8601String(),
    };
  }

// from map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'],
      chatId: map['chatId'],
      role: Role.values[map['role']],
      message: StringBuffer(map['message']),
      imagesUrrls: List<String>.from(map['imagesUrrls']),
      timeSent: DateTime.parse(map['timeSent']),
    );
  }

  // copyWith
  Message copyWith({
    String? messageId,
    String? chatId,
    Role? role,
    StringBuffer? message,
    List<String>? imagesUrrls,
    DateTime? timeSent,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      role: role ?? this.role,
      message: message ?? this.message,
      imagesUrrls: imagesUrrls ?? this.imagesUrrls,
      timeSent: timeSent ?? this.timeSent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.messageId == messageId;
  }

  @override
  int get hashCode {
    return messageId.hashCode;
  }
}

enum Role {
  user,
  assistant,
}
