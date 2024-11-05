import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../viewsmodel/project_list_viewmodel.dart';

void showAddCustomPriorityDialog(BuildContext context, ProjectListViewModel viewModel) {
  final titleController = TextEditingController();
  Color selectedColor = Colors.blue; // Color por defecto

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Agregar Prioridad Personalizada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // Mostrar el selector de color
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: SingleChildScrollView(
                        child: BlockPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (Color color) {
                            selectedColor = color; // Actualiza el color seleccionado
                            Navigator.of(context).pop(); // Cierra el diálogo
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: selectedColor,
                child: const Center(child: Text('Seleccionar Color')),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Agregar prioridad personalizada
              viewModel.addCustomPriority(titleController.text, selectedColor);
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      );
    },
  );
}

