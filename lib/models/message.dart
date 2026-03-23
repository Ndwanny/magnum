class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    required this.isRead,
  });
}

class ChatChannel {
  final String id;
  final String name;
  final String type; // 'team' | 'site' | 'direct'
  final List<ChatMessage> messages;
  final int unread;

  const ChatChannel({
    required this.id,
    required this.name,
    required this.type,
    required this.messages,
    required this.unread,
  });
}
