
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import '../../models/compressImageModel.dart';

class DatabaseHelper{

  late Database _database;

  Future<Database> initDatabase()async{
    final databasePath = getDatabasesPath();
    final finalPath = path.join(databasePath.toString(),'ImageDatabase.db');

    return await openDatabase(
      finalPath,
      version: 1,
      onCreate: (db, version) async{

        await db.execute('''
        CREATE TABLE IMAGES(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filePath TEXT,
        originalSize REAL,
        compressedSize REAL,
        compressedAt TEXT,
        format TEXT,
        isCompressed INT
        )''');
      },);
  }

  Future<List<CompressedImage>> fetchImagesfromDatabase() async{
    final db = await initDatabase();
    final res = await db.rawQuery('''SELECT * FROM IMAGES''');

    var temp = res.map((e) => CompressedImage.fromMap(e),).toList();

    return temp;
  }

  Future<void> addImage(CompressedImage imageData) async{
    final db = await initDatabase();
    db.insert('IMAGES', imageData.toMap());
    fetchImagesfromDatabase();
  }

  Future<void> deleteImage(String filePath) async{
    final db = await initDatabase();
    await db.delete('IMAGES',where: 'filePath = ?',whereArgs: [filePath]);
    print('deleted image having filePath = $filePath');
    fetchImagesfromDatabase();
  }

}