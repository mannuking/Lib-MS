# Library Management System - Copilot Instructions

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

## Project Overview
This is a Flutter mobile application for a Library Management System with AI-powered book recommendations.

## Architecture & Patterns
- **State Management**: Flutter Riverpod for reactive state management
- **Navigation**: GoRouter for declarative routing
- **Backend**: Firebase (Auth, Firestore, Storage)
- **AI Integration**: Google Generative AI (Gemini) for book recommendations
- **Design Pattern**: Feature-first folder structure with clean architecture

## Key Features
1. **Authentication**: Firebase Auth with role-based access (User/Admin)
2. **Book Management**: CRUD operations for books with image upload
3. **AI Recommendations**: Personalized book suggestions based on user history
4. **Modern UI**: Material 3 design with animations using flutter_animate
5. **Responsive Design**: Adaptive layouts for different screen sizes

## Code Style Guidelines
- Use meaningful variable and function names
- Follow Dart naming conventions (camelCase for variables, PascalCase for classes)
- Always add proper error handling with try-catch blocks
- Use const constructors where possible for performance
- Add comprehensive comments for complex business logic
- Implement proper loading states and error handling in UI

## Firebase Configuration
- Update `lib/firebase_options.dart` with your actual Firebase project configuration
- Update `lib/core/constants/app_constants.dart` with your Gemini API key
- Ensure proper Firebase rules are set up for security

## AI Integration Notes
- The AI recommendation service uses Gemini for generating personalized book suggestions
- Fallback logic is implemented for when AI service is unavailable
- User reading history and preferences are analyzed to improve recommendations

## Testing
- Write unit tests for business logic in the services
- Integration tests for critical user flows
- Widget tests for complex UI components

## Common Commands
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
