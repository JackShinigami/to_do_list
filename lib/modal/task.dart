class Task {
  final String id;
  final String name;
  final DateTime dateTime;
  final int notificationId;

  Task({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.notificationId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dateTime': dateTime.toIso8601String(),
        'notificationId': notificationId,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        name: json['name'],
        dateTime: DateTime.parse(json['dateTime']),
        notificationId: json['notificationId'],
      );
}