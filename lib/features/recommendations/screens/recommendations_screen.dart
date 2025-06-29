import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_management_system/core/theme/app_colors.dart';
import 'package:library_management_system/features/auth/services/auth_service.dart';
import 'package:library_management_system/features/books/services/book_service.dart';
import 'package:library_management_system/ai/recommendation_service.dart';
import 'package:library_management_system/shared/widgets/book_card.dart';
import 'package:library_management_system/shared/models/book_model.dart';

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService();
});

final userRecommendationsProvider = FutureProvider<List<BookRecommendation>>((ref) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  if (currentUser == null) return [];

  final allBooks = await ref.watch(allBooksProvider.future);
  final borrowedBooks = await ref.watch(userBorrowedBooksProvider(currentUser.id).future);
  final recommendationService = ref.watch(recommendationServiceProvider);

  return await recommendationService.getPersonalizedRecommendations(
    user: currentUser,
    availableBooks: allBooks,
    userHistory: borrowedBooks,
  );
});

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final recommendations = ref.watch(userRecommendationsProvider);
    final allBooks = ref.watch(allBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(userRecommendationsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userRecommendationsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(context, currentUser),
              
              const SizedBox(height: 24),
              
              // Recommendations Section
              Text(
                'Recommended for You',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().slideX(begin: -0.3, duration: 600.ms),
              
              const SizedBox(height: 16),
              
              recommendations.when(
                data: (recs) => allBooks.when(
                  data: (books) => _buildRecommendationsList(context, recs, books),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _buildErrorState(context, error.toString()),
                ),
                loading: () => _buildLoadingState(context),
                error: (error, _) => _buildErrorState(context, error.toString()),
              ),
              
              const SizedBox(height: 24),
              
              // Personalization Tips
              _buildPersonalizationTips(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, AsyncValue currentUser) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withOpacity(0.8),
              AppColors.secondaryDark.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI-Powered Suggestions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      currentUser.when(
                        data: (user) => Text(
                          'Personalized for ${user?.name ?? 'you'}',
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
            const Text(
              'Our AI analyzes your reading history and preferences to suggest books you\'ll love.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildRecommendationsList(
    BuildContext context,
    List<BookRecommendation> recommendations,
    List<BookModel> allBooks,
  ) {
    if (recommendations.isEmpty) {
      return _buildEmptyRecommendations(context);
    }

    final bookMap = {for (var book in allBooks) book.id: book};
    
    return Column(
      children: recommendations.asMap().entries.map((entry) {
        final index = entry.key;
        final recommendation = entry.value;
        final book = bookMap[recommendation.bookId];
        
        if (book == null) return const SizedBox();
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildRecommendationCard(context, recommendation, book, index),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    BookRecommendation recommendation,
    BookModel book,
    int index,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/book/${book.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rank Badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Book Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 80,
                  child: book.coverImageUrl != null
                      ? Image.network(
                          book.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildDefaultCover(),
                        )
                      : _buildDefaultCover(),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Book Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Confidence Score
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getConfidenceColor(recommendation.confidenceScore),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(recommendation.confidenceScore * 100).toInt()}% match',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (book.rating > 0) ...[
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            book.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Reason
                    Text(
                      recommendation.reason,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideX(
      begin: 0.3,
      duration: 600.ms,
      delay: Duration(milliseconds: index * 100 + 200),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      color: AppColors.primaryLight,
      child: const Center(
        child: Icon(
          Icons.book,
          color: AppColors.primary,
          size: 24,
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.6) return AppColors.warning;
    return AppColors.textSecondary;
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildEmptyRecommendations(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Recommendations Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start borrowing books to get personalized recommendations!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Recommendations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Using fallback recommendations based on popular books.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizationTips(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outlined,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Improve Your Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem('📚', 'Borrow more books to train the AI'),
            _buildTipItem('⭐', 'Rate books you\'ve read'),
            _buildTipItem('🏷️', 'Update your favorite genres in profile'),
            _buildTipItem('🔄', 'Check back regularly for new suggestions'),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.3, duration: 600.ms, delay: 800.ms);
  }

  Widget _buildTipItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
