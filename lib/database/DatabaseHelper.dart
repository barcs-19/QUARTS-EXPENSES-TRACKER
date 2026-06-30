import 'dart:math';

import 'package:path/path.dart';
import 'package:simple_login/EnvironmentVariable/DatabaseConstant.dart';
import 'package:simple_login/model/CravingsModel.dart';
import 'package:simple_login/model/ExpensesModel.dart';
import 'package:simple_login/model/ResourceModel.dart';
import 'package:simple_login/model/UserModel.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? database;
  static final String TABLE_ACCOUNT = "account";

  static Future<Database> get db async {
    if (database != null) return database!;
    database = await initDatabase();
    return database!;
  }

  static Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'user.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: createDatabase,
      onUpgrade: upgradeDatabase,
    );
  }

  static Future upgradeDatabase(Database db, int oldVer, int newVer) async {
    await db.execute('''
      DROP TABLE IF EXISTS ${DatabaseConstant.TABLE_ACCOUNT}
    ''');

    await db.execute('''
      DROP TABLE IF EXISTS ${DatabaseConstant.TABLE_RESOURCES}
    ''');

    await db.execute('''
      DROP TABLE IF EXISTS ${DatabaseConstant.TABLE_CRAVINGS}
    ''');

    await db.execute('''
      DROP TABLE IF EXISTS ${DatabaseConstant.TABLE_EXPENSES}
    ''');

    await createDatabase(db, newVer);
  }

  static Future createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstant.TABLE_ACCOUNT} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstant.COLUMN_ACCOUNT_USERNAME} TEXT NOT NULL,
      ${DatabaseConstant.COLUMN_ACCOUNT_PASSWORD} TEXT NOT NULL
      )
    ''');

    await db.execute('''
     CREATE TABLE IF NOT EXISTS ${DatabaseConstant.TABLE_RESOURCES} (
     resources_id INTEGER PRIMARY KEY AUTOINCREMENT,
     id INTEGER NOT NULL,
     ${DatabaseConstant.COLUMN_RESOURCES_TYPE} TEXT NOT NULL,
     ${DatabaseConstant.COLUMN_RESOURCES_BALANCE} INTEGER,
     FOREIGN KEY(id)
     REFERENCES ${DatabaseConstant.TABLE_ACCOUNT}(id)
     )
    ''');

    await db.execute('''
     CREATE TABLE IF NOT EXISTS ${DatabaseConstant.TABLE_CRAVINGS} (
     cravings_id INTEGER PRIMARY KEY AUTOINCREMENT,
     id INTEGER NOT NULL,
     ${DatabaseConstant.COLUMN_CRAVINGS_TITLE} TEXT NOT NULL,
     ${DatabaseConstant.COLUMN_CRAVINGS_LOCATION} TEXT,
     ${DatabaseConstant.COLUMN_CRAVINGS_AMOUNT} INTEGER NOT NULL,
     FOREIGN KEY(id)
     REFERENCES ${DatabaseConstant.TABLE_ACCOUNT}(id)
     )
    ''');

    await db.execute('''
     CREATE TABLE IF NOT EXISTS ${DatabaseConstant.TABLE_EXPENSES} (
     account_id INTEGER PRIMARY KEY AUTOINCREMENT,
     id INTEGER NOT NULL,
     resources_id INTEGER NOT NULL,
     ${DatabaseConstant.COLUMN_EXPENSES_TITLE} TEXT NOT NULL,
     ${DatabaseConstant.COLUMN_EXPENSES_LOCATION} TEXT,
     ${DatabaseConstant.COLUMN_EXPENSES_AMOUNT} INTEGER NOT NULL,
     ${DatabaseConstant.COLUMN_EXPENSES_DATE} TEXT NOT NULL,
     FOREIGN KEY(id)
     REFERENCES ${DatabaseConstant.TABLE_ACCOUNT}(id)
     FOREIGN KEY(resources_id)
     REFERENCES ${DatabaseConstant.TABLE_RESOURCES}(resources_id)
     )
    ''');
  }

  static Future<bool> DEDUCT_BALANCE(
    int user_id,
    int resources_id,
    double amount,
  ) async {
    final db = await DatabaseHelper.db;
    final result = await db.query(
      DatabaseConstant.TABLE_RESOURCES,
      where: 'id = ? AND resources_id = ?',
      whereArgs: [user_id, resources_id],
    );

    if (result.isEmpty) return false;
    double current_balance = (result.first['balance'] as num).toDouble();

    if (amount > current_balance) return false;
    double new_balance = current_balance - amount;

    await db.update(
      DatabaseConstant.TABLE_RESOURCES,
      {DatabaseConstant.COLUMN_RESOURCES_BALANCE: new_balance},
      where: 'id = ? AND resources_id = ?',
      whereArgs: [user_id, resources_id],
    );

    return true;
  }

  static Future<String> GET_RESOURCES_NAME(int resources_id) async {
    final db = await DatabaseHelper.db;
    final result = await db.query(
      DatabaseConstant.TABLE_RESOURCES,
      where: 'resources_id = ?',
      whereArgs: [resources_id],
    );
    return result.first['title'].toString();
  }

  static Future<int> UPDATE_RESOURCES_BALANCE(int resources_id, double newBalance,) async {
    final db = await DatabaseHelper.db;
    return await db.update(
      DatabaseConstant.TABLE_RESOURCES,
      {DatabaseConstant.COLUMN_RESOURCES_BALANCE: newBalance},
      where: 'resources_id = ?',
      whereArgs: [resources_id],
    );
  }

  static Future<List<ExpensesModel>> GET_ALL_EXPENSES(int user_id) async {
    final db = await DatabaseHelper.db;
    final result = await db.query(
      DatabaseConstant.TABLE_EXPENSES,
      where: 'id=?',
      whereArgs: [user_id],
      orderBy: 'date DESC',
    );
    return result.map((e) => ExpensesModel.fromMap(e)).toList();
  }

  static Future<int> CREATE_EXPENSES(ExpensesModel expenses) async {
    final db = await DatabaseHelper.db;
    return db.insert(DatabaseConstant.TABLE_EXPENSES, expenses.toMap());
  }

  static Future<int> CREATE_CRAVINGS(CravingsModel cravings) async {
    final db = await DatabaseHelper.db;
    return db.insert(DatabaseConstant.TABLE_CRAVINGS, cravings.toMap());
  }

  static Future<void> DELETE_CRAVINGS(int cravings_id) async {
    final db = await DatabaseHelper.db;
    db.delete(
      DatabaseConstant.TABLE_CRAVINGS,
      where: 'cravings_id = ?',
      whereArgs: [cravings_id],
    );
  }

  static Future<List<CravingsModel>> GET_ALL_CRAVINGS(int user_id) async {
    final db = await DatabaseHelper.db;
    final result = await db.query(
      DatabaseConstant.TABLE_CRAVINGS,
      where: 'id = ?',
      whereArgs: [user_id],
    );
    return result.map((e) => CravingsModel.fromMap(e)).toList();
  }

  static Future<void> INIT_RESOURCES(Resourcemodel resource) async {
    final db = await DatabaseHelper.db;
    db.insert(DatabaseConstant.TABLE_RESOURCES, resource.toMap());
  }

  static Future<int> CREATE_RESOURCES(Resourcemodel resources) async {
    final db = await DatabaseHelper.db;
    return db.insert(DatabaseConstant.TABLE_RESOURCES, resources.toMap());
  }

  static Future<List<Resourcemodel>> GET_RESOURCE(int user_id) async {
    final db = await DatabaseHelper.db;
    final result = await db.query(
      DatabaseConstant.TABLE_RESOURCES,
      where: 'id = ?',
      whereArgs: [user_id],
    );
    return result.map((e) => Resourcemodel.fromMap(e)).toList();
  }

  static Future<double> GET_TOTAL_BALANCE(int user_id) async {
    final db = await DatabaseHelper.db;
    final result = await db.rawQuery(
      '''
      SELECT SUM(${DatabaseConstant.COLUMN_RESOURCES_BALANCE}) as total
      FROM ${DatabaseConstant.TABLE_RESOURCES} 
      WHERE id = ?
    ''',
      [user_id],
    );
    return ((result.first["total"] ?? 0) as num).toDouble();
  }

  static Future<int> CREATE_USER(UserModel user) async {
    final db = await DatabaseHelper.db;
    return db.insert(DatabaseConstant.TABLE_ACCOUNT, user.toMap());
  }

  static Future<UserModel?> LOGIN_USER(String username, String password) async {
    final db = await DatabaseHelper.db;
    final result = await db.query(
      DatabaseConstant.TABLE_ACCOUNT,
      where:
          '${DatabaseConstant.COLUMN_ACCOUNT_USERNAME} = ? AND ${DatabaseConstant.COLUMN_ACCOUNT_PASSWORD} = ?',
      whereArgs: [username, password],
    );
    if (result.isEmpty) {
      return null;
    }
    return UserModel.fromMap(result.first);
  }
}
