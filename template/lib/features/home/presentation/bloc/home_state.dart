import 'package:equatable/equatable.dart';

import '../../domain/entities/welcome_message.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({required this.welcomeMessage});

  final WelcomeMessage welcomeMessage;

  @override
  List<Object> get props => [welcomeMessage];
}

class HomeError extends HomeState {
  const HomeError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}
