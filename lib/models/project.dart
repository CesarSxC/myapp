import 'task.dart';

class Project {
  String id;
  String name;
  String description;
  DateTime startDate;
  DateTime endDate;
  List<Task> tasks;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.tasks,
  });
}
