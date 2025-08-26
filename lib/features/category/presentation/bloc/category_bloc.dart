import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/usecases.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories getCategories;
  final AddCategory addCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;

  List<CategoryEntity> _allCategories = [];

  CategoryBloc({
    required this.getCategories,
    required this.addCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<SearchCategoriesEvent>(_onSearchCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await getCategories(NoParams());
    
    result.fold(
      (failure) => emit(CategoryError(failure.toString())),
      (categories) {
        _allCategories = categories;
        emit(CategoriesLoaded(categories: categories));
      },
    );
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await addCategory(AddCategoryParams(category: event.category));
    
    result.fold(
      (failure) => emit(CategoryError(failure.toString())),
      (category) {
        _allCategories.add(category);
        emit(CategoryAdded(category));
        emit(CategoriesLoaded(categories: List.from(_allCategories)));
      },
    );
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await updateCategory(UpdateCategoryParams(category: event.category));
    
    result.fold(
      (failure) => emit(CategoryError(failure.toString())),
      (updatedCategory) {
        final index = _allCategories.indexWhere((cat) => cat.id == updatedCategory.id);
        if (index != -1) {
          _allCategories[index] = updatedCategory;
        }
        emit(CategoryUpdated(updatedCategory));
        emit(CategoriesLoaded(categories: List.from(_allCategories)));
      },
    );
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await deleteCategory(event.categoryId);
    
    result.fold(
      (failure) => emit(CategoryError(failure.toString())),
      (_) {
        _allCategories.removeWhere((cat) => cat.id == event.categoryId);
        emit(CategoryDeleted(event.categoryId));
        emit(CategoriesLoaded(categories: List.from(_allCategories)));
      },
    );
  }

  void _onSearchCategories(
    SearchCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) {
    if (event.query.isEmpty) {
      emit(CategoriesLoaded(categories: _allCategories));
      return;
    }

    final filteredCategories = _allCategories
        .where((category) =>
            category.name.toLowerCase().contains(event.query.toLowerCase()))
        .toList();

    emit(CategoriesLoaded(
      categories: _allCategories,
      filteredCategories: filteredCategories,
    ));
  }
}
