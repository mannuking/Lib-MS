class BorrowedBookModel {
  final String id;
  final String userId;
  final String bookId;
  final String userName;
  final String bookTitle;
  final String bookAuthor;
  final String? bookCoverUrl;
  final DateTime borrowedDate;
  final DateTime dueDate;
  final DateTime? returnedDate;
  final String status;
  final double? fineAmount;

  BorrowedBookModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.userName,
    required this.bookTitle,
    required this.bookAuthor,
    this.bookCoverUrl,
    required this.borrowedDate,
    required this.dueDate,
    this.returnedDate,
    required this.status,
    this.fineAmount,
  });

  factory BorrowedBookModel.fromMap(Map<String, dynamic> map) {
    return BorrowedBookModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      bookId: map['bookId'] ?? '',
      userName: map['userName'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      bookAuthor: map['bookAuthor'] ?? '',
      bookCoverUrl: map['bookCoverUrl'],
      borrowedDate: DateTime.fromMillisecondsSinceEpoch(map['borrowedDate'] ?? 0),
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] ?? 0),
      returnedDate: map['returnedDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['returnedDate'])
          : null,
      status: map['status'] ?? 'borrowed',
      fineAmount: map['fineAmount']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookId': bookId,
      'userName': userName,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookCoverUrl': bookCoverUrl,
      'borrowedDate': borrowedDate.millisecondsSinceEpoch,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'returnedDate': returnedDate?.millisecondsSinceEpoch,
      'status': status,
      'fineAmount': fineAmount,
    };
  }

  BorrowedBookModel copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? userName,
    String? bookTitle,
    String? bookAuthor,
    String? bookCoverUrl,
    DateTime? borrowedDate,
    DateTime? dueDate,
    DateTime? returnedDate,
    String? status,
    double? fineAmount,
  }) {
    return BorrowedBookModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      userName: userName ?? this.userName,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookCoverUrl: bookCoverUrl ?? this.bookCoverUrl,
      borrowedDate: borrowedDate ?? this.borrowedDate,
      dueDate: dueDate ?? this.dueDate,
      returnedDate: returnedDate ?? this.returnedDate,
      status: status ?? this.status,
      fineAmount: fineAmount ?? this.fineAmount,
    );
  }

  bool get isOverdue => DateTime.now().isAfter(dueDate) && status == 'borrowed';
  int get daysOverdue => isOverdue ? DateTime.now().difference(dueDate).inDays : 0;
}
