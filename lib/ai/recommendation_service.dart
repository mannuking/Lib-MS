import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:library_management_system/core/constants/app_constants.dart';
import 'package:library_management_system/shared/models/book_model.dart';
import 'package:library_management_system/shared/models/user_model.dart';
import 'package:library_management_system/shared/models/borrowed_book_model.dart';

class BookRecommendation {
  final String bookId;
  final String title;
  final String author;
  final String category;
  final double confidenceScore;
  final String reason;

  BookRecommendation({
    required this.bookId,
    required this.title,
    required this.author,
    required this.category,
    required this.confidenceScore,
    required this.reason,
  });

  factory BookRecommendation.fromMap(Map<String, dynamic> map) {
    return BookRecommendation(
      bookId: map['bookId'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      category: map['category'] ?? '',
      confidenceScore: (map['confidenceScore'] ?? 0.0).toDouble(),
      reason: map['reason'] ?? '',
    );
  }
}

class RecommendationService {
  late final GenerativeModel _model;
  
  RecommendationService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: AppConstants.geminiApiKey,
    );
  }

  Future<List<BookRecommendation>> getPersonalizedRecommendations({
    required UserModel user,
    required List<BookModel> availableBooks,
    required List<BorrowedBookModel> userHistory,
  }) async {
    try {
      final prompt = _buildPrompt(user, availableBooks, userHistory);
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return _parseRecommendations(response.text ?? '', availableBooks);
    } catch (e) {
      // Fallback to rule-based recommendations if AI fails
      return _getFallbackRecommendations(user, availableBooks, userHistory);
    }
  }

  String _buildPrompt(
    UserModel user,
    List<BookModel> availableBooks,
    List<BorrowedBookModel> userHistory,
  ) {
    final userPreferences = user.favoriteGenres.join(', ');
    final recentReads = userHistory
        .take(5)
        .map((book) => '${book.bookTitle} by ${book.bookAuthor} (${book.borrowedDate.year})')
        .join(', ');
    
    final bookList = availableBooks
        .map((book) => '${book.id}|${book.title}|${book.author}|${book.category}|${book.description}')
        .join('\n');

    return '''
You are a smart librarian AI assistant. Based on the user's profile and reading history, recommend the top ${AppConstants.maxRecommendations} books from the available collection.

User Profile:
- Name: ${user.name}
- Favorite Genres: ${userPreferences.isEmpty ? 'None specified' : userPreferences}
- Recent Reads: ${recentReads.isEmpty ? 'No recent history' : recentReads}
- Total Books Borrowed: ${user.borrowedBooksCount}

Available Books (Format: ID|Title|Author|Category|Description):
$bookList

Instructions:
1. Analyze the user's reading patterns and preferences
2. Consider genre diversity while respecting preferences
3. Recommend books that match their interests but also introduce new themes
4. Provide a confidence score (0.0-1.0) and a brief reason for each recommendation
5. Return exactly ${AppConstants.maxRecommendations} recommendations

Response Format (JSON):
{
  "recommendations": [
    {
      "bookId": "book_id_here",
      "confidenceScore": 0.85,
      "reason": "Brief explanation why this book fits the user's taste"
    }
  ]
}
''';
  }

  List<BookRecommendation> _parseRecommendations(
    String aiResponse,
    List<BookModel> availableBooks,
  ) {
    try {
      // Simple parsing - in production, use proper JSON parsing
      final recommendations = <BookRecommendation>[];
      final bookMap = {for (var book in availableBooks) book.id: book};
      
      // Extract book IDs from AI response (simplified approach)
      final bookIds = RegExp(r'"bookId":\s*"([^"]+)"')
          .allMatches(aiResponse)
          .map((match) => match.group(1)!)
          .toList();
      
      final reasons = RegExp(r'"reason":\s*"([^"]+)"')
          .allMatches(aiResponse)
          .map((match) => match.group(1)!)
          .toList();
      
      final scores = RegExp(r'"confidenceScore":\s*([0-9.]+)')
          .allMatches(aiResponse)
          .map((match) => double.tryParse(match.group(1)!) ?? 0.5)
          .toList();

      for (int i = 0; i < bookIds.length && i < AppConstants.maxRecommendations; i++) {
        final book = bookMap[bookIds[i]];
        if (book != null) {
          recommendations.add(BookRecommendation(
            bookId: book.id,
            title: book.title,
            author: book.author,
            category: book.category,
            confidenceScore: i < scores.length ? scores[i] : 0.5,
            reason: i < reasons.length ? reasons[i] : 'Matches your reading preferences',
          ));
        }
      }
      
      return recommendations;
    } catch (e) {
      return [];
    }
  }

  List<BookRecommendation> _getFallbackRecommendations(
    UserModel user,
    List<BookModel> availableBooks,
    List<BorrowedBookModel> userHistory,
  ) {
    final recommendations = <BookRecommendation>[];
    final readBookIds = userHistory.map((book) => book.bookId).toSet();
    
    // Filter out already read books
    final unreadBooks = availableBooks
        .where((book) => !readBookIds.contains(book.id))
        .toList();
    
    // Sort by rating and category preference
    unreadBooks.sort((a, b) {
      final aPreferred = user.favoriteGenres.contains(a.category) ? 1 : 0;
      final bPreferred = user.favoriteGenres.contains(b.category) ? 1 : 0;
      
      if (aPreferred != bPreferred) {
        return bPreferred.compareTo(aPreferred);
      }
      
      return b.rating.compareTo(a.rating);
    });
    
    // Take top recommendations
    for (int i = 0; i < unreadBooks.length && i < AppConstants.maxRecommendations; i++) {
      final book = unreadBooks[i];
      final isPreferred = user.favoriteGenres.contains(book.category);
      
      recommendations.add(BookRecommendation(
        bookId: book.id,
        title: book.title,
        author: book.author,
        category: book.category,
        confidenceScore: isPreferred ? 0.8 : 0.6,
        reason: isPreferred 
            ? 'Matches your favorite genre: ${book.category}'
            : 'Highly rated book that might interest you',
      ));
    }
    
    return recommendations;
  }

  Future<String> getBookRecommendationExplanation({
    required BookModel book,
    required UserModel user,
  }) async {
    try {
      final prompt = '''
Explain in 1-2 sentences why "${book.title}" by ${book.author} would be a good recommendation for someone who likes ${user.favoriteGenres.join(', ')}.

Book Description: ${book.description}
Book Category: ${book.category}
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? 'This book matches your reading preferences and interests.';
    } catch (e) {
      return 'This book is recommended based on your reading history and preferences.';
    }
  }
}
