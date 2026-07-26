/// A single service review.
///
/// Backend: GET /api/v1/review?serviceId=<id>
/// Shape: { _id, booking, service, employer, employerName, review, rating,
///          status, createdAt, updatedAt }
class ReviewModel {
  final String id;
  final String employerName;
  final String review;
  final double rating;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.employerName,
    required this.review,
    required this.rating,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final rawDate = json['createdAt']?.toString();
    if (rawDate != null && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate);
    }

    return ReviewModel(
      id: json['_id']?.toString() ?? '',
      employerName: json['employerName']?.toString() ?? 'Anonymous',
      review: json['review']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      createdAt: parsedDate,
    );
  }
}

/// Aggregated rating stats derived from a list of [ReviewModel].
///
/// `distribution` maps each star bucket (5 → 1) to how many reviews gave it,
/// so the UI can draw a per-star histogram like the app-store style summary.
class RatingSummary {
  final double average;
  final int total;
  final Map<int, int> distribution;

  const RatingSummary({
    required this.average,
    required this.total,
    required this.distribution,
  });

  factory RatingSummary.fromReviews(List<ReviewModel> reviews) {
    final counts = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    double sum = 0;

    for (final r in reviews) {
      sum += r.rating;
      // Round to the nearest whole star, clamped to the 1..5 buckets.
      final bucket = r.rating.round().clamp(1, 5);
      counts[bucket] = (counts[bucket] ?? 0) + 1;
    }

    final total = reviews.length;
    final average = total == 0 ? 0.0 : sum / total;

    return RatingSummary(
      average: average,
      total: total,
      distribution: counts,
    );
  }

  /// Fraction (0..1) of reviews that fall in [star], for the bar width.
  double fractionFor(int star) {
    if (total == 0) return 0;
    return (distribution[star] ?? 0) / total;
  }
}
