import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Administrador'),
            accountEmail: const Text('administrador@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(child: Image.asset('image/1366_2000.jpg')),
            ),
            decoration: const BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              // Aquí puedes navegar a la página principal o realizar alguna acción
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Proyectos'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              // Navegar a la vista de proyectos
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_turned_in_outlined),
            title: const Text('Tareas Completas'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              // Navegar a la vista de tareas completadas
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_road_outlined),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              // Navegar a la vista de configuración
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              // Navegar a la vista de perfil
            },
          )
        ],
      ),
    );
  }
}
