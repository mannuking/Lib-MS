# Images Directory

This directory contains image assets for the Library Management System app.

## Required Images:

### Book Covers (Examples)
- `placeholder_book.png` - Default book cover image (200x300px recommended)
- `book_1.jpg`, `book_2.jpg`, etc. - Sample book cover images

### User Interface
- `app_logo.png` - App logo (512x512px for high resolution)
- `app_icon.png` - App icon (various sizes needed for different platforms)
- `library_hero.jpg` - Hero image for splash/welcome screens (1920x1080px)

### Categories/Genres
- `fiction_icon.png` - Fiction category icon (64x64px)
- `science_icon.png` - Science category icon (64x64px)
- `history_icon.png` - History category icon (64x64px)
- `biography_icon.png` - Biography category icon (64x64px)
- `technology_icon.png` - Technology category icon (64x64px)
- `arts_icon.png` - Arts category icon (64x64px)

### Empty States
- `empty_books.png` - Empty state for when no books are found
- `empty_favorites.png` - Empty state for favorites screen
- `empty_history.png` - Empty state for reading history

## Format Guidelines:
- Use PNG for images with transparency
- Use JPG for photos and images without transparency
- Optimize images for mobile use (keep file sizes reasonable)
- Use consistent naming conventions (lowercase, underscores)

## Adding New Images:
1. Place images in this directory
2. Update pubspec.yaml if adding new assets
3. Use appropriate image loading widgets in the app (CachedNetworkImage for URLs, Image.asset for local assets)
