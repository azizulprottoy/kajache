class ServiceModel {
  final String id;
  final String title;
  final String category;
  final double rating;
  final int reviews;
  final double price;
  final String imageUrl;

  ServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.imageUrl,
  });
}