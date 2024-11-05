import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'project_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE projects (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            startDate TEXT NOT NULL,
            endDate TEXT NOT NULL,
            isSynced INTEGER DEFAULT 0
          )
        ''');
        
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            projectId TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            dueDate TEXT NOT NULL,
            isCompleted INTEGER DEFAULT 0,
            isSynced INTEGER DEFAULT 0,
            FOREIGN KEY (projectId) REFERENCES projects (id)
          )
        ''');
      },
    );
  }
}