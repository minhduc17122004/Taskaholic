import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;
  final CategoryLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CategoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCategories = await remoteDataSource.getCategories();
        await localDataSource.saveCategories(remoteCategories);
        return Right(remoteCategories);
      } catch (e) {
        if (e is Failure) {
          return Left(e);
        }
        return const Left(ServerFailure(message: 'Lỗi server không xác định'));
      }
    } else {
      try {
        final localCategories = await localDataSource.getCategories();
        return Right(localCategories);
      } catch (e) {
        return const Left(CacheFailure(message: 'Lỗi khi đọc dữ liệu cục bộ'));
      }
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> addCategory(CategoryEntity category) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCategory = await remoteDataSource.addCategory(category.name);
        await localDataSource.addCategory(category.name);
        return Right(remoteCategory);
      } catch (e) {
        if (e is Failure) {
          return Left(e);
        }
        return const Left(ServerFailure(message: 'Lỗi khi thêm danh mục'));
      }
    } else {
      try {
        final localCategory = await localDataSource.addCategory(category.name);
        return Right(localCategory);
      } catch (e) {
        return const Left(CacheFailure(message: 'Lỗi khi thêm danh mục cục bộ'));
      }
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(CategoryEntity category) async {
    if (await networkInfo.isConnected) {
      try {
        final categoryModel = CategoryModel.fromEntity(category);
        final remoteCategory = await remoteDataSource.updateCategory(categoryModel);
        await localDataSource.updateCategory(categoryModel);
        return Right(remoteCategory);
      } catch (e) {
        if (e is Failure) {
          return Left(e);
        }
        return const Left(ServerFailure(message: 'Lỗi khi cập nhật danh mục'));
      }
    } else {
      try {
        final categoryModel = CategoryModel.fromEntity(category);
        final localCategory = await localDataSource.updateCategory(categoryModel);
        return Right(localCategory);
      } catch (e) {
        return const Left(CacheFailure(message: 'Lỗi khi cập nhật danh mục cục bộ'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteCategory(id);
        await localDataSource.deleteCategory(id);
        return const Right(null);
      } catch (e) {
        if (e is Failure) {
          return Left(e);
        }
        return const Left(ServerFailure(message: 'Lỗi khi xóa danh mục'));
      }
    } else {
      try {
        await localDataSource.deleteCategory(id);
        return const Right(null);
      } catch (e) {
        return const Left(CacheFailure(message: 'Lỗi khi xóa danh mục cục bộ'));
      }
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCategory = await remoteDataSource.getCategoryById(id);
        if (remoteCategory != null) {
          return Right(remoteCategory);
        } else {
          return const Left(NotFoundFailure(message: 'Không tìm thấy danh mục'));
        }
      } catch (e) {
        if (e is Failure) {
          return Left(e);
        }
        return const Left(ServerFailure(message: 'Lỗi khi lấy danh mục'));
      }
    } else {
      try {
        final localCategory = await localDataSource.getCategoryById(id);
        if (localCategory != null) {
          return Right(localCategory);
        } else {
          return const Left(NotFoundFailure(message: 'Không tìm thấy danh mục'));
        }
      } catch (e) {
        return const Left(CacheFailure(message: 'Lỗi khi đọc danh mục cục bộ'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> updateTaskCount(String categoryId, int taskCount) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateTaskCount(categoryId, taskCount);
        await localDataSource.updateTaskCount(categoryId, taskCount);
        return const Right(null);
      } catch (e) {
        if (e is Failure) {
          return Left(e);
        }
        return const Left(ServerFailure(message: 'Lỗi khi cập nhật số lượng công việc'));
      }
    } else {
      try {
        await localDataSource.updateTaskCount(categoryId, taskCount);
        return const Right(null);
      } catch (e) {
        return const Left(CacheFailure(message: 'Lỗi khi cập nhật số lượng công việc cục bộ'));
      }
    }
  }
}
