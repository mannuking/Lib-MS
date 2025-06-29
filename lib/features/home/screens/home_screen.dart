import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_management_system/core/theme/app_colors.dart';
import 'package:library_management_system/features/auth/services/auth_service.dart';
import 'package:library_management_system/features/books/services/book_service.dart';
import 'package:library_management_system/shared/models/book_model.dart';
import 'package:library_management_system/shared/widgets/book_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final allBooks = ref.watch(allBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: currentUser.when(
          data: (user) => Text('Welcome, ${user?.name ?? 'User'}'),
          loading: () => const Text('Library'),
          error: (_, __) => const Text('Library'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allBooksProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats Card
              _buildQuickStatsCard(context, ref),
              
              const SizedBox(height: 24),
              
              // Recently Added Books
              Text(
                'Recently Added',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().slideX(begin: -0.3, duration: 600.ms),
              
              const SizedBox(height: 16),
              
              allBooks.when(
                data: (books) => _buildRecentlyAddedBooks(context, books),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Error: $error'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Categories Section
              Text(
                'Browse by Category',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().slideX(begin: -0.3, duration: 600.ms, delay: 200.ms),
              
              const SizedBox(height: 16),
              
              _buildCategoriesGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppColors.primaryGradient,
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.library_books,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Library Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      currentUser.when(
                        data: (user) => Text(
                          user?.isAdmin == true ? 'Admin View' : 'Member View',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.book,
                    title: 'Books Borrowed',
                    value: currentUser.when(
                      data: (user) => user?.borrowedBooksCount.toString() ?? '0',
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.favorite,
                    title: 'Favorites',
                    value: '0', // TODO: Implement favorites count
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentlyAddedBooks(BuildContext context, List<BookModel> books) {
    final recentBooks = books.take(5).toList();
    
    if (recentBooks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.library_books_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No books available yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentBooks.length,
        itemBuilder: (context, index) {
          final book = recentBooks[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            child: BookCard(
              book: book,
              onTap: () => context.push('/book/${book.id}'),
            ),
          ).animate().slideX(
            begin: 0.3,
            duration: 600.ms,
            delay: Duration(milliseconds: index * 100),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    final categories = [
      CategoryItem('Fiction', Icons.auto_stories, AppColors.primary),
      CategoryItem('Science', Icons.science, AppColors.success),
      CategoryItem('Technology', Icons.computer, AppColors.info),
      CategoryItem('History', Icons.history_edu, AppColors.warning),
      CategoryItem('Biography', Icons.person, AppColors.secondary),
      CategoryItem('Mystery', Icons.search, Colors.purple),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(context, category, index);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryItem category, int index) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to category books
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                category.color.withValues(alpha: 0.1),
                category.color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                size: 32,
                color: category.color,
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: category.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(
      duration: 600.ms,
      delay: Duration(milliseconds: index * 100 + 400),
    );
  }
}

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  CategoryItem(this.name, this.icon, this.color);
}
