import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'user_transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'expense_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            title TEXT,
            amount REAL
          )
        ''');
      },
    );
  }

  Future<void> insertTransaction(UserTransaction transaction) async {
    final db = await database;
    await db!.insert('transactions', transaction.toMap());
  }

  Future<List<UserTransaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('transactions');

    return List.generate(maps.length, (index) {
      return UserTransaction(
        id: maps[index]['id'],
        title: maps[index]['title'],
        amount: maps[index]['amount'],
      );
    });
  }

  Future<double> calculateTotalAmount() async {
    final db = await database;
    final result = await db!.rawQuery('SELECT SUM(amount) as totalAmount FROM transactions');
    final totalAmount = result.first['totalAmount'] as double;
    return totalAmount;
  }

  Future<void> updateTransaction(UserTransaction transaction) async {
    final db = await database;
    await db!.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }
  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db!.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
