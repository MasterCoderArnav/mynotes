import 'package:flutter/material.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'dart:developer' as devtools show log;
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        centerTitle: true,
        elevation: 0.0,
        actions: <Widget>[
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
          )
        ],
      ),
      body: const Text('Hello World'),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context){
  return showDialog<bool>(context: context, builder: (context){
    return AlertDialog(
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to Logout?'),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop(false);
        }, child: const Text('Cancel')),
        TextButton(onPressed: (){
          Navigator.of(context).pop(true);
        }, child: const Text('Logout')),
      ],
    );
  }).then((value) => value??false);
}