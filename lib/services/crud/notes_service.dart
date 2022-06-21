// import 'dart:async';
// import 'package:flutter/widgets.dart';
// import 'package:mynotes/extensions/filter_extension.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart' show join;
// import 'crud_exceptions.dart';
//
// @immutable
// class DatabaseUser{
//   final int id;
//   final String email;
//   const DatabaseUser({required this.id, required this.email});
//   DatabaseUser.fromRow(Map<String, Object?> map) : id = map[idColumn] as int,  email = map[emailColumn] as String;
//   @override
//   String toString()=> 'Person, ID = $id, email = $email';
//   @override
//   bool operator == (covariant DatabaseUser other) => id == other.id;
//   @override
//   int get hashCode => id.hashCode;
// }
//
// class NoteService{
//   Database? _db;
//   DatabaseUser? _user;
//   static final NoteService _shared = NoteService._sharedInstance();
//   NoteService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }
//   factory NoteService() => _shared;
//
//   Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream.filter((note){
//     final currentUser = _user;
//     if(currentUser!=null){
//       return note.userId == currentUser.id;
//     }
//     else{
//       throw UserShouldBeSetBeforeReadingNotes();
//     }
//   });
//
//   Future<DatabaseUser> getOrCreateUser({required String email, bool setAsCurrentUser = true}) async{
//     try {
//       final user = await getUser(email: email);
//       if(setAsCurrentUser){
//         _user = user;
//       }
//       return user;
//     }
//     on CouldNotGetUser{
//       final createNewUser = await createUser(email: email);
//       if(setAsCurrentUser){
//         _user = createNewUser;
//       }
//       return createNewUser;
//     }
//     catch (e){
//       rethrow;
//     }
//   }
//
//   List<DatabaseNote> _notes = [];
//
//   // final _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();
//   late final StreamController<List<DatabaseNote>> _notesStreamController;
//   Future<void> _cacheNotes() async{
//     final allNotes = await getAllNote();
//     _notes = allNotes;
//     _notesStreamController.add(_notes);
//   }
//
//   Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async{
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     await getNote(id: note.id);
//     final updateCount = await db.update(noteTable, {
//       textColumn: text,
//       isSyncedWithCloudColumn: 0,
//     }, where: "id = ?", whereArgs: [note.id]);
//     if(updateCount==0){
//       throw CouldNotUpdateNote();
//     }
//     else{
//       final updateNote =  await getNote(id: note.id);
//       _notes.removeWhere((note) => updateNote.id==note.id);
//       _notes.add(updateNote);
//       _notesStreamController.add(_notes);
//       return updateNote;
//     }
//   }
//
//   Future<List<DatabaseNote>> getAllNote() async{
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(noteTable);
//     final result = notes.map((noteRow) => DatabaseNote.fromRow(noteRow)).toList();
//     return result;
//   }
//
//   Future<DatabaseNote> getNote({required int id}) async{
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);
//     if(results.isEmpty){
//       throw CouldNotGetNote();
//     }
//     else{
//       final note = DatabaseNote.fromRow(results.first);
//       _notes.removeWhere((note) => note.id == id);
//       _notes.add(note);
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }
//
//   Future<int> deleteAllNote() async{
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final numberOfDeletions =  await db.delete(noteTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return numberOfDeletions;
//   }
//
//   Future<void> deleteNote({required int id}) async{
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(noteTable, where: 'id=?', whereArgs: [id]);
//     if(deletedCount==0){
//       throw CouldNotDeleteNote();
//     }
//     else{
//       _notes.removeWhere((note) => note.id==id);
//       _notesStreamController.add(_notes);
//     }
//   }
//
//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async{
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final dbUser = await getUser(email: owner.email);
//     if(dbUser!=owner){
//       throw CouldNotGetUser();
//     }
//     const text = '';
//     final noteID = await db.insert(noteTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });
//     final note = DatabaseNote(id: noteID, userId: owner.id, text: text, isSyncedWithCloud: true);
//     _notes.add(note);
//     _notesStreamController.add(_notes);
//     return note;
//   }
//
//   Future<DatabaseUser> getUser({required String email}) async{
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(userTable,limit: 1,where: 'email = ?', whereArgs: [email.toLowerCase()]);
//     if(results.isEmpty){
//       throw CouldNotGetUser();
//     }
//     else{
//       return DatabaseUser.fromRow(results.first);
//     }
//   }
//
//   Future<DatabaseUser> createUser({required String email}) async{
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
//     if(results.isNotEmpty){
//       throw UserAlreadyExists();
//     }
//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });
//     return DatabaseUser(id: userId, email: email);
//   }
//
//   Future<void> deleteUser({required String email}) async{
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(userTable, where: 'email = ?', whereArgs: [email.toLowerCase()]);
//     if(deletedCount!=1){
//       throw CouldNotDeleteUser();
//     }
//   }
//
//   Database _getDatabaseOrThrow(){
//     final db = _db;
//     if(db==null){
//       throw DatabaseNotOpenException();
//     }
//     else{
//       return db;
//     }
//   }
//
//   Future<void> _ensureDBIsOpen() async{
//     try{
//       await open();
//     }
//     on DatabaseAlreadyOpenException{
//       //open
//     }
//   }
//
//   Future<void> open() async{
//     if(_db!=null){
//       throw DatabaseAlreadyOpenException();
//     }
//     try{
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;
//       //Create User Table
//       await db.execute(createUserTable);
//       //Create Notes Table
//       await db.execute(createNoteTable);
//       await _cacheNotes();
//     } on MissingPlatformDirectoryException{
//       throw UnableToGetDocumentsDirectory();
//     }
//   }
//
//   Future<void> close() async{
//     final db = _db;
//     if(db==null){
//       throw DatabaseNotOpenException();
//     }
//     else{
//       await db.close();
//       _db = null;
//     }
//   }
// }
//
// class DatabaseNote{
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;
//   const DatabaseNote({required this.id, required this.userId, required this.text, required this.isSyncedWithCloud});
//   DatabaseNote.fromRow(Map<String, Object?> map) :
//         id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud = (map[isSyncedWithCloudColumn]) == 1 ? true : false;
//
//   @override
//   String toString() => 'Note, ID: $id, UserID: $userId, Text: $text, IsSyncedWithCloud: $isSyncedWithCloud';
//
//   @override
//   bool operator == (covariant DatabaseNote other) => id == other.id;
//
//   @override
//   int get hashCode => id.hashCode;
// }
//
// const dbName = 'notes.db';
//
// const noteTable = 'note';
//
// const userTable = 'user';
//
// const idColumn = 'id';
//
// const emailColumn = 'email';
//
// const userIdColumn = 'user_id';
//
// const textColumn = 'text';
//
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';
//
// const createUserTable = '''
//         CREATE TABLE IF NOT EXISTS "user" (
// 	        "id"	INTEGER NOT NULL,
// 	        "email"	TEXT NOT NULL UNIQUE,
// 	        PRIMARY KEY("id" AUTOINCREMENT)
// );''';
//
// const createNoteTable = '''
//         CREATE TABLE IF NOT EXISTS "note" (
// 	        "id"	INTEGER NOT NULL,
// 	        "user_id"	INTEGER NOT NULL,
// 	        "text"	TEXT,
// 	        "is_synced_with_cloud"	INTEGER DEFAULT 0,
// 	        FOREIGN KEY("user_id") REFERENCES "user"("id"),
// 	        PRIMARY KEY("id" AUTOINCREMENT)
// );''';