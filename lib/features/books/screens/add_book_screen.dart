import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_management_system/core/theme/app_colors.dart';
import 'package:library_management_system/features/auth/services/auth_service.dart';
import 'package:library_management_system/features/books/services/book_service.dart';
import 'package:library_management_system/shared/models/book_model.dart';
import 'package:library_management_system/shared/widgets/custom_button.dart';
import 'package:library_management_system/shared/widgets/custom_text_field.dart';

class AddBookScreen extends ConsumerStatefulWidget {
  const AddBookScreen({super.key});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _isbnController = TextEditingController();
  final _totalCopiesController = TextEditingController();
  final _publishedDateController = TextEditingController();
  
  String _selectedCategory = 'Fiction';
  File? _selectedImage;
  bool _isLoading = false;
  DateTime? _selectedDate;
  final List<String> _tags = [];
  final _tagController = TextEditingController();

  final List<String> _categories = [
    'Fiction',
    'Science',
    'Technology',
    'History',
    'Biography',
    'Mystery',
    'Romance',
    'Fantasy',
    'Thriller',
    'Self-Help',
    'Educational',
    'Children',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _isbnController.dispose();
    _totalCopiesController.dispose();
    _publishedDateController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Book'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: currentUser.when(
        data: (user) => user?.isAdmin == true
            ? _buildAddBookForm(context)
            : _buildUnauthorized(context),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildUnauthorized(context),
      ),
    );
  }

  Widget _buildAddBookForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Add a new book to the library',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().slideY(begin: -0.3, duration: 600.ms),
            
            const SizedBox(height: 24),
            
            // Book Cover Section
            _buildCoverSection().animate().slideY(begin: 0.3, duration: 600.ms, delay: 100.ms),
            
            const SizedBox(height: 24),
            
            // Basic Information
            _buildBasicInformation().animate().slideY(begin: 0.3, duration: 600.ms, delay: 200.ms),
            
            const SizedBox(height: 24),
            
            // Additional Details
            _buildAdditionalDetails().animate().slideY(begin: 0.3, duration: 600.ms, delay: 300.ms),
            
            const SizedBox(height: 24),
            
            // Tags Section
            _buildTagsSection().animate().slideY(begin: 0.3, duration: 600.ms, delay: 400.ms),
            
            const SizedBox(height: 32),
            
            // Submit Button
            CustomButton(
              text: 'Add Book',
              onPressed: _isLoading ? null : _submitBook,
              isLoading: _isLoading,
              width: double.infinity,
              icon: Icons.add,
            ).animate().slideY(begin: 0.3, duration: 600.ms, delay: 500.ms),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Cover',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Cover Preview
                Container(
                  width: 100,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.textHint),
                    color: AppColors.background,
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book,
                              size: 40,
                              color: AppColors.textHint,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No Image',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Upload Buttons
                Expanded(
                  child: Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Choose from Gallery'),
                      ),
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          label: const Text(
                            'Remove',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _titleController,
              label: 'Book Title',
              hint: 'Enter the book title',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter the book title';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _authorController,
              label: 'Author',
              hint: 'Enter the author name',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter the author name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter a brief description of the book',
              maxLines: 4,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // ISBN
            CustomTextField(
              controller: _isbnController,
              label: 'ISBN',
              hint: 'Enter the ISBN number',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter the ISBN';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Category Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.textHint),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Published Date
            CustomTextField(
              controller: _publishedDateController,
              label: 'Published Date',
              hint: 'Select publication date',
              readOnly: true,
              onTap: _selectDate,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please select the publication date';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Total Copies
            CustomTextField(
              controller: _totalCopiesController,
              label: 'Total Copies',
              hint: 'Enter number of copies',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter the number of copies';
                }
                final copies = int.tryParse(value!);
                if (copies == null || copies <= 0) {
                  return 'Please enter a valid number of copies';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Add Tag Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'Add a tag',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _addTag,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _addTag(_tagController.text),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Tags Display
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthorized(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block,
            size: 64,
            color: AppColors.error,
          ),
          SizedBox(height: 16),
          Text(
            'Unauthorized Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Only administrators can add books',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _publishedDateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag.trim())) {
      setState(() {
        _tags.add(tag.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submitBook() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider).asData?.value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final totalCopies = int.parse(_totalCopiesController.text);
      
      final book = BookModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description: _descriptionController.text.trim(),
        isbn: _isbnController.text.trim(),
        category: _selectedCategory,
        status: 'available',
        publishedDate: _selectedDate ?? DateTime.now(),
        addedAt: DateTime.now(),
        totalCopies: totalCopies,
        availableCopies: totalCopies,
        tags: _tags,
        addedBy: currentUser.id,
      );

      final bookService = ref.read(bookServiceProvider);
      await bookService.addBook(
        book: book,
        coverImage: _selectedImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add book: ${e.toString()}'),
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
}
