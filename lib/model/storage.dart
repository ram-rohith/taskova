import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskova/model/task.dart';

class StorageClass {
  static const String _taskKey = 'users_tasks';

  static Future<bool> saveTasks(List<Task> tasks) async {
    final prefInst = await SharedPreferences.getInstance();
    final String jsonString = Task.encode(tasks);
    return await prefInst.setString(_taskKey, jsonString);
  }

  static Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final String? jsonString = prefs.getString(_taskKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    return Task.decode(jsonString);
  }
}
