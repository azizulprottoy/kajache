class BookingChatMessageModel {
  final String id;
  final String bidId;
  final String senderId;
  final String senderUsername;
  final String content;
  final bool isSystemMessage;
  final DateTime? createdAt;

  BookingChatMessageModel({
    required this.id,
    required this.bidId,
    required this.senderId,
    required this.senderUsername,
    required this.content,
    required this.isSystemMessage,
    this.createdAt,
  });

  factory BookingChatMessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    final senderIsMap = sender is Map;
    return BookingChatMessageModel(
      id: json['_id']?.toString() ?? '',
      bidId: json['bid']?.toString() ?? '',
      senderId: senderIsMap
          ? (sender['_id']?.toString() ?? '')
          : (sender?.toString() ?? ''),
      senderUsername: senderIsMap ? (sender['username']?.toString() ?? '') : '',
      content: json['content']?.toString() ?? '',
      isSystemMessage: json['isSystemMessage'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
