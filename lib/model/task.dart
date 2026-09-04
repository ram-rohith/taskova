import 'dart:convert';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Task {
  final int hashedValue;
  final String id;
  final String title;
  final String description;
  DateTime? dateTime = DateTime.now();
  Task(this.title, this.description, {this.dateTime})
    : id = uuid.v4(),
      hashedValue = Object.hash(
        title,
        description,
        DateTime(
          dateTime!.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
        ),
      );

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': dateTime.toString(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      map['title'],
      map['description'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
  static String encode(List<Task> tasks) {
    List<Map<String, dynamic>> mappedVlues = tasks
        .map((task) => task.toMap())
        .toList();
    return jsonEncode(mappedVlues);
  }

  static List<Task> decode(String tasksJson) {
    final List<dynamic> decodedList = jsonDecode(tasksJson);
    return decodedList.map((item) => Task.fromMap(item)).toList();
  }
}
