import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_management_system/core/theme/app_colors.dart';
import 'package:library_management_system/features/auth/services/auth_service.dart';
import 'package:library_management_system/features/books/services/book_service.dart';
import 'package:library_management_system/shared/widgets/custom_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: currentUser.when(
        data: (user) => user != null 
            ? _buildProfileContent(context, ref, user)
            : _buildErrorState(context),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(context),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, user) {
    final borrowedBooks = ref.watch(userBorrowedBooksProvider(user.id));
    final favoriteBooks = ref.watch(userFavoriteBooksProvider(user.id));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          _buildProfileHeader(context, user),
          
          const SizedBox(height: 24),
          
          // Stats Cards
          _buildStatsSection(context, user, borrowedBooks, favoriteBooks),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(context, user),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildRecentActivity(context, borrowedBooks),
          
          const SizedBox(height: 24),
          
          // Account Actions
          _buildAccountActions(context, ref),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppColors.primaryGradient,
        ),
        child: Column(
          children: [
            // Profile Picture
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: user.profileImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        user.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                      ),
                    )
                  : _buildDefaultAvatar(),
            ).animate().scale(duration: 600.ms),
            
            const SizedBox(height: 16),
            
            // User Info
            Text(
              user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ).animate().slideY(begin: 0.3, duration: 600.ms, delay: 200.ms),
            
            const SizedBox(height: 4),
            
            Text(
              user.email,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ).animate().slideY(begin: 0.3, duration: 600.ms, delay: 300.ms),
            
            const SizedBox(height: 8),
            
            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.isAdmin ? 'Administrator' : 'Member',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return const Icon(
      Icons.person,
      size: 40,
      color: Colors.white,
    );
  }

  Widget _buildStatsSection(context, user, borrowedBooks, favoriteBooks) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.book,
            title: 'Books Borrowed',
            value: borrowedBooks.when(
              data: (books) => books.length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            color: AppColors.primary,
          ).animate().slideX(begin: -0.3, duration: 600.ms, delay: 500.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.favorite,
            title: 'Favorites',
            value: favoriteBooks.when(
              data: (books) => books.length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            color: AppColors.error,
          ).animate().slideX(begin: 0.3, duration: 600.ms, delay: 600.ms),
        ),
      ],
    );
  }

  Widget _buildStatCard(context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, user) {
    final actions = [
      if (!user.isAdmin) ...[
        ActionItem(
          icon: Icons.history,
          title: 'Borrowing History',
          subtitle: 'View your borrowed books',
          onTap: () {
            // TODO: Navigate to history
          },
        ),
        ActionItem(
          icon: Icons.favorite,
          title: 'My Favorites',
          subtitle: 'Books you loved',
          onTap: () {
            // TODO: Navigate to favorites
          },
        ),
      ],
      ActionItem(
        icon: Icons.category,
        title: 'Favorite Genres',
        subtitle: 'Update your preferences',
        onTap: () => _showGenreSelector(context, user),
      ),
      if (user.isAdmin) ...[
        ActionItem(
          icon: Icons.dashboard,
          title: 'Admin Dashboard',
          subtitle: 'Manage library',
          onTap: () {
            // TODO: Navigate to admin dashboard
          },
        ),
      ],
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...actions.asMap().entries.map((entry) {
              final index = entry.key;
              final action = entry.value;
              return _buildActionTile(context, action)
                  .animate()
                  .slideX(
                    begin: 0.3,
                    duration: 400.ms,
                    delay: Duration(milliseconds: index * 100 + 700),
                  );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, ActionItem action) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(action.icon, color: AppColors.primary),
      ),
      title: Text(action.title),
      subtitle: Text(action.subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: action.onTap,
    );
  }

  Widget _buildRecentActivity(BuildContext context, borrowedBooks) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            borrowedBooks.when(
              data: (books) {
                final recentBooks = books.take(3).toList();
                if (recentBooks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No recent activity',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }
                return Column(
                  children: recentBooks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final book = entry.value;
                    return _buildActivityItem(context, book)
                        .animate()
                        .slideX(
                          begin: 0.3,
                          duration: 400.ms,
                          delay: Duration(milliseconds: index * 100 + 1000),
                        );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Failed to load activity'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, borrowedBook) {
    return ListTile(
      leading: const Icon(Icons.book, color: AppColors.primary),
      title: Text(borrowedBook.bookTitle),
      subtitle: Text('Borrowed on ${_formatDate(borrowedBook.borrowedDate)}'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: borrowedBook.status == 'borrowed' 
              ? AppColors.warning.withOpacity(0.2)
              : AppColors.success.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          borrowedBook.status.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: borrowedBook.status == 'borrowed' 
                ? AppColors.warning 
                : AppColors.success,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Sign Out',
              onPressed: () => _showSignOutDialog(context, ref),
              backgroundColor: AppColors.error,
              width: double.infinity,
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.3, duration: 600.ms, delay: 1200.ms);
  }

  Widget _buildErrorState(BuildContext context) {
    return const Center(
      child: Text('Failed to load profile'),
    );
  }

  void _showGenreSelector(BuildContext context, user) {
    final genres = [
      'Fiction', 'Science', 'Technology', 'History', 'Biography',
      'Mystery', 'Romance', 'Fantasy', 'Thriller', 'Self-Help'
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Favorite Genres'),
        content: SizedBox(
          width: double.maxFinite,
          child: Wrap(
            spacing: 8,
            children: genres.map((genre) {
              final isSelected = user.favoriteGenres.contains(genre);
              return FilterChip(
                label: Text(genre),
                selected: isSelected,
                onSelected: (selected) {
                  // TODO: Update user preferences
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Save preferences
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final authService = ref.read(authServiceProvider);
                await authService.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sign out: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
