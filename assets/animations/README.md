# Animations Directory

This directory contains Lottie animation files for the Library Management System app.

## Required Animations:

### Loading States
- `loading_books.json` - Loading animation for book searches and API calls
- `loading_spinner.json` - General loading spinner
- `ai_thinking.json` - AI processing animation for recommendations

### Success/Error States
- `success_checkmark.json` - Success confirmation animation
- `error_animation.json` - Error state animation
- `empty_state.json` - Empty state animation (when no results found)

### Feature-Specific
- `book_flip.json` - Book page turning animation
- `favorite_heart.json` - Heart animation for favorites
- `search_animation.json` - Search process animation
- `upload_progress.json` - File upload progress animation

### Welcome/Onboarding
- `welcome_books.json` - Welcome screen animation with floating books
- `ai_recommendation.json` - AI feature introduction animation

## Animation Guidelines:
- Use Lottie animations (.json format)
- Keep animations lightweight (< 100KB each)
- Ensure animations loop smoothly where appropriate
- Use consistent color schemes matching the app theme
- Test animations on different screen densities

## Sources for Animations:
- [LottieFiles](https://lottiefiles.com/) - Free and premium Lottie animations
- [Rive](https://rive.app/) - Create custom animations
- Adobe After Effects with Bodymovin plugin for custom animations

## Implementation:
Use the `lottie` package to display animations:
```dart
Lottie.asset('assets/animations/loading_books.json')
```
