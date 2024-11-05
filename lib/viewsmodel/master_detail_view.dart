import 'package:flutter/material.dart';
import 'package:myapp/views/project_detail_view.dart';
import 'package:myapp/viewsmodel/project_list_viewmodel.dart';
import 'package:provider/provider.dart';

class MasterDetailView extends StatelessWidget {
  const MasterDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProjectListViewModel>(context);
    
    return Row(
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
    );
  }
}
