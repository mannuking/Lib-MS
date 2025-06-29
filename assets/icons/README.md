# Icons Directory

This directory contains custom icon assets for the Library Management System app.

## Required Icons:

### Navigation & UI
- `home_filled.svg` - Home icon (filled state)
- `home_outlined.svg` - Home icon (outlined state)
- `search_filled.svg` - Search icon (filled state)
- `search_outlined.svg` - Search icon (outlined state)
- `recommendations.svg` - AI recommendations icon
- `profile_filled.svg` - Profile icon (filled state)
- `profile_outlined.svg` - Profile icon (outlined state)

### Book Actions
- `favorite_filled.svg` - Favorite/heart icon (filled)
- `favorite_outlined.svg` - Favorite/heart icon (outlined)
- `bookmark_filled.svg` - Bookmark icon (filled)
- `bookmark_outlined.svg` - Bookmark icon (outlined)
- `share.svg` - Share book icon
- `download.svg` - Download/save icon

### Category Icons
- `fiction.svg` - Fiction genre icon
- `science.svg` - Science genre icon
- `history.svg` - History genre icon
- `biography.svg` - Biography genre icon
- `technology.svg` - Technology genre icon
- `arts.svg` - Arts genre icon
- `mystery.svg` - Mystery genre icon
- `romance.svg` - Romance genre icon

### Admin/Management
- `add_book.svg` - Add new book icon
- `edit_book.svg` - Edit book icon
- `delete_book.svg` - Delete book icon
- `manage_users.svg` - User management icon
- `analytics.svg` - Analytics dashboard icon

### Status Indicators
- `available.svg` - Book available status
- `borrowed.svg` - Book borrowed status
- `reserved.svg` - Book reserved status
- `overdue.svg` - Overdue status icon

## Icon Guidelines:
- Use SVG format for scalability
- Maintain consistent style (outlined vs filled states)
- Use the app's color scheme (defined in app_colors.dart)
- Keep icons simple and recognizable
- Standard size: 24x24dp for most UI icons

## Implementation:
Use Flutter's built-in support for SVG icons or the `flutter_svg` package:
```dart
SvgPicture.asset('assets/icons/favorite_filled.svg')
```

## Color Usage:
Icons should adapt to the theme. Use the theme colors:
- Primary: #6366F1 (Indigo)
- Secondary: #06B6D4 (Cyan)
- Success: #10B981 (Emerald)
- Warning: #F59E0B (Amber)
- Error: #EF4444 (Red)
