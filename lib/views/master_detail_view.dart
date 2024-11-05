import 'package:flutter/material.dart';
import 'package:myapp/models/project.dart';
import 'package:myapp/views/dialogpriority.dart';
import 'package:myapp/viewsmodel/project_list_viewmodel.dart';
import 'package:provider/provider.dart';
import 'project_detail_view.dart';

class MasterDetailView extends StatelessWidget {
  const MasterDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProjectListViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddProjectDialog(context, viewModel);
            },
          ),
          IconButton(
            icon: const Icon(Icons.star), // Cambia el icono si lo deseas
            onPressed: () {
              showAddCustomPriorityDialog(context, viewModel); // Llama a la función del diálogo
            },
          ),
        ],
        
      ),
      body: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.projects.length,
              itemBuilder: (context, index) {
                final project = viewModel.projects[index];
                return ListTile(
                  title: Text(project.name),
                  onTap: () {
                    viewModel.selectProject(project);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailView(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context, ProjectListViewModel viewModel) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Proyecto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Proyecto'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                  final newProject = Project(
                    id: DateTime.now().toString(),
                    name: nameController.text,
                    description: descriptionController.text,
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(const Duration(days: 30)),
                    tasks: [],
                  );
                  viewModel.addProject(newProject);
                  Navigator.pop(context);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}
