import 'package:equatable/equatable.dart';

class WelcomeMessage extends Equatable {
  const WelcomeMessage({
    required this.title,
    required this.message,
    required this.timestamp,
  });

  final String title;
  final String message;
  final DateTime timestamp;

  @override
  List<Object> get props => [title, message, timestamp];
}
