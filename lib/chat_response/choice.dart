import 'message.dart';

class Choice {
  Message? message;
  String? finishReason;
  int? index;

  Choice({this.message, this.finishReason, this.index});

  @override
  String toString() {
    return 'Choice(message: $message, finishReason: $finishReason, index: $index)';
  }

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
        message: json['message'] == null
            ? null
            : Message.fromJson(json['message'] as Map<String, dynamic>),
        finishReason: json['finish_reason'] as String?,
        index: json['index'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'message': message?.toJson(),
        'finish_reason': finishReason,
        'index': index,
      };
}
