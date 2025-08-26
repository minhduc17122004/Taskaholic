import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/category_repository.dart';

class DeleteCategory implements UseCase<void, String> {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  @override
  Future<Either<Failure, void>> call(String categoryId) {
    return repository.deleteCategory(categoryId);
  }
}
