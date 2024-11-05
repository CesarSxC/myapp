import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../models/task.dart';

class ProjectListViewModel extends ChangeNotifier {
  List<Project> _projects = [];
  Project? _selectedProject;

  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;

  void loadProjects() {
    // Simulación de carga de datos
    _projects = [
      Project(
        id: '1',
        name: 'Proyecto 1',
        description: 'Descripción del Proyecto 1',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 30)),
        tasks: [],
      ),
    ];
    notifyListeners();
  }

  void selectProject(Project project) {
    _selectedProject = project;
    notifyListeners();
  }

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void addTaskToProject(Task task) {
    if (_selectedProject != null) {
      _selectedProject!.tasks.add(task);
      notifyListeners();
    }
  }

  void markTaskAsCompleted(String taskId) {
    if (_selectedProject != null) {
      final task = _selectedProject!.tasks.firstWhere((t) => t.id == taskId);
      task.isCompleted = true;
      notifyListeners();
    }
  }

  void deleteProject(String projectId) {
    _projects.removeWhere((project) => project.id == projectId);
    if (_selectedProject?.id == projectId) {
      _selectedProject = null; 
    }
    notifyListeners();
  }
  
}
