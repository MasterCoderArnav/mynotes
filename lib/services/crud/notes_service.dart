import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

@immutable
class DatabaseUser{
  final int id;
  final String email;
  const DatabaseUser({required this.id, required this.email});
  DatabaseUser.fromRow(Map<String, Object?> map) : id = map[idColumn] as int,  email = map[emailColumn] as String;
  @override
  String toString()=> 'Person, ID = $id, email = $email';
  @override
  bool operator == (covariant DatabaseUser other) => id == other.id;
  @override
  int get hashCode => id.hashCode;
}

class DatabaseAlreadyOpenException implements Exception{}
class UnableToGetDocumentsDirectory implements Exception{}
class DatabaseNotOpenException implements Exception{}
class CouldNotDeleteUser implements Exception{}
class UserAlreadyExists implements Exception{}
class CouldNotGetUser implements Exception{}

class NoteService{
  Database? _db;
  Future<DatabaseUser> getUser({required String email}) async{
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,limit: 1,where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if(results.isEmpty){
      throw CouldNotGetUser();
    }
    else{
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async{
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if(results.isNotEmpty){
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async{
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(userTable, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if(deletedCount!=1){
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow(){
    final db = _db;
    if(db==null){
      throw DatabaseNotOpenException();
    }
    else{
      return db;
    }
  }

  Future<void> open() async{
    if(_db!=null){
      throw DatabaseAlreadyOpenException();
    }
    try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      await db.execute(createUserTable);
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException{
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async{
    if(_db==null){
      throw DatabaseNotOpenException();
    }
    else{
      final db = _db;
      await db!.close();
      _db = null;
    }
  }
}

class DatabaseNote{
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;
  const DatabaseNote({required this.id, required this.userId, required this.text, required this.isSyncedWithCloud});
  DatabaseNote.fromRow(Map<String, Object?> map) :
        id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedWithCloudColumn]) == 1 ? true : false;

  @override
  String toString() => 'Note, ID: $id, UserID: $userId, Text: $text, IsSyncedWithCloud: $isSyncedWithCloud';

  @override
  bool operator == (covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = ''' 
        CREATE TABLE IF NOT EXISTS "user" (
	        "id"	INTEGER NOT NULL,
        	"email"	TEXT NOT NULL UNIQUE,
	        PRIMARY KEY("id" AUTOINCREMENT)
        );''';
const createNoteTable = '''
        CREATE TABLE IF NOT EXISTS "note" (
	        "id"	INTEGER NOT NULL,
	        "user_id"	INTEGER NOT NULL,
	        "text"	TEXT,
	        "is_synced_with_cloud"	INTEGER DEFAULT 0,
	        PRIMARY KEY("id" AUTOINCREMENT)
        );''';