import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/category_local_datasource.dart';
import '../datasources/remote/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      developer.log('Đang lấy danh sách danh mục từ local', name: 'CategoryRepository');
      final localCategories = await localDataSource.getCategories();
      
      try {
        developer.log('Đang đồng bộ danh mục với Firestore', name: 'CategoryRepository');
        final remoteCategories = await remoteDataSource.getCategories();
        await localDataSource.cacheCategories(remoteCategories);
        developer.log('Đã đồng bộ và lấy ${remoteCategories.length} danh mục từ Firestore', name: 'CategoryRepository');
        return Right(remoteCategories);
      } catch (e) {
        developer.log('Lỗi khi đồng bộ danh mục với Firestore: $e, sử dụng dữ liệu local', name: 'CategoryRepository');
        return Right(localCategories);
      }
    } catch (e) {
      developer.log('Lỗi khi lấy danh sách danh mục: $e', name: 'CategoryRepository');
      return Left(ServerFailure(message: 'Không thể lấy danh sách danh mục: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(String id) async {
    try {
      developer.log('Đang lấy danh mục với ID $id', name: 'CategoryRepository');
      try {
        final remoteCategory = await remoteDataSource.getCategoryById(id);
        return Right(remoteCategory);
      } catch (e) {
        developer.log('Lỗi khi lấy danh mục từ Firestore: $e, thử lấy từ local', name: 'CategoryRepository');
        final localCategory = await localDataSource.getCategoryById(id);
        return Right(localCategory);
      }
    } catch (e) {
      developer.log('Lỗi khi lấy danh mục: $e', name: 'CategoryRepository');
      return Left(ServerFailure(message: 'Không thể lấy danh mục: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addCategory(Category category) async {
    try {
      developer.log('Đang thêm danh mục: ${category.name}', name: 'CategoryRepository');
      final categoryModel = CategoryModel.fromEntity(category);
      
      // Thêm vào local trước
      await localDataSource.addCategory(categoryModel);
      
      try {
        // Sau đó thêm vào remote
        await remoteDataSource.addCategory(categoryModel);
        developer.log('Đã thêm danh mục vào Firestore', name: 'CategoryRepository');
      } catch (e) {
        developer.log('Lỗi khi thêm danh mục vào Firestore: $e', name: 'CategoryRepository');
      }
      
      return const Right(unit);
    } catch (e) {
      developer.log('Lỗi khi thêm danh mục: $e', name: 'CategoryRepository');
      return Left(ServerFailure(message: 'Không thể thêm danh mục: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCategory(Category category) async {
    try {
      developer.log('Đang cập nhật danh mục: ${category.name}', name: 'CategoryRepository');
      final categoryModel = CategoryModel.fromEntity(category);
      
      // Cập nhật local trước
      await localDataSource.updateCategory(categoryModel);
      
      try {
        // Sau đó cập nhật remote
        await remoteDataSource.updateCategory(categoryModel);
        developer.log('Đã cập nhật danh mục trong Firestore', name: 'CategoryRepository');
      } catch (e) {
        developer.log('Lỗi khi cập nhật danh mục trong Firestore: $e', name: 'CategoryRepository');
      }
      
      return const Right(unit);
    } catch (e) {
      developer.log('Lỗi khi cập nhật danh mục: $e', name: 'CategoryRepository');
      return Left(ServerFailure(message: 'Không thể cập nhật danh mục: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String id) async {
    try {
      developer.log('Đang xóa danh mục với ID: $id', name: 'CategoryRepository');
      
      // Xóa từ local trước
      await localDataSource.deleteCategory(id);
      
      try {
        // Sau đó xóa từ remote
        await remoteDataSource.deleteCategory(id);
        developer.log('Đã xóa danh mục khỏi Firestore', name: 'CategoryRepository');
      } catch (e) {
        developer.log('Lỗi khi xóa danh mục khỏi Firestore: $e', name: 'CategoryRepository');
      }
      
      return const Right(unit);
    } catch (e) {
      developer.log('Lỗi khi xóa danh mục: $e', name: 'CategoryRepository');
      return Left(ServerFailure(message: 'Không thể xóa danh mục: $e'));
    }
  }
} 