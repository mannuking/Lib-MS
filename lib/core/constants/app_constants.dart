class AppConstants {
  // App Info
  static const String appName = 'Library Management System';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String booksCollection = 'books';
  static const String borrowedBooksCollection = 'borrowed_books';
  static const String categoriesCollection = 'categories';
  static const String favoritesCollection = 'favorites';
  
  // User Roles
  static const String adminRole = 'admin';
  static const String userRole = 'user';
  
  // Book Status
  static const String availableStatus = 'available';
  static const String borrowedStatus = 'borrowed';
  static const String reservedStatus = 'reserved';
  
  // Storage Paths
  static const String bookCoversPath = 'book_covers';
  static const String userProfilesPath = 'user_profiles';
  
  // AI Configuration
  static const String geminiApiKey = 'your-gemini-api-key-here';
  static const int maxRecommendations = 5;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
}
