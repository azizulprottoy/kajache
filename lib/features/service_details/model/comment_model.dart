class CommentModel {
  final String id;
  final String service;
  final String name;
  final String propic;
  final String comment;
  final String status;
  final DateTime? createdAt;

  CommentModel({
    required this.id,
    required this.service,
    required this.name,
    required this.propic,
    required this.comment,
    required this.status,
    this.createdAt,
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
    };
  }
}
