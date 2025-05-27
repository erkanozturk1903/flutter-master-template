import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/welcome_message.dart';

abstract class HomeRepository {
  Future<Either<Failure, WelcomeMessage>> getWelcomeMessage();
}
