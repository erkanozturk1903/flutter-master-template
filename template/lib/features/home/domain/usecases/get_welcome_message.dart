import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/welcome_message.dart';
import '../repositories/home_repository.dart';

class GetWelcomeMessage implements UseCase<WelcomeMessage, NoParams> {
  const GetWelcomeMessage(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, WelcomeMessage>> call(NoParams params) async {
    return await repository.getWelcomeMessage();
  }
}
