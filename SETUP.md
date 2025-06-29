# Development Setup Guide

This guide will help you set up the Library Management System Flutter app for development.

## Prerequisites

### Required Software
1. **Flutter SDK** (3.0.0 or later)
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Add Flutter to your PATH
   - Run `flutter doctor` to verify installation

2. **IDE** (Choose one)
   - **VS Code** with Flutter extension (recommended)
   - **Android Studio** with Flutter plugin
   - **IntelliJ IDEA** with Flutter plugin

3. **Mobile Development**
   - **For Android**: Android Studio, Android SDK, Java 8+
   - **For iOS**: Xcode (macOS only), iOS SDK

### Required Accounts & API Keys
1. **Firebase Project**
   - Create a project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication, Firestore, and Storage

2. **Google AI Studio** (for Gemini API)
   - Get API key from [aistudio.google.com](https://aistudio.google.com)

## Project Setup

### 1. Clone and Install Dependencies
```bash
git clone <your-repo-url>
cd library_management_system
flutter pub get
```

### 2. Firebase Configuration

#### Step 1: Install Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

#### Step 2: Initialize Firebase in Project
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This will:
- Create `firebase_options.dart`
- Configure Firebase for your platforms
- Link your Firebase project

#### Step 3: Update Firebase Rules

**Firestore Rules** (`firestore.rules`):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Books are readable by all authenticated users
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.get('createdBy') == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.get('isAdmin') == true);
    }
    
    // Borrowed books
    match /borrowed_books/{borrowId} {
      allow read, write: if request.auth != null && 
        (resource.data.get('userId') == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.get('isAdmin') == true);
    }
  }
}
```

**Storage Rules** (`storage.rules`):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /book_covers/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /profile_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3. Configure API Keys

#### Update `lib/core/constants/app_constants.dart`:
```dart
class AppConstants {
  // Replace with your actual Gemini API key
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // Other constants...
}
```

### 4. Firebase Authentication Setup

In Firebase Console:
1. Go to Authentication → Sign-in method
2. Enable **Email/Password** provider
3. Optionally enable **Google** sign-in

### 5. Firestore Database Setup

1. Create Firestore database in **production mode**
2. Create these collections:
   - `users` - User profiles
   - `books` - Book catalog
   - `borrowed_books` - Borrowing records

### 6. Firebase Storage Setup

1. Create storage buckets:
   - `book_covers/` - Book cover images
   - `profile_images/` - User profile pictures

## Development Workflow

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Run in debug mode with hot reload
flutter run --debug

# Run in release mode
flutter run --release

# Run for specific platform
flutter run -d android
flutter run -d ios
```

### Building the App
```bash
# Build APK for Android
flutter build apk

# Build App Bundle for Google Play
flutter build appbundle

# Build for iOS (macOS only)
flutter build ios
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Check for unused dependencies
flutter pub deps
```

## Creating Sample Data

### Sample Books (Add to Firestore)
```json
{
  "id": "book_1",
  "title": "The Flutter Complete Reference",
  "author": "Alberto Miola",
  "isbn": "978-1234567890",
  "category": "Technology",
  "description": "Complete guide to Flutter development...",
  "coverImageUrl": "https://example.com/flutter_book.jpg",
  "totalCopies": 5,
  "availableCopies": 3,
  "publishedDate": "2023-01-15T00:00:00Z",
  "createdAt": "2024-01-01T00:00:00Z",
  "createdBy": "admin_user_id",
  "tags": ["flutter", "mobile", "development"]
}
```

### Sample Admin User
```json
{
  "uid": "admin_user_id",
  "email": "admin@library.com",
  "displayName": "Library Administrator",
  "isAdmin": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "favoriteBooks": [],
  "borrowingHistory": []
}
```

## Troubleshooting

### Common Issues

#### 1. Firebase Connection Issues
```bash
# Clear Flutter cache
flutter clean
flutter pub get

# Regenerate Firebase options
flutterfire configure
```

#### 2. Android Build Issues
```bash
# Clean and rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### 3. iOS Build Issues
```bash
# Clean iOS build
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

#### 4. Dependency Conflicts
```bash
# Update dependencies
flutter pub upgrade
flutter pub get

# Check for conflicts
flutter pub deps
```

### Performance Tips

1. **Enable R8/ProGuard** for Android release builds
2. **Use const constructors** where possible
3. **Implement proper image caching** with CachedNetworkImage
4. **Use ListView.builder** for large lists
5. **Implement pagination** for book lists

## VS Code Configuration

### Recommended Extensions
- Flutter
- Dart
- GitLens
- Bracket Pair Colorizer
- Material Icon Theme

### Debug Configuration (`.vscode/launch.json`)
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "library_management_system",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug"
    },
    {
      "name": "library_management_system (profile mode)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile"
    }
  ]
}
```

## Production Deployment

### Android (Google Play Store)
1. Update `android/app/build.gradle` with proper signing config
2. Create upload keystore
3. Build app bundle: `flutter build appbundle`
4. Upload to Google Play Console

### iOS (App Store)
1. Configure signing in Xcode
2. Build archive: `flutter build ios`
3. Upload through Xcode or Application Loader

## Support

For issues and questions:
1. Check the [Flutter documentation](https://flutter.dev/docs)
2. Visit [Firebase documentation](https://firebase.google.com/docs)
3. Create issues in the project repository
4. Check the troubleshooting section above

## Next Steps

After setup:
1. Add real book data to Firestore
2. Add image assets to the `assets/` directory
3. Test AI recommendations with your Gemini API key
4. Customize the app theme and branding
5. Add additional features as needed
