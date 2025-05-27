import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/welcome_message.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this.remoteDataSource,
  });

  final HomeRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, WelcomeMessage>> getWelcomeMessage() async {
    try {
      final remoteMessage = await remoteDataSource.getWelcomeMessage();
      return Right(remoteMessage.toEntity());
    } catch (e) {
      return const Left(
        ServerFailure(message: 'Failed to get welcome message'),
      );
    }
  }
}
