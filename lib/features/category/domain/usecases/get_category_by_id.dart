import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoryById implements UseCase<CategoryEntity, String> {
  final CategoryRepository repository;

  GetCategoryById(this.repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(String categoryId) {
    return repository.getCategoryById(categoryId);
  }
}
