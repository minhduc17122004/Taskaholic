import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/usecases/update_tasks_category.dart';
import '../../../data/lists_data.dart';
import '../../../core/constants/category_constants.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/category_notifier.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;
  final CategoryService _categoryService;
  final UpdateTasksCategory _updateTasksCategory;
  final CategoryNotifier _categoryNotifier;
  
  // Hot Reload safety flag
  bool _isDisposed = false;

  CategoryBloc({
    required this.categoryRepository,
    required CategoryService categoryService,
    required UpdateTasksCategory updateTasksCategory,
    required CategoryNotifier categoryNotifier,
  }) : _categoryService = categoryService,
       _updateTasksCategory = updateTasksCategory,
       _categoryNotifier = categoryNotifier,
       super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<EditCategoryEvent>(_onEditCategory);
    on<SearchCategoriesEvent>(_onSearchCategories);
    
    // Initialize with safe state
    _initializeSafely();
  }
  
  /// Initialize with Hot Reload safety
  void _initializeSafely() {
    try {
      developer.log('CategoryBloc initialized', name: 'CategoryBloc');
    } catch (e) {
      developer.log('Error during CategoryBloc initialization: $e', name: 'CategoryBloc');
    }
  }
  
  /// Safe emit that checks if bloc is still active
  void _safeEmit(CategoryState state, Emitter<CategoryState> emit) {
    if (!_isDisposed && !isClosed) {
      try {
        emit(state);
      } catch (e) {
        developer.log('Error emitting state: $e', name: 'CategoryBloc');
      }
    }
  }
  
  @override
  Future<void> close() {
    _isDisposed = true;
    developer.log('🔒 CategoryBloc disposed', name: 'CategoryBloc');
    return super.close();
  }

  Future<void> _onLoadCategories(LoadCategoriesEvent event, Emitter<CategoryState> emit) async {
    // Hot Reload safety check
    if (_isDisposed || isClosed) {
      developer.log('Attempted to load categories on disposed bloc', name: 'CategoryBloc');
      return;
    }
    
    _safeEmit(CategoryLoading(), emit);
    
    try {
      developer.log('Loading categories...', name: 'CategoryBloc');
      
      // Get categories from repository (Firebase + local)
      final result = await categoryRepository.getCategories();
      
      await result.fold(
        (failure) async {
          developer.log('Failed to load categories from repository: ${failure.message}', name: 'CategoryBloc');
          
          // Fallback to category service (local + defaults)
          final selectableCategories = _categoryService.getSelectableCategories()
              .map((cat) => cat.name)
              .where((name) => name != CategoryConstants.completedCategoryName && name != CategoryConstants.allTasksCategoryName)
              .toList();
          
          developer.log('Loaded ${selectableCategories.length} categories from fallback', name: 'CategoryBloc');
          _safeEmit(CategoriesLoaded(selectableCategories), emit);
        },
        (categories) async {
          // Filter out system categories for display
          final customCategories = categories
              .where((cat) => !cat.isSystem && cat.name != CategoryConstants.completedCategoryName)
              .map((cat) => cat.name)
              .toList();
          
          // Get default categories
          final defaultCategoryNames = CategoryConstants.getSelectableCategories()
              .map((cat) => cat.name)
              .toList();
          
          // Combine categories with custom categories first (at the top)
          final displayCategories = <String>[];
          displayCategories.addAll(customCategories); // Custom categories first
          
          // Add default categories that might not be in Firebase yet
          for (final defaultName in defaultCategoryNames) {
            if (!displayCategories.contains(defaultName)) {
              displayCategories.add(defaultName);
            }
          }
          
          // Update ListsData for backward compatibility
          _updateListsData(displayCategories);
          
          developer.log('Loaded ${displayCategories.length} categories successfully', name: 'CategoryBloc');
          _safeEmit(CategoriesLoaded(displayCategories), emit);
        },
      );
    } catch (e) {
      developer.log('Error loading categories: $e', name: 'CategoryBloc');
      _safeEmit(CategoryError('Không thể tải danh sách danh mục: $e'), emit);
    }
  }

  Future<void> _onAddCategory(AddCategoryEvent event, Emitter<CategoryState> emit) async {
    // Hot Reload safety check
    if (_isDisposed || isClosed) {
      developer.log('Attempted to add category on disposed bloc', name: 'CategoryBloc');
      return;
    }
    
    // Store current state for potential rollback
    final currentState = state;
    
    try {
      developer.log('Adding new category: ${event.name}', name: 'CategoryBloc');
      
      // Validate category name
      if (event.name.trim().isEmpty) {
        _safeEmit(CategoryError('Tên danh mục không được để trống'), emit);
        return;
      }
      
      // Check if category already exists
      final existingCategories = _categoryService.getSelectableCategoryNames();
      if (existingCategories.contains(event.name.trim())) {
        _safeEmit(CategoryError('Danh mục "${event.name.trim()}" đã tồn tại'), emit);
        return;
      }
      
      // Check if it's a system category name
      if (event.name.trim() == CategoryConstants.completedCategoryName ||
          event.name.trim() == CategoryConstants.allTasksCategoryName) {
        _safeEmit(CategoryError('Không thể tạo danh mục với tên hệ thống'), emit);
        return;
      }
      // Basic color default and validation can be extended when color picker exists

      // Emit loading state
      _safeEmit(CategoryLoading(), emit);
      
      // Create new category entity
      final now = DateTime.now();
      final newCategory = Category(
        id: 'custom_${now.millisecondsSinceEpoch}',
        name: event.name.trim(),
        color: '#607D8B', // Default color
        isSystem: false,
        userId: 'current_user', // TODO: Get from auth service
        createdAt: now,
        updatedAt: now,
      );
      
      // Add to local service immediately for optimistic update
      final categoryInfo = CategoryInfo(
        id: newCategory.id,
        name: newCategory.name,
        color: newCategory.color,
        icon: Icons.folder,
        isSystem: newCategory.isSystem,
      );
      _categoryService.addCustomCategory(categoryInfo);
      
      // Update ListsData legacy lists for backward compatibility only
      // Note: Don't call ListsData.addCustomCategory as it also calls _categoryService.addCustomCategory (causing duplicates)
      if (!ListsData.lists.contains(newCategory.name)) {
        ListsData.lists.insert(0, newCategory.name);
        ListsData.listOptions.insert(0, newCategory.name);
      }
      
      // Optimistic update: Add category to current list immediately (at the beginning)
      if (currentState is CategoriesLoaded) {
        final updatedCategories = List<String>.from(currentState.categories);
        updatedCategories.insert(0, event.name.trim()); // Insert at beginning instead of end
        _safeEmit(CategoriesLoaded(updatedCategories), emit);
      }
      
      // Add to repository (Firebase)
      final result = await categoryRepository.addCategory(newCategory);
      
      await result.fold(
        (failure) async {
          developer.log('Failed to add category to Firebase: ${failure.message}', name: 'CategoryBloc');
          
          // Category already added optimistically to service and ListsData
          // Just save to local storage
          await ListsData.saveCustomCategories();
          
          // Category already added optimistically, just show warning
          developer.log('Category added locally but not synced to server', name: 'CategoryBloc');
          
          // Notify all forms about new category
          _categoryNotifier.notifyCategoryAdded(newCategory.name);
          
          // Keep CategoriesLoaded state; UI already updated optimistically
        },
        (_) async {
          developer.log('Category added to Firebase successfully', name: 'CategoryBloc');
          
          // Category already added optimistically to service and ListsData
          // Just save to local storage
          await ListsData.saveCustomCategories();
          
          // Category already added optimistically, operation complete
          developer.log('Category operation completed successfully', name: 'CategoryBloc');
          
          // Notify all forms about new category
          _categoryNotifier.notifyCategoryAdded(newCategory.name);
          
          // Keep CategoriesLoaded state; UI already updated optimistically
        },
      );
    } catch (e) {
      developer.log('Error adding category: $e', name: 'CategoryBloc');
      _safeEmit(CategoryError('Không thể thêm danh mục: $e'), emit);
    }
  }

  Future<void> _onDeleteCategory(DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    // Store current state for potential rollback
    final currentState = state;
    
    try {
      developer.log('🗑️ Deleting category: ${event.name}', name: 'CategoryBloc');
      
      // Check if it's a system category (ONLY system categories cannot be deleted)
      final category = _categoryService.getCategoryByName(event.name);
      if (category != null && category.isSystem) {
        emit(CategoryError('Không thể xóa danh mục hệ thống'));
        return;
      }
      
      // Additional checks for system categories only
      if (event.name == CategoryConstants.completedCategoryName || 
          event.name == CategoryConstants.allTasksCategoryName) {
        emit(CategoryError('Không thể xóa danh mục hệ thống'));
        return;
      }
      
      // Optimistic update: Remove category from current list immediately (no loading state)
      if (currentState is CategoriesLoaded) {
        final updatedCategories = List<String>.from(currentState.categories);
        updatedCategories.remove(event.name);
        emit(CategoriesLoaded(updatedCategories));
      }
      
      if (category != null) {
        // Delete from repository (Firebase)
        final result = await categoryRepository.deleteCategory(category.id);
        
        await result.fold(
          (failure) async {
            developer.log('Failed to delete category from Firebase: ${failure.message}', name: 'CategoryBloc');
            emit(CategoryError('Không thể xóa danh mục từ server: ${failure.message}'));
          },
          (_) async {
            developer.log('Category deleted from Firebase successfully', name: 'CategoryBloc');
            
            // Remove from local service
            _categoryService.removeCustomCategory(category.id);
            
            // Update ListsData for backward compatibility
            ListsData.removeCustomCategory(event.name);
            
            // Save to local storage
            await ListsData.saveCustomCategories();
            
            // Category already removed optimistically, operation complete
            developer.log('Category delete operation completed successfully', name: 'CategoryBloc');
          },
        );
      } else {
        // If not found in service, try to remove from legacy lists
        ListsData.removeCustomCategory(event.name);
        // Category already removed optimistically, operation complete
        developer.log('Category delete from legacy lists completed', name: 'CategoryBloc');
      }
    } catch (e) {
      developer.log('Error deleting category: $e', name: 'CategoryBloc');
      emit(CategoryError('Không thể xóa danh mục: $e'));
    }
  }

  Future<void> _onEditCategory(EditCategoryEvent event, Emitter<CategoryState> emit) async {
    // Store current state for potential rollback
    final currentState = state;
    
    try {
      developer.log(' Editing category: ${event.oldName} -> ${event.newName}', name: 'CategoryBloc');
      
      // Validate new name
      if (event.newName.trim().isEmpty) {
        emit(CategoryError('Tên danh mục không được để trống'));
        return;
      }
      
      // Check if it's a system category (ONLY system categories cannot be edited)
      final oldCategory = _categoryService.getCategoryByName(event.oldName);
      if (oldCategory != null && oldCategory.isSystem) {
        emit(CategoryError('Không thể chỉnh sửa danh mục hệ thống'));
        return;
      }
      
      // Additional checks for system categories only
      if (event.oldName == CategoryConstants.completedCategoryName || 
          event.oldName == CategoryConstants.allTasksCategoryName) {
        emit(CategoryError('Không thể chỉnh sửa danh mục hệ thống'));
        return;
      }
      
      // Check if new name already exists
      final existingCategories = _categoryService.getSelectableCategoryNames();
      if (existingCategories.contains(event.newName.trim()) && event.newName.trim() != event.oldName) {
        emit(CategoryError('Danh mục "${event.newName.trim()}" đã tồn tại'));
        return;
      }
      if (event.newName.trim() == CategoryConstants.completedCategoryName ||
          event.newName.trim() == CategoryConstants.allTasksCategoryName) {
        emit(CategoryError('Không thể đổi tên thành tên hệ thống'));
        return;
      }
      
      // Optimistic update: Replace old name with new name in current list immediately (no loading state)
      if (currentState is CategoriesLoaded) {
        final updatedCategories = List<String>.from(currentState.categories);
        final index = updatedCategories.indexOf(event.oldName);
        if (index != -1) {
          updatedCategories[index] = event.newName.trim();
          emit(CategoriesLoaded(updatedCategories));
        }
      }
      
      if (oldCategory != null) {
        // Create updated category
        final updatedCategory = Category(
          id: oldCategory.id,
          name: event.newName.trim(),
          color: oldCategory.color,
          isSystem: oldCategory.isSystem,
          userId: 'current_user', // TODO: Get from auth service
          createdAt: DateTime.now(), // Remote layer will preserve original createdAt
          updatedAt: DateTime.now(),
        );
        
        // Update in repository (Firebase)
        final result = await categoryRepository.updateCategory(updatedCategory);
        
        await result.fold(
          (failure) async {
            developer.log('Failed to update category in Firebase: ${failure.message}', name: 'CategoryBloc');
            emit(CategoryError('Không thể cập nhật danh mục: ${failure.message}'));
          },
          (_) async {
            developer.log('Category updated in Firebase successfully', name: 'CategoryBloc');
            
            // Update all tasks that belong to this category
            developer.log('Updating all tasks with new category name: ${event.oldName} -> ${event.newName}', name: 'CategoryBloc');
            try {
              final updateTasksResult = await _updateTasksCategory(
                UpdateTasksCategoryParams(
                  oldCategoryName: event.oldName,
                  newCategoryName: event.newName.trim(),
                ),
              );
              
              await updateTasksResult.fold(
                (failure) async {
                  developer.log('Failed to update tasks category: ${failure.message}', name: 'CategoryBloc');
                  // Continue with category update even if task update fails
                },
                (_) async {
                  developer.log('Successfully updated all tasks with new category name', name: 'CategoryBloc');
                },
              );
            } catch (e) {
              developer.log('Error updating tasks category: $e', name: 'CategoryBloc');
              // Continue with category update even if task update fails
            }
            
            // Update local service
            _categoryService.removeCustomCategory(oldCategory.id);
            final updatedCategoryInfo = CategoryInfo(
              id: updatedCategory.id,
              name: updatedCategory.name,
              color: updatedCategory.color,
              icon: Icons.folder,
              isSystem: updatedCategory.isSystem,
            );
            _categoryService.addCustomCategory(updatedCategoryInfo);
            
            // Update ListsData for backward compatibility
            final index = ListsData.lists.indexOf(event.oldName);
            if (index != -1) {
              ListsData.lists[index] = event.newName;
            }
            final optionsIndex = ListsData.listOptions.indexOf(event.oldName);
            if (optionsIndex != -1) {
              ListsData.listOptions[optionsIndex] = event.newName;
            }
            
            // Save to local storage
            await ListsData.saveCustomCategories();
            
            // Category already updated optimistically, operation complete
            developer.log('Category edit operation completed successfully', name: 'CategoryBloc');
            
            // Notify all forms about category rename
            _categoryNotifier.notifyCategoryUpdated(event.oldName, event.newName.trim());
            
            // Emit success to allow other parts (e.g., Task UI) to refresh
            _safeEmit(const CategoryUpdated('Đã cập nhật danh mục thành công'), emit);
          },
        );
      } else {
        emit(CategoryError('Không tìm thấy danh mục "${event.oldName}"'));
      }
    } catch (e) {
      developer.log('Error editing category: $e', name: 'CategoryBloc');
      emit(CategoryError('Không thể chỉnh sửa danh mục: $e'));
    }
  }

  /// Update ListsData for backward compatibility
  void _updateListsData(List<String> categories) {
    // Clear existing custom categories
    ListsData.lists.removeWhere((cat) => 
        cat != CategoryConstants.allTasksCategoryName && 
        !CategoryConstants.getSelectableCategories().any((defaultCat) => defaultCat.name == cat));
    
    ListsData.listOptions.removeWhere((cat) => 
        cat != CategoryConstants.allTasksCategoryName && 
        !CategoryConstants.getSelectableCategories().any((defaultCat) => defaultCat.name == cat));
    
    // Add current categories
    for (final category in categories) {
      if (!ListsData.lists.contains(category)) {
        ListsData.lists.add(category);
      }
      if (!ListsData.listOptions.contains(category)) {
        ListsData.listOptions.add(category);
      }
    }
  }

  /// Handle search categories event
  void _onSearchCategories(SearchCategoriesEvent event, Emitter<CategoryState> emit) {
    try {
      if (state is CategoriesLoaded) {
        final currentState = state as CategoriesLoaded;
        final allCategories = currentState.categories;
        
        if (event.query.isEmpty) {
          emit(CategoriesLoaded(allCategories));
        } else {
          final filteredCategories = allCategories
              .where((category) => category.toLowerCase().contains(event.query.toLowerCase()))
              .toList();
          emit(CategoriesLoaded(filteredCategories));
        }
      }
    } catch (e) {
      developer.log('Error searching categories: $e', name: 'CategoryBloc');
      emit(CategoryError('Không thể tìm kiếm danh mục: $e'));
    }
  }
} 