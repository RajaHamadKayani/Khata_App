import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'khata_users.db');

    var db = await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE KhataUsers(id INTEGER PRIMARY KEY, name TEXT, cnic TEXT)');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'CREATE TABLE KhataUsers_New(id INTEGER PRIMARY KEY, name TEXT, cnic TEXT)');
      await db.execute(
          'INSERT INTO KhataUsers_New (id, name, cnic) SELECT id, name, cnic FROM KhataUsers');
      await db.execute('DROP TABLE KhataUsers');
      await db.execute('ALTER TABLE KhataUsers_New RENAME TO KhataUsers');
    }
  }

  Future<int> saveCustomer(Map<String, dynamic> item) async {
    var dbClient = await db;
    var result = await dbClient.insert("KhataUsers", item);
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    var dbClient = await db;
    var result = await dbClient.query("KhataUsers");
    return result;
  }

  Future<int> deleteUser(int id) async {
    var dbClient = await db;
    return await dbClient.delete("KhataUsers", where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllUsers() async {
    var dbClient = await db;
    return await dbClient.delete("KhataUsers");
  }
}
