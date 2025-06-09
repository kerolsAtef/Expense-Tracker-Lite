import 'package:expense_tracker/src/core/constants/ategory_constants.dart';
import 'package:flutter/material.dart';

class CategorySelectionGrid extends StatelessWidget {
  final String selectedCategory;
  final Function(String category, String icon) onCategorySelected;

  const CategorySelectionGrid({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Popular Categories (Top Row)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCategoryItem('groceries'),
              _buildCategoryItem('entertainment'),
              _buildCategoryItem('transportation'),
              _buildCategoryItem('food'),
            ],
          ),
          const SizedBox(height: 12),
          
          // Second Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCategoryItem('rent'),
              _buildCategoryItem('shopping'),
              _buildCategoryItem('healthcare'),
              _buildCategoryItem('utilities'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Show More Categories Button
          GestureDetector(
            onTap: () => _showAllCategories(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add,
                    size: 16,
                    color: Color(0xFF6C5CE7),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Add Category',
                    style: TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category) {
    final icon = CategoryConstants.getCategoryIcon(category);
    final isSelected = category == selectedCategory;
    
    return GestureDetector(
      onTap: () => onCategorySelected(category, icon),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF6C5CE7) 
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF6C5CE7) 
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 2),
            Text(
              category.substring(0, 1).toUpperCase() + category.substring(1),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showAllCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => AllCategoriesSheet(
          selectedCategory: selectedCategory,
          onCategorySelected: (category, icon) {
            onCategorySelected(category, icon);
            Navigator.of(context).pop();
          },
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class AllCategoriesSheet extends StatelessWidget {
  final String selectedCategory;
  final Function(String category, String icon) onCategorySelected;
  final ScrollController scrollController;

  const AllCategoriesSheet({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = CategoryConstants.categoryNames;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'Select Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          
          // Categories Grid
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final icon = CategoryConstants.getCategoryIcon(category);
                final isSelected = category == selectedCategory;
                
                return GestureDetector(
                  onTap: () => onCategorySelected(category, icon),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF6C5CE7) 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFF6C5CE7) 
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.substring(0, 1).toUpperCase() + 
                          category.substring(1),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isSelected 
                                ? Colors.white 
                                : const Color(0xFF718096),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}