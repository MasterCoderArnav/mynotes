import 'package:flutter/material.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'dart:developer' as devtools show log;
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/view/notes/notes_list_view.dart';
import '../utilities/showLogoutDialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NoteService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState(){
    _notesService = NoteService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        centerTitle: false,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            onPressed: (){
              Navigator.of(context).pushNamed(newNotesRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async{
              devtools.log(value.toString());
              switch(value){
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if(shouldLogout){
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
                  else{
                    return;
                  }
              }
            },
            itemBuilder: (context){
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log Out'),
                ),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if(snapshot.hasData){
                          final allNote = snapshot.data as List<DatabaseNote>;
                          print(allNote);
                          return NotesListView(notes: allNote, onDeleteNote: (note) async{
                            await _notesService.deleteNote(id: note.id);
                          }, onTap: (note){
                            Navigator.of(context).pushNamed(newNotesRoute, arguments: note);
                          },);
                        }
                        else{
                          return const CircularProgressIndicator();
                        }
                      default:
                        return const CircularProgressIndicator();
                    }
                  }
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}