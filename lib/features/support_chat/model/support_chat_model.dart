class SupportChatMessageModel {
  final String id;
  final String sender; // 'user' | 'admin'
  final String message;
  final bool read;
  final DateTime? createdAt;

  SupportChatMessageModel({
    required this.id,
    required this.sender,
    required this.message,
    required this.read,
    this.createdAt,
  });

  bool get isMine => sender == 'user';

  factory SupportChatMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportChatMessageModel(
      id: json['_id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? 'admin',
      message: json['message']?.toString() ?? '',
      read: json['read'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
