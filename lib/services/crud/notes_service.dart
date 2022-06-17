import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';

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

class NoteService{
  Database? _db;
  Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async{
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if(updateCount==0){
      throw CouldNotUpdateNote();
    }
    else{
      return await getNote(id: note.id);
    }
  }

  Future<List<DatabaseNote>> getAllNote() async{
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    if(notes.isEmpty){
      throw CouldNotGetNote();
    }
    else{
      return notes.map((n) => DatabaseNote.fromRow(n)).toList();
    }
  }

  Future<DatabaseNote> getNote({required int id}) async{
    final db = _getDatabaseOrThrow();
    final results = await db.query(noteTable, limit: 1, where: 'email = ?', whereArgs: [id]);
    if(results.isEmpty){
      throw CouldNotGetNote();
    }
    else{
      return DatabaseNote.fromRow(results.first);
    }
  }

  Future<void> deleteAllNote() async{
    final db = _getDatabaseOrThrow();
    db.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async{
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(noteTable, where: 'id=?', whereArgs: [id]);
    if(deletedCount==0){
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async{
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if(dbUser!=owner){
      throw CouldNotGetUser();
    }
    const text = '';
    final noteID = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });
    final note = DatabaseNote(id: noteID, userId: owner.id, text: text, isSyncedWithCloud: true);
    return note;
  }
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