import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Para notificaciones locales
import '../models/project.dart';
import '../models/task.dart';
import 'package:timezone/timezone.dart' as tz;
import '../notification/notificacion.dart';
import '../models/custompriority.dart'; // Importa el nuevo modelo


class ProjectListViewModel extends ChangeNotifier {
  
  final FlutterLocalNotificationsPlugin notificationsPlugin;
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  List<Task> _completedTasks = [];

  ProjectListViewModel(this.notificationsPlugin);

  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get error => _error;
  List<Task> get completedTasks => _completedTasks;
  
  List<CustomPriority> _customPriorities = [
    CustomPriority(name: 'Alta', color: Colors.red),
    CustomPriority(name: 'Media', color: Color.fromARGB(255, 255, 152, 0)),
    CustomPriority(name: 'Baja', color: Colors.green),
  ];

  List<CustomPriority> get customPriorities => _customPriorities;

  void addCustomPriority(String name, Color color) {
    _customPriorities.add(CustomPriority(name: name, color: color));
    notifyListeners();
  }


  void loadProjects() {
    _isLoading = true;
    notifyListeners();

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

    _isLoading = false;
    notifyListeners();
  }

  void selectProject(Project project) {
    _selectedProject = project;
    notifyListeners();
  }

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
    NotificationService.showNotification("Listo!!", "Proyecto creado con exito");
  }

  void updateProject(Project updatedProject) {
    int index =
        _projects.indexWhere((project) => project.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
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

  void addTaskToProject(Task task) {
    if (_selectedProject != null) {
      _selectedProject!.tasks.add(task);
      if (task.dueDate.isAfter(DateTime.now())) {
        scheduleTaskReminder(task);
      } else {
        print('La fecha de vencimiento debe ser en el futuro');
      }
      notifyListeners();
      NotificationService.showNotification("Listo!!", "Tarea creada con exito");
    }
  }

  void updateTask(Task updatedTask) async {
    if (_selectedProject != null) {
      int index = _selectedProject!.tasks
          .indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        // Cancelar la notificación anterior
        await notificationsPlugin
            .cancel(_selectedProject!.tasks[index].id.hashCode);

        // Actualizar la tarea
        _selectedProject!.tasks[index] = updatedTask;

        // Programar una nueva notificación si la tarea tiene una fecha de vencimiento
        if (updatedTask.dueDate.isAfter(DateTime.now())) {
          scheduleTaskReminder(updatedTask);
        }

        notifyListeners();
      }
    }
  }

  void deleteTask(String taskId) async {
    if (_selectedProject != null) {
      int index =
          _selectedProject!.tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        // Cancelar la notificación programada para la tarea
        await notificationsPlugin
            .cancel(_selectedProject!.tasks[index].id.hashCode);
        _selectedProject!.tasks.removeAt(index);
        notifyListeners();
      }
    }
  }

  void markTaskAsCompleted(String taskId) {
    if (_selectedProject != null) {
      int index =
          _selectedProject!.tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _selectedProject!.tasks[index].isCompleted = true;
        _completedTasks.add(_selectedProject!.tasks[index]);
        notifyListeners();
      }
    }
  }

  void scheduleTaskReminder(Task task) async {
    if (task.dueDate.isAfter(DateTime.now())) {
      await notificationsPlugin.zonedSchedule(
        task.id.hashCode, // ID único para la tarea
        'Recordatorio de tarea: ${task.title}',
        task.description,
        tz.TZDateTime.from(
            task.dueDate, tz.local), // Asegúrate de que sea una fecha futura
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channelId', // Debe coincidir con el ID del canal creado
            'Channel Name',
            channelDescription: 'Description of the channel',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle:
            true, // Permitir notificaciones en modo de reposo
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      print(
          'No se puede programar una notificación porque la fecha es en el pasado.');
    }
  }

  void sortTasks(String criteria) {
    if (_selectedProject != null) {
      switch (criteria) {
        case 'date':
          _selectedProject!.tasks
              .sort((a, b) => a.dueDate.compareTo(b.dueDate));
          break;
        case 'priority':
          _selectedProject!.tasks
              .sort((a, b) => a.priority.compareTo(b.priority));
          break;
        case 'status':
          _selectedProject!.tasks.sort((a, b) => a.isCompleted ? 1 : -1);
          break;
      }
      notifyListeners();
    }
  }

  void searchTasks(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Task> get filteredTasks {
    if (_selectedProject != null) {
      return _selectedProject!.tasks
          .where((task) => task.title.contains(_searchQuery))
          .toList();
    }
    return [];
  }
}
