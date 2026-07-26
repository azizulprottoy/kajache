class CommentModel {
  final String id;
  final String service;
  final String name;
  final String propic;
  final String comment;
  final String status;
  final DateTime? createdAt;
  final List<ReplyModel> replies;

  CommentModel({
    required this.id,
    required this.service,
    required this.name,
    required this.propic,
    required this.comment,
    required this.status,
    this.createdAt,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id']?.toString() ?? '',
      service: json['service']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Anonymous',
      propic: json['propic']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      status: json['status']?.toString() ?? 'approved',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      replies: json['replies'] is List
          ? (json['replies'] as List)
              .map((e) => ReplyModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'service': service,
      'name': name,
      'propic': propic,
      'comment': comment,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      'replies': replies.map((e) => e.toJson()).toList(),
    };
  }
}

/// A reply nested under a [CommentModel].
///
/// Backend: POST /api/v1/comment/:id/reply
/// Shape: { _id, user, name, propic, reply, status, createdAt, updatedAt }
class ReplyModel {
  final String id;
  final String user;
  final String name;
  final String propic;
  final String reply;
  final String status;
  final DateTime? createdAt;

  ReplyModel({
    required this.id,
    required this.user,
    required this.name,
    required this.propic,
    required this.reply,
    required this.status,
    this.createdAt,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json['_id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Anonymous',
      propic: json['propic']?.toString() ?? '',
      reply: json['reply']?.toString() ?? '',
      status: json['status']?.toString() ?? 'approved',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'name': name,
      'propic': propic,
      'reply': reply,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
