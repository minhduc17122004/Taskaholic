import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/lists_data.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<EditCategoryEvent>(_onEditCategory);
  }

  void _onLoadCategories(LoadCategoriesEvent event, Emitter<CategoryState> emit) {
    emit(CategoryLoading());
    
    try {
      final categories = ListsData.lists
          .where((category) => category != 'Danh sách tất cả')
          .toList();
      
      emit(CategoriesLoaded(categories));
    } catch (e) {
      developer.log('Lỗi khi tải danh mục: $e', name: 'CategoryBloc');
      emit(CategoryError('Không thể tải danh sách danh mục: $e'));
    }
  }

  void _onAddCategory(AddCategoryEvent event, Emitter<CategoryState> emit) {
    try {
      if (ListsData.lists.contains(event.name)) {
        emit(CategoryError('Danh mục "${event.name}" đã tồn tại'));
        return;
      }

      ListsData.lists.add(event.name);
      ListsData.listOptions.add(event.name);
      
      final categories = ListsData.lists
          .where((category) => category != 'Danh sách tất cả')
          .toList();
      
      emit(CategoriesLoaded(categories));
    } catch (e) {
      developer.log('Lỗi khi thêm danh mục: $e', name: 'CategoryBloc');
      emit(CategoryError('Không thể thêm danh mục: $e'));
    }
  }

  void _onDeleteCategory(DeleteCategoryEvent event, Emitter<CategoryState> emit) {
    try {
      // Không cho phép xóa các danh mục hệ thống
      if (event.name == 'Danh sách tất cả' || 
          event.name == 'Công việc' || 
          event.name == 'Mặc định') {
        emit(CategoryError('Không thể xóa danh mục hệ thống'));
        return;
      }

      ListsData.lists.remove(event.name);
      ListsData.listOptions.remove(event.name);
      
      final categories = ListsData.lists
          .where((category) => category != 'Danh sách tất cả')
          .toList();
      
      emit(CategoriesLoaded(categories));
    } catch (e) {
      developer.log('Lỗi khi xóa danh mục: $e', name: 'CategoryBloc');
      emit(CategoryError('Không thể xóa danh mục: $e'));
    }
  }

  void _onEditCategory(EditCategoryEvent event, Emitter<CategoryState> emit) {
    try {
      // Không cho phép chỉnh sửa các danh mục hệ thống
      if (event.oldName == 'Danh sách tất cả' || 
          event.oldName == 'Công việc' || 
          event.oldName == 'Mặc định') {
        emit(CategoryError('Không thể chỉnh sửa danh mục hệ thống'));
        return;
      }

      // Kiểm tra tên mới đã tồn tại chưa
      if (ListsData.lists.contains(event.newName)) {
        emit(CategoryError('Danh mục "${event.newName}" đã tồn tại'));
        return;
      }

      final oldIndex = ListsData.lists.indexOf(event.oldName);
      if (oldIndex != -1) {
        ListsData.lists[oldIndex] = event.newName;
        
        final optionsIndex = ListsData.listOptions.indexOf(event.oldName);
        if (optionsIndex != -1) {
          ListsData.listOptions[optionsIndex] = event.newName;
        }
        
        final categories = ListsData.lists
            .where((category) => category != 'Danh sách tất cả')
            .toList();
        
        emit(CategoriesLoaded(categories));
      } else {
        emit(CategoryError('Không tìm thấy danh mục "${event.oldName}"'));
      }
    } catch (e) {
      developer.log('Lỗi khi chỉnh sửa danh mục: $e', name: 'CategoryBloc');
      emit(CategoryError('Không thể chỉnh sửa danh mục: $e'));
    }
  }
} 