import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _nombreBaseDatos = 'cafeteria_usuarios.db';
  static const String tablaUsuarios = 'usuarios';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _inicializarBaseDatos();
    return _database!;
  }

  Future<Database> _inicializarBaseDatos() async {
    final ruta = join(await getDatabasesPath(), _nombreBaseDatos);

    return openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tablaUsuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre_completo TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            telefono TEXT NOT NULL,
            password TEXT NOT NULL,
            tipo_usuario TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> registrarUsuario({
    required String nombreCompleto,
    required String email,
    required String telefono,
    required String password,
    required String tipoUsuario,
  }) async {
    final db = await database;
    return db.insert(
      tablaUsuarios,
      {
        'nombre_completo': nombreCompleto.trim(),
        'email': email.trim().toLowerCase(),
        'telefono': telefono.trim(),
        'password': password,
        'tipo_usuario': tipoUsuario,
      },
    );
  }

  Future<Map<String, dynamic>?> buscarUsuarioPorEmail(String email) async {
    final db = await database;
    final resultados = await db.query(
      tablaUsuarios,
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (resultados.isEmpty) return null;
    return resultados.first;
  }

  Future<Map<String, dynamic>?> validarCredenciales({
    required String email,
    required String password,
  }) async {
    final usuario = await buscarUsuarioPorEmail(email);
    if (usuario == null) return null;
    if (usuario['password'] != password) return null;
    return usuario;
  }
}
