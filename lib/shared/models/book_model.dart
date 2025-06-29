class BookModel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String isbn;
  final String category;
  final String? coverImageUrl;
  final String status;
  final DateTime publishedDate;
  final DateTime addedAt;
  final int totalCopies;
  final int availableCopies;
  final double rating;
  final List<String> tags;
  final String? addedBy;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.isbn,
    required this.category,
    this.coverImageUrl,
    required this.status,
    required this.publishedDate,
    required this.addedAt,
    required this.totalCopies,
    required this.availableCopies,
    this.rating = 0.0,
    this.tags = const [],
    this.addedBy,
  });

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      isbn: map['isbn'] ?? '',
      category: map['category'] ?? '',
      coverImageUrl: map['coverImageUrl'],
      status: map['status'] ?? 'available',
      publishedDate: DateTime.fromMillisecondsSinceEpoch(map['publishedDate'] ?? 0),
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] ?? 0),
      totalCopies: map['totalCopies'] ?? 1,
      availableCopies: map['availableCopies'] ?? 1,
      rating: (map['rating'] ?? 0.0).toDouble(),
      tags: List<String>.from(map['tags'] ?? []),
      addedBy: map['addedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'isbn': isbn,
      'category': category,
      'coverImageUrl': coverImageUrl,
      'status': status,
      'publishedDate': publishedDate.millisecondsSinceEpoch,
      'addedAt': addedAt.millisecondsSinceEpoch,
      'totalCopies': totalCopies,
      'availableCopies': availableCopies,
      'rating': rating,
      'tags': tags,
      'addedBy': addedBy,
    };
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? isbn,
    String? category,
    String? coverImageUrl,
    String? status,
    DateTime? publishedDate,
    DateTime? addedAt,
    int? totalCopies,
    int? availableCopies,
    double? rating,
    List<String>? tags,
    String? addedBy,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      isbn: isbn ?? this.isbn,
      category: category ?? this.category,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      status: status ?? this.status,
      publishedDate: publishedDate ?? this.publishedDate,
      addedAt: addedAt ?? this.addedAt,
      totalCopies: totalCopies ?? this.totalCopies,
      availableCopies: availableCopies ?? this.availableCopies,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      addedBy: addedBy ?? this.addedBy,
    );
  }

  bool get isAvailable => availableCopies > 0 && status == 'available';
}
