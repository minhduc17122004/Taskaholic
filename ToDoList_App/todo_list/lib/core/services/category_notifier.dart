import 'dart:async';
import 'dart:developer' as developer;

/// Service to notify UI components when categories are added, updated, or deleted
class CategoryNotifier {
  static final CategoryNotifier _instance = CategoryNotifier._internal();
  factory CategoryNotifier() => _instance;
  CategoryNotifier._internal();

  // Stream controller to broadcast category changes
  final _categoryChangesController = StreamController<CategoryChangeEvent>.broadcast();

  /// Stream of category changes that UI components can listen to
  Stream<CategoryChangeEvent> get categoryChanges => _categoryChangesController.stream;

  /// Notify that a category was added
  void notifyCategoryAdded(String categoryName) {
    developer.log('Notifying category added: $categoryName', name: 'CategoryNotifier');
    _categoryChangesController.add(CategoryChangeEvent(
      type: CategoryChangeType.added,
      categoryName: categoryName,
    ));
  }

  /// Notify that a category was updated/renamed
  void notifyCategoryUpdated(String oldName, String newName) {
    developer.log('Notifying category updated: $oldName -> $newName', name: 'CategoryNotifier');
    _categoryChangesController.add(CategoryChangeEvent(
      type: CategoryChangeType.updated,
      categoryName: newName,
      oldCategoryName: oldName,
    ));
  }

  /// Notify that a category was deleted
  void notifyCategoryDeleted(String categoryName) {
    developer.log('Notifying category deleted: $categoryName', name: 'CategoryNotifier');
    _categoryChangesController.add(CategoryChangeEvent(
      type: CategoryChangeType.deleted,
      categoryName: categoryName,
    ));
  }

  /// Dispose the notifier
  void dispose() {
    _categoryChangesController.close();
  }
}

/// Types of category changes
enum CategoryChangeType {
  added,
  updated,
  deleted,
}

/// Event representing a category change
class CategoryChangeEvent {
  final CategoryChangeType type;
  final String categoryName;
  final String? oldCategoryName;

  CategoryChangeEvent({
    required this.type,
    required this.categoryName,
    this.oldCategoryName,
  });

  @override
  String toString() {
    return 'CategoryChangeEvent{type: $type, categoryName: $categoryName, oldCategoryName: $oldCategoryName}';
  }
} 