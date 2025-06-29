import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_management_system/core/theme/app_colors.dart';
import 'package:library_management_system/features/auth/services/auth_service.dart';
import 'package:library_management_system/features/books/services/book_service.dart';
import 'package:library_management_system/shared/models/book_model.dart';
import 'package:library_management_system/shared/widgets/custom_button.dart';

final bookProvider = StreamProvider.family<BookModel?, String>((ref, bookId) {
  final bookService = ref.watch(bookServiceProvider);
  return bookService.getAllBooks().map((books) {
    try {
      return books.firstWhere((book) => book.id == bookId);
    } catch (e) {
      return null;
    }
  });
});

class BookDetailsScreen extends ConsumerStatefulWidget {
  final String bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  ConsumerState<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends ConsumerState<BookDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final book = ref.watch(bookProvider(widget.bookId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: book.when(
        data: (bookData) => bookData != null
            ? _buildBookDetails(context, bookData, currentUser)
            : _buildNotFound(context),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(context, error.toString()),
      ),
    );
  }

  Widget _buildBookDetails(BuildContext context, BookModel book, AsyncValue currentUser) {
    return CustomScrollView(
      slivers: [
        // App Bar with Book Cover
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.primaryDark,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Book Cover
                      Hero(
                        tag: 'book-${book.id}',
                        child: Container(
                          width: 120,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: book.coverImageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: book.coverImageUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => _buildCoverPlaceholder(),
                                    errorWidget: (context, url, error) => _buildCoverPlaceholder(),
                                  )
                                : _buildCoverPlaceholder(),
                          ),
                        ).animate().scale(duration: 600.ms),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // Book Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              book.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ).animate().slideX(begin: 0.3, duration: 600.ms, delay: 200.ms),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'by ${book.author}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ).animate().slideX(begin: 0.3, duration: 600.ms, delay: 300.ms),
                            
                            const SizedBox(height: 12),
                            
                            // Category and Rating
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    book.category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                            
                            const SizedBox(height: 8),
                            
                            if (book.rating > 0)
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    return Icon(
                                      index < book.rating.floor()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    book.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Book Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Availability
                _buildStatusSection(book).animate().slideY(begin: 0.3, duration: 600.ms, delay: 600.ms),
                
                const SizedBox(height: 24),
                
                // Description
                _buildDescriptionSection(context, book).animate().slideY(begin: 0.3, duration: 600.ms, delay: 700.ms),
                
                const SizedBox(height: 24),
                
                // Book Details
                _buildDetailsSection(context, book).animate().slideY(begin: 0.3, duration: 600.ms, delay: 800.ms),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                currentUser.when(
                  data: (user) => user != null 
                      ? _buildActionButtons(context, book, user).animate().slideY(begin: 0.3, duration: 600.ms, delay: 900.ms)
                      : const SizedBox(),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      color: AppColors.primaryLight,
      child: const Center(
        child: Icon(
          Icons.book,
          size: 60,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildStatusSection(BookModel book) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              book.isAvailable ? Icons.check_circle : Icons.access_time,
              color: book.isAvailable ? AppColors.success : AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.isAvailable ? 'Available' : 'Currently Borrowed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: book.isAvailable ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  Text(
                    '${book.availableCopies}/${book.totalCopies} copies available',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, BookModel book) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              book.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, BookModel book) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('ISBN', book.isbn),
            _buildDetailRow('Category', book.category),
            _buildDetailRow('Published', _formatDate(book.publishedDate)),
            _buildDetailRow('Added', _formatDate(book.addedAt)),
            if (book.tags.isNotEmpty)
              _buildDetailRow('Tags', book.tags.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, BookModel book, user) {
    return Column(
      children: [
        if (!user.isAdmin && book.isAvailable) ...[
          CustomButton(
            text: 'Borrow Book',
            onPressed: _isLoading ? null : () => _borrowBook(book, user),
            isLoading: _isLoading,
            width: double.infinity,
            icon: Icons.library_add,
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _addToFavorites(book, user),
                icon: const Icon(Icons.favorite_border),
                label: const Text('Add to Favorites'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareBook(book),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Not Found')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Book not found',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Future<void> _borrowBook(BookModel book, user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookService = ref.read(bookServiceProvider);
      await bookService.borrowBook(
        userId: user.id,
        userName: user.name,
        book: book,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book borrowed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to borrow book: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addToFavorites(BookModel book, user) async {
    try {
      final bookService = ref.read(bookServiceProvider);
      await bookService.addToFavorites(user.id, book.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to favorites!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to favorites: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _shareBook(BookModel book) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
