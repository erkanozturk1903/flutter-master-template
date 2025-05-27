import '../models/welcome_message_model.dart';

abstract class HomeRemoteDataSource {
  Future<WelcomeMessageModel> getWelcomeMessage();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl({required this.apiClient});

  final dynamic apiClient; // Using dynamic to avoid circular import

  @override
  Future<WelcomeMessageModel> getWelcomeMessage() async {
    // Simulate API call - replace with real implementation
    await Future.delayed(const Duration(seconds: 1));
    
    return WelcomeMessageModel(
      title: 'Welcome!',
      message: 'Welcome to Flutter Master Template! 🚀\n\nThis is a production-ready Flutter application with:\n• Clean Architecture\n• BLoC State Management\n• Comprehensive Testing\n• Security Best Practices\n\nStart building amazing apps!',
      timestamp: DateTime.now(),
    );

    // Real API implementation would look like:
    // final response = await apiClient.get('/welcome');
    // return WelcomeMessageModel.fromJson(response.data);
  }
}
