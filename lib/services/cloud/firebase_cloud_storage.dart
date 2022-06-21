import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_exceptions.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';

class FirebaseCloudStorage{
  final notes = FirebaseFirestore.instance.collection("notes");
  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
  void createNewNotes({required String ownerUserID}) async{
    await notes.add({
      ownerUserIdFieldName: ownerUserID,
      textFieldName: '',
    });
  }
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}){
    return notes.snapshots().map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)).where(
            (note) => note.ownerUserID==ownerUserId));
  }
  Future<Iterable<CloudNote>> getNote({required String ownerUserID}) async{
    try{
      return await notes.where(
        ownerUserIdFieldName,
        isEqualTo: ownerUserID,
      ).get().then((value) => value.docs.map((doc){
        return CloudNote(
            documentID: doc.id,
            ownerUserID: doc.data()[ownerUserIdFieldName] as String,
            text: doc.data()[textFieldName] as String);
      }));
    }
    catch(e){
      throw CouldNotGetAllNote();
    }
  }
  Future<void> updateNote({required String documentId, required String text}) async{
    try{
      return notes.doc(documentId).update({textFieldName: text});
    }
    catch(e){
      throw CouldNotUpdateNoteException();
    }
  }
  Future<void> deleteNote({required String documentId}){
    try{
      return notes.doc(documentId).delete();
    }
    catch(e){
      throw CouldNotDeleteNote();
    }
  }
}