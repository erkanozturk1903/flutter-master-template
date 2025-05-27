import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadWelcomeMessage extends HomeEvent {
  const LoadWelcomeMessage();
}

class RefreshWelcomeMessage extends HomeEvent {
  const RefreshWelcomeMessage();
}
