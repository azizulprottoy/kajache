class FaqModel {
  final String id;
  final String question;
  final String questionBn;
  final String answer;
  final String answerBn;
  final int order;

  FaqModel({
    required this.id,
    required this.question,
    required this.questionBn,
    required this.answer,
    required this.answerBn,
    required this.order,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['_id']?.toString() ?? '',
      question: json['ques']?.toString() ?? '',
      questionBn: json['quesBn']?.toString() ?? '',
      answer: json['ans']?.toString() ?? '',
      answerBn: json['ansBn']?.toString() ?? '',
      order: int.tryParse(json['order']?.toString() ?? '0') ?? 0,
    );
  }

  String localizedQuestion(bool isBengali) =>
      isBengali && questionBn.isNotEmpty ? questionBn : question;

  String localizedAnswer(bool isBengali) =>
      isBengali && answerBn.isNotEmpty ? answerBn : answer;
}

class SupportTicketModel {
  final String id;
  final String title;
  final String reason;
  final String status;
  final String createdAt;

  SupportTicketModel({
    required this.id,
    required this.title,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
