import 'choice.dart';
import 'usage.dart';

class ChatResponse {
  String? id;
  String? object;
  int? created;
  String? model;
  Usage? usage;
  List<Choice>? choices;

  ChatResponse({
    this.id,
    this.object,
    this.created,
    this.model,
    this.usage,
    this.choices,
  });

  @override
  String toString() {
    return 'ChatResponse(id: $id, object: $object, created: $created, model: $model, usage: $usage, choices: $choices)';
  }

  factory ChatResponse.fromJson(Map<String, dynamic> json) => ChatResponse(
        id: json['id'] as String?,
        object: json['object'] as String?,
        created: json['created'] as int?,
        model: json['model'] as String?,
        usage: json['usage'] == null
            ? null
            : Usage.fromJson(json['usage'] as Map<String, dynamic>),
        choices: (json['choices'] as List<dynamic>?)
            ?.map((e) => Choice.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'object': object,
        'created': created,
        'model': model,
        'usage': usage?.toJson(),
        'choices': choices?.map((e) => e.toJson()).toList(),
      };
}
