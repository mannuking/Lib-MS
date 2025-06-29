import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:library_management_system/shared/models/book_model.dart';
import 'package:library_management_system/shared/models/borrowed_book_model.dart';
import 'package:library_management_system/core/constants/app_constants.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Add a new book
  Future<void> addBook({
    required BookModel book,
    File? coverImage,
  }) async {
    try {
      String? coverImageUrl;
      
      if (coverImage != null) {
        coverImageUrl = await _uploadCoverImage(book.id, coverImage);
      }

      final bookWithImage = book.copyWith(coverImageUrl: coverImageUrl);
      
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(book.id)
          .set(bookWithImage.toMap());
    } catch (e) {
      throw Exception('Failed to add book: ${e.toString()}');
    }
  }

  // Get all books
  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection(AppConstants.booksCollection)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromMap(doc.data()))
            .toList());
  }

  // Get books by category
  Stream<List<BookModel>> getBooksByCategory(String category) {
    return _firestore
        .collection(AppConstants.booksCollection)
        .where('category', isEqualTo: category)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromMap(doc.data()))
            .toList());
  }

  // Search books
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      final results = await _firestore
          .collection(AppConstants.booksCollection)
          .get();

      final books = results.docs
          .map((doc) => BookModel.fromMap(doc.data()))
          .where((book) =>
              book.title.toLowerCase().contains(query.toLowerCase()) ||
              book.author.toLowerCase().contains(query.toLowerCase()) ||
              book.category.toLowerCase().contains(query.toLowerCase()) ||
              book.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .toList();

      return books;
    } catch (e) {
      throw Exception('Failed to search books: ${e.toString()}');
    }
  }

  // Update book
  Future<void> updateBook({
    required BookModel book,
    File? newCoverImage,
  }) async {
    try {
      String? coverImageUrl = book.coverImageUrl;
      
      if (newCoverImage != null) {
        // Delete old image if exists
        if (coverImageUrl != null) {
          await _deleteCoverImage(coverImageUrl);
        }
        // Upload new image
        coverImageUrl = await _uploadCoverImage(book.id, newCoverImage);
      }

      final updatedBook = book.copyWith(coverImageUrl: coverImageUrl);
      
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(book.id)
          .update(updatedBook.toMap());
    } catch (e) {
      throw Exception('Failed to update book: ${e.toString()}');
    }
  }

  // Delete book
  Future<void> deleteBook(String bookId) async {
    try {
      // Get book to delete cover image
      final bookDoc = await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .get();

      if (bookDoc.exists) {
        final book = BookModel.fromMap(bookDoc.data()!);
        
        // Delete cover image if exists
        if (book.coverImageUrl != null) {
          await _deleteCoverImage(book.coverImageUrl!);
        }
        
        // Delete book document
        await _firestore
            .collection(AppConstants.booksCollection)
            .doc(bookId)
            .delete();
      }
    } catch (e) {
      throw Exception('Failed to delete book: ${e.toString()}');
    }
  }

  // Borrow book
  Future<void> borrowBook({
    required String userId,
    required String userName,
    required BookModel book,
  }) async {
    try {
      // Create borrowed book record
      final borrowedBook = BorrowedBookModel(
        id: _uuid.v4(),
        userId: userId,
        bookId: book.id,
        userName: userName,
        bookTitle: book.title,
        bookAuthor: book.author,
        bookCoverUrl: book.coverImageUrl,
        borrowedDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 14)), // 2 weeks
        status: 'borrowed',
      );

      // Add to borrowed books collection
      await _firestore
          .collection(AppConstants.borrowedBooksCollection)
          .doc(borrowedBook.id)
          .set(borrowedBook.toMap());

      // Update book availability
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(book.id)
          .update({
        'availableCopies': book.availableCopies - 1,
        'status': book.availableCopies - 1 > 0 ? 'available' : 'borrowed',
      });
    } catch (e) {
      throw Exception('Failed to borrow book: ${e.toString()}');
    }
  }

  // Return book
  Future<void> returnBook(String borrowedBookId) async {
    try {
      final borrowedBookDoc = await _firestore
          .collection(AppConstants.borrowedBooksCollection)
          .doc(borrowedBookId)
          .get();

      if (borrowedBookDoc.exists) {
        final borrowedBook = BorrowedBookModel.fromMap(borrowedBookDoc.data()!);
        
        // Update borrowed book status
        await _firestore
            .collection(AppConstants.borrowedBooksCollection)
            .doc(borrowedBookId)
            .update({
          'returnedDate': DateTime.now().millisecondsSinceEpoch,
          'status': 'returned',
        });

        // Get book and update availability
        final bookDoc = await _firestore
            .collection(AppConstants.booksCollection)
            .doc(borrowedBook.bookId)
            .get();

        if (bookDoc.exists) {
          final book = BookModel.fromMap(bookDoc.data()!);
          await _firestore
              .collection(AppConstants.booksCollection)
              .doc(book.id)
              .update({
            'availableCopies': book.availableCopies + 1,
            'status': 'available',
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to return book: ${e.toString()}');
    }
  }

  // Get user's borrowed books
  Stream<List<BorrowedBookModel>> getUserBorrowedBooks(String userId) {
    return _firestore
        .collection(AppConstants.borrowedBooksCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('borrowedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BorrowedBookModel.fromMap(doc.data()))
            .toList());
  }

  // Get all borrowed books (for admin)
  Stream<List<BorrowedBookModel>> getAllBorrowedBooks() {
    return _firestore
        .collection(AppConstants.borrowedBooksCollection)
        .orderBy('borrowedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BorrowedBookModel.fromMap(doc.data()))
            .toList());
  }

  // Add to favorites
  Future<void> addToFavorites(String userId, String bookId) async {
    try {
      await _firestore
          .collection(AppConstants.favoritesCollection)
          .doc('${userId}_$bookId')
          .set({
        'userId': userId,
        'bookId': bookId,
        'addedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to add to favorites: ${e.toString()}');
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String userId, String bookId) async {
    try {
      await _firestore
          .collection(AppConstants.favoritesCollection)
          .doc('${userId}_$bookId')
          .delete();
    } catch (e) {
      throw Exception('Failed to remove from favorites: ${e.toString()}');
    }
  }

  // Get user's favorite books
  Stream<List<BookModel>> getUserFavoriteBooks(String userId) {
    return _firestore
        .collection(AppConstants.favoritesCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final bookIds = snapshot.docs.map((doc) => doc.data()['bookId'] as String).toList();
      
      if (bookIds.isEmpty) return <BookModel>[];
      
      final books = <BookModel>[];
      for (final bookId in bookIds) {
        final bookDoc = await _firestore
            .collection(AppConstants.booksCollection)
            .doc(bookId)
            .get();
        
        if (bookDoc.exists) {
          books.add(BookModel.fromMap(bookDoc.data()!));
        }
      }
      
      return books;
    });
  }

  // Check if book is in favorites
  Future<bool> isBookInFavorites(String userId, String bookId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.favoritesCollection)
          .doc('${userId}_$bookId')
          .get();
      
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Upload cover image
  Future<String> _uploadCoverImage(String bookId, File imageFile) async {
    try {
      final ref = _storage.ref().child('${AppConstants.bookCoversPath}/$bookId.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload cover image: ${e.toString()}');
    }
  }

  // Delete cover image
  Future<void> _deleteCoverImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore errors when deleting images
    }
  }
}

// Providers
final bookServiceProvider = Provider<BookService>((ref) => BookService());

final allBooksProvider = StreamProvider<List<BookModel>>((ref) {
  final bookService = ref.watch(bookServiceProvider);
  return bookService.getAllBooks();
});

final userBorrowedBooksProvider = StreamProvider.family<List<BorrowedBookModel>, String>((ref, userId) {
  final bookService = ref.watch(bookServiceProvider);
  return bookService.getUserBorrowedBooks(userId);
});

final userFavoriteBooksProvider = StreamProvider.family<List<BookModel>, String>((ref, userId) {
  final bookService = ref.watch(bookServiceProvider);
  return bookService.getUserFavoriteBooks(userId);
});
