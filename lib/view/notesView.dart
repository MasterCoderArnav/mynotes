import 'package:flutter/material.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'dart:developer' as devtools show log;
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

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
    _notesService.open();
    super.initState();
  }

  @override
  void dispose(){
    _notesService.close();
    super.dispose();
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
                  break;
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
                        return const Text('Waiting for the notes to appear');
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

Future<bool> showLogoutDialog(BuildContext context){
  return showDialog<bool>(context: context, builder: (context){
    return AlertDialog(
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to Logout?'),
      actions: [
        TextButton(
            onPressed: (){
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel')
        ),
        TextButton(
            onPressed: (){
              Navigator.of(context).pop(true);
            },
            child: const Text('Logout')
        ),
      ],
    );
  }).then((value) => value??false);
}