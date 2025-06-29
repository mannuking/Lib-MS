# # 📚 Smart Library Management System

A modern Flutter mobile application for library management with AI-powered book recommendations. Built with Firebase backend and Google's Gemini AI for personalized book suggestions.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black)
![AI](https://img.shields.io/badge/AI_Powered-4285F4?style=for-the-badge&logo=google&logoColor=white)

## ✨ Features

### 🔐 Authentication
- **Firebase Authentication** with email/password
- **Role-based access control** (User/Admin)
- Secure user management

### 📖 Book Management
- **Add, edit, delete books** (Admin only)
- **Upload cover images** with Firebase Storage
- **Category-based organization**
- **Search functionality** with filters
- **Real-time availability tracking**

### 🤖 AI-Powered Recommendations
- **Personalized book suggestions** using Google Gemini AI
- **Analysis of reading history** and preferences
- **Confidence scoring** for recommendations
- **Fallback system** for offline mode

### 📱 Modern UI/UX
- **Material 3 Design** with custom theming
- **Smooth animations** using flutter_animate
- **Responsive layouts** for all screen sizes
- **Dark/Light theme support**

### 👤 User Features
- **Browse and search books**
- **Borrow/return functionality**
- **Favorites management**
- **Reading history tracking**
- **Profile customization**

## 🏗️ Architecture

```
lib/
├── ai/                     # AI recommendation service
├── core/                   # Core utilities
│   ├── constants/         # App constants
│   ├── navigation/        # Router configuration
│   └── theme/            # App theming
├── features/              # Feature modules
│   ├── auth/             # Authentication
│   ├── books/            # Book management
│   ├── home/             # Home screen
│   ├── profile/          # User profile
│   └── recommendations/  # AI recommendations
└── shared/               # Shared components
    ├── models/           # Data models
    └── widgets/          # Reusable widgets
```

## 🚀 Getting Started

### Prerequisites
- Flutter 3.7.2 or higher
- Dart 3.0 or higher
- Firebase project with the following services:
  - Authentication
  - Firestore Database
  - Storage
- Google AI API key for Gemini

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd library-management-system
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication (Email/Password)
   - Create Firestore database
   - Enable Storage
   - Download configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
   - Update `lib/firebase_options.dart` with your project configuration

4. **AI Configuration**
   - Get a Google AI API key for Gemini
   - Update `lib/core/constants/app_constants.dart`:
     ```dart
     static const String geminiApiKey = 'your-gemini-api-key-here';
     ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Firebase Rules

**Firestore Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // All authenticated users can read books
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users can manage their own borrowed books
    match /borrowed_books/{borrowId} {
      allow read, write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Users can manage their own favorites
    match /favorites/{favoriteId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

**Storage Security Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /book_covers/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 📦 Dependencies

### Main Dependencies
- `flutter_riverpod` - State management
- `firebase_core` - Firebase core
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `firebase_storage` - File storage
- `go_router` - Navigation
- `flutter_animate` - Animations
- `cached_network_image` - Image caching
- `google_generative_ai` - AI integration
- `image_picker` - Image selection

### Dev Dependencies
- `flutter_lints` - Code analysis
- `flutter_test` - Testing framework

## 🎯 Usage

### For Users
1. **Sign up** with email and password
2. **Browse books** on the home screen
3. **Search** for specific books or authors
4. **Borrow books** by tapping on available books
5. **Get AI recommendations** based on your reading history
6. **Manage favorites** and view borrowing history

### For Administrators
1. **Add new books** using the floating action button
2. **Upload book covers** and manage book details
3. **View all borrowed books** and manage returns
4. **Track library statistics**

## 🤖 AI Recommendations

The app uses Google's Gemini AI to provide personalized book recommendations:

- **Analyzes user behavior**: Reading history, favorite genres, borrowing patterns
- **Provides confidence scores**: Each recommendation comes with a confidence percentage
- **Explains reasoning**: AI provides explanations for why each book is recommended
- **Fallback system**: Rule-based recommendations when AI is unavailable

## 🧪 Testing

Run tests with:
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/
```

## 🚀 Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Firebase for backend services
- Google AI for recommendation engine
- Flutter team for the amazing framework
- Material Design for UI guidelines

## 📞 Support

For support, email your-email@example.com or create an issue in the repository.

---

Made with ❤️ using Flutter
