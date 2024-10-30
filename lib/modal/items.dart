class DataItem {
  final String id;
  final String name;
  final DateTime dateTime;

  DataItem({required this.id, required this.name, required this.dateTime});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dateTime': dateTime.toIso8601String()
      };

  factory DataItem.fromJson(Map<String, dynamic> json) {
    return DataItem(
      id: json['id'],
      name: json['name'],
      dateTime: DateTime.parse(json['dateTime'])
    );
  }
}