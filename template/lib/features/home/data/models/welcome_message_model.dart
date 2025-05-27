import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/welcome_message.dart';

part 'welcome_message_model.g.dart';

@JsonSerializable()
class WelcomeMessageModel extends WelcomeMessage {
  const WelcomeMessageModel({
    required super.title,
    required super.message,
    required super.timestamp,
  });

  factory WelcomeMessageModel.fromJson(Map<String, dynamic> json) =>
      _$WelcomeMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$WelcomeMessageModelToJson(this);

  factory WelcomeMessageModel.fromEntity(WelcomeMessage entity) {
    return WelcomeMessageModel(
      title: entity.title,
      message: entity.message,
      timestamp: entity.timestamp,
    );
  }

  WelcomeMessage toEntity() {
    return WelcomeMessage(
      title: title,
      message: message,
      timestamp: timestamp,
    );
  }
}
