class BookDetailsRecommendation {
  const BookDetailsRecommendation({
    required this.title,
    required this.author,
    this.coverUrl,
  });

  final String title;
  final String author;
  final String? coverUrl;
}
