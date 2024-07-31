import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelperAddProducts {
  static final DatabaseHelperAddProducts _instance = DatabaseHelperAddProducts.internal();
  factory DatabaseHelperAddProducts() => _instance;
  static Database? _db;

  DatabaseHelperAddProducts.internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'Khata_product.db');

    var db = await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE Khata_Products(id INTEGER PRIMARY KEY, name TEXT, quantity TEXT, price TEXT, customer_id INTEGER)'
    );
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE Khata_Products ADD COLUMN customer_id INTEGER'
      );
    }
  }

  Future<int> saveProduct(Map<String, dynamic> item) async {
    var dbClient = await db;
    var result = await dbClient.insert("Khata_Products", item);
    return result;
  }

  Future<List<Map<String, dynamic>>> getProductsByCustomer(int customerId) async {
    var dbClient = await db;
    var result = await dbClient.query(
      "Khata_Products",
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );
    return result;
  }

  Future<int> deleteProduct(int id) async {
    var dbClient = await db;
    return await dbClient.delete("Khata_Products", where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllProducts() async {
    var dbClient = await db;
    return await dbClient.delete("Khata_Products");
  }
  Future<int> updateProduct(int id, Map<String, dynamic> updatedProduct) async {
  var dbClient = await db;
  return await dbClient.update(
    "Khata_Products",
    updatedProduct,
    where: 'id = ?',
    whereArgs: [id],
  );
}

}
