import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'dart:developer' as devtools show log;
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth_service.dart';
import 'package:mynotes/services/bloc/auth_bloc.dart';
import 'package:mynotes/services/bloc/auth_event.dart';
import 'package:mynotes/services/bloc/auth_state.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/view/notes/notes_list_view.dart';
import '../services/cloud/cloud_note.dart';
import '../utilities/showLogoutDialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userID => AuthService.firebase().currentUser!.id;

  @override
  void initState(){
    _notesService = FirebaseCloudStorage();
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
                    // await AuthService.firebase().logOut();
                    context.read<AuthBloc>().add(const AuthEventLogout());
                    // Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
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
      body: StreamBuilder(
            stream: _notesService.allNotes(ownerUserId: userID),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  case ConnectionState.active:
                    if(snapshot.hasData){
                      final allNote = snapshot.data as Iterable<CloudNote>;
                      return NotesListView(notes: allNote, onDeleteNote: (note) async{
                        await _notesService.deleteNote(documentId: note.documentID);
                        }, onTap: (note){
                          Navigator.of(context).pushNamed(newNotesRoute, arguments: note);
                          },
                      );
                    }
                    else{
                      return const CircularProgressIndicator();
                    }
                    default:
                      return const CircularProgressIndicator();
              }
            }
      )
    );
  }
}