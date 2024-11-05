import 'package:flutter/material.dart';
import 'package:myapp/viewsmodel/project_list_viewmodel.dart';
import 'package:provider/provider.dart';
import 'notification/notificacion.dart';
import 'views/master_detail_view.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  tz.initializeTimeZones();

  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  runApp(MyApp(notificationsPlugin: notificationsPlugin));
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  const MyApp({super.key, required this.notificationsPlugin});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProjectListViewModel(notificationsPlugin),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gestión de Proyectos',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(title: const Text('Inicio')),
          body: MasterDetailView(),
        ),
      ),
    );
  }
}