class CategoryConstants {
  static const Map<String, String> categories = {
    'groceries': '🛒',
    'entertainment': '🎬',
    'transportation': '🚗',
    'rent': '🏠',
    'utilities': '⚡',
    'healthcare': '🏥',
    'education': '📚',
    'shopping': '🛍️',
    'food': '🍕',
    'travel': '✈️',
    'fitness': '💪',
    'beauty': '💄',
    'gifts': '🎁',
    'charity': '❤️',
    'business': '💼',
    'technology': '💻',
    'subscriptions': '📺',
    'insurance': '🛡️',
    'taxes': '📊',
    'other': '📝',
  };

  static const Map<String, String> categoryColors = {
    'groceries': '0xFF4CAF50',
    'entertainment': '0xFFE91E63',
    'transportation': '0xFF2196F3',
    'rent': '0xFF795548',
    'utilities': '0xFFFF9800',
    'healthcare': '0xFFF44336',
    'education': '0xFF9C27B0',
    'shopping': '0xFFE91E63',
    'food': '0xFFFF5722',
    'travel': '0xFF00BCD4',
    'fitness': '0xFF8BC34A',
    'beauty': '0xFFE91E63',
    'gifts': '0xFFFFC107',
    'charity': '0xFF4CAF50',
    'business': '0xFF607D8B',
    'technology': '0xFF3F51B5',
    'subscriptions': '0xFF9C27B0',
    'insurance': '0xFF795548',
    'taxes': '0xFF757575',
    'other': '0xFF9E9E9E',
  };

  static List<String> get categoryNames => categories.keys.toList();
  
  static String getCategoryIcon(String category) {
    return categories[category.toLowerCase()] ?? categories['other']!;
  }
  
  static String getCategoryColor(String category) {
    return categoryColors[category.toLowerCase()] ?? categoryColors['other']!;
  }
}