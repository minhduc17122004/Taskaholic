import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  /// Lấy danh sách tất cả các danh mục
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  
  /// Thêm danh mục mới
  Future<Either<Failure, CategoryEntity>> addCategory(String name);
  
  /// Cập nhật danh mục
  Future<Either<Failure, CategoryEntity>> updateCategory(CategoryEntity category);
  
  /// Xóa danh mục
  Future<Either<Failure, void>> deleteCategory(String id);
  
  /// Lấy danh mục theo ID
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id);
  
  /// Cập nhật số lượng công việc trong danh mục
  Future<Either<Failure, void>> updateTaskCount(String categoryId, int taskCount);
} 