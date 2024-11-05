import 'package:flutter/material.dart';
import 'package:myapp/models/project.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/viewsmodel/project_list_viewmodel.dart';
import 'package:provider/provider.dart';

class ProjectDetailView extends StatefulWidget {
  @override
  _ProjectDetailViewState createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<ProjectDetailView> {
  String _selectedSortCriteria = 'date';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProjectListViewModel>(context);
    final project = viewModel.selectedProject;

    if (project == null) {
      return Center(child: Text('No se ha seleccionado ningún proyecto.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProjectDialog(context, viewModel, project),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              viewModel.deleteProject(project.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProjectInfoCard(project),
          _buildSearchAndSortOptions(viewModel),
          Expanded(
            child: _buildTaskList(viewModel),
          ),
          _buildCompletedTasksSection(viewModel),
          ElevatedButton(
            onPressed: () => _showAddTaskDialog(context, viewModel),
            child: const Text('Agregar Tarea'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfoCard(Project project) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Descripción: ${project.description}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Inicio: ${project.startDate.toLocal().toString().split(' ')[0]}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Fin: ${project.endDate.toLocal().toString().split(' ')[0]}', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndSortOptions(ProjectListViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Buscar tarea'),
              onChanged: (value) => viewModel.searchTasks(value),
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: _selectedSortCriteria,
            items: [
              DropdownMenuItem(value: 'date', child: Text('Fecha')),
              DropdownMenuItem(value: 'priority', child: Text('Prioridad')),
              DropdownMenuItem(value: 'status', child: Text('Estado')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedSortCriteria = value);
                viewModel.sortTasks(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(ProjectListViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.filteredTasks.length,
      itemBuilder: (context, index) {
        final task = viewModel.filteredTasks[index];
        return _buildTaskCard(context, viewModel, task);
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, ProjectListViewModel viewModel, Task task) {
    Color priorityColor = _getPriorityColor(task.priority);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descripción: ${task.description}'),
            Text('Fecha Límite: ${task.dueDate.toLocal().toString().split(' ')[0]}'),
            Text('Prioridad: ${task.priority}', style: TextStyle(color: priorityColor)),
          ],
        ),
        trailing: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            if (value != null) viewModel.markTaskAsCompleted(task.id);
          },
        ),
        onTap: () => _showEditTaskDialog(context, viewModel, task),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Alta':
        return Colors.red;
      case 'Media':
        return const Color.fromARGB(255, 255, 152, 0);
      case 'Baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCompletedTasksSection(ProjectListViewModel viewModel) {
    if (viewModel.completedTasks.isEmpty) return Container();

    return Column(
      children: [
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Tareas Completadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: viewModel.completedTasks.length,
          itemBuilder: (context, index) {
            final completedTask = viewModel.completedTasks[index];
            return ListTile(
              title: Text(completedTask.title),
              subtitle: Text('Completada el ${completedTask.dueDate.toLocal().toString().split(' ')[0]}'),
            );
          },
        ),
      ],
    );
  }

  void _showEditProjectDialog(BuildContext context, ProjectListViewModel viewModel, Project project) {
    final nameController = TextEditingController(text: project.name);
    final descriptionController = TextEditingController(text: project.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Proyecto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Descripción')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final updatedProject = Project(
                  id: project.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  startDate: project.startDate,
                  endDate: project.endDate,
                  tasks: project.tasks,
                );
                viewModel.updateProject(updatedProject);
                Navigator.pop(context);
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context, ProjectListViewModel viewModel) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDateTime = DateTime.now();
    String priority = 'Media';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Tarea'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Descripción')),
              DropdownButtonFormField<String>(
                value: priority,
                items: ['Alta', 'Media', 'Baja']
                    .map((priority) => DropdownMenuItem(value: priority, child: Text(priority)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Prioridad'),
                onChanged: (value) {
                  if (value != null) priority = value;
                },
              ),
              _buildDatePicker(context, selectedDateTime),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final newTask = Task(
                  id: DateTime.now().toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  dueDate: selectedDateTime,
                  priority: priority,
                );
                viewModel.addTaskToProject(newTask);
                viewModel.scheduleTaskReminder(newTask);
                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDatePicker(BuildContext context, DateTime selectedDateTime) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Fecha Límite',
        hintText: "${selectedDateTime.toLocal()}".split(' ')[0],
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDateTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != selectedDateTime) {
          setState(() {
            selectedDateTime = picked;
          });
        }
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, ProjectListViewModel viewModel, Task task) {
    // Implementar el diálogo para editar tareas
  }
}
