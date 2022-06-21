import 'package:flutter/material.dart';
import 'package:mynotes/services/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import '../../services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/arguments/get_arguments.dart';

class newNoteView extends StatefulWidget {
  const newNoteView({Key? key}) : super(key: key);

  @override
  State<newNoteView> createState() => _newNoteViewState();
}

class _newNoteViewState extends State<newNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _noteService;
  late final TextEditingController _textEditingController;
  Future<CloudNote> createOrGetExistingNote(BuildContext context) async{
    final widgetNote = context.getArgument<CloudNote>();
    if(widgetNote!=null){
      _note = widgetNote;
      _textEditingController.text = widgetNote.text;
      return widgetNote;
    }
    final existingNote = _note;
    if(existingNote!=null){
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email;
    // final owner = await _noteService.getUser(email: email);
    // final newNote = await _noteService.createNote(owner: owner);
    final userID = currentUser.id;
    final newNote = await _noteService.createNewNotes(ownerUserID: userID);
    _note = newNote;
    return newNote;
  }
  void _deleteNoteIfTextIsEmpty(){
    final note = _note;
    if(_textEditingController.text.isEmpty&&note!=null){
      // _noteService.deleteNote(id: note.id);
      _noteService.deleteNote(documentId: note.documentID);
    }
  }
  void _saveNoteIfTextNotEmpty() async{
    final note = _note;
    final text = _textEditingController.text;
    if(note!=null&&text.isNotEmpty){
      // await _noteService.updateNote(note: note, text: text);
      await _noteService.updateNote(documentId: note.documentID, text: text);
    }
  }

  void _textControllerListener() async{
    final note = _note;
    if(note==null){
      return;
    }
    final text = _textEditingController.text;
    // await _noteService.updateNote(note: note, text: text);
    await _noteService.updateNote(documentId: note.documentID, text: text);
  }

  void _setupTextControllerListener(){
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
  }

  void initState(){
    _noteService = FirebaseCloudStorage();
    _textEditingController = TextEditingController();
    super.initState();
  }

  void dispose(){
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: FutureBuilder(
              future: createOrGetExistingNote(context),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.done:
                    _setupTextControllerListener();
                    return Container(
                      margin: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: _textEditingController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Enter your note here',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            )
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.pink,
                                width: 2.0,
                              )
                          ),
                        ),
                      ),
                    );
                  default:
                    return const CircularProgressIndicator();
                }
              }
          ),
    );
  }
}
