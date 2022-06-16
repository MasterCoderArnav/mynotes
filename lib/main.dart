import 'package:flutter/material.dart';
import 'package:mynotes/view/registerView.dart';
import 'package:mynotes/view/loginView.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/view/verify_email_view.dart';
import 'dart:developer' as devtools show log;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(myApp());
}

class myApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(),
      routes: {
        '/login' : (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/notes': (context) => const NotesView(),
      },
    );
  }
}

class HomePage extends StatelessWidget{
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context){
    return FutureBuilder(
            future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot){
              switch(snapshot.connectionState){
                  case ConnectionState.done:
                    final user = FirebaseAuth.instance.currentUser;
                    final userVerified = user?.emailVerified ?? false;
                    if(userVerified){
                      devtools.log("User verified");
                      return const NotesView();
                    }
                    else if(user!=null){
                      return const verifyEmailView();
                    }
                    else{
                      return const LoginView();
                    }
                  default:
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                         child: Center(
                            child: SpinKitFoldingCube(
                                color: Colors.blue[800],
                                size: 80.0,
                              ),
                        ),
                      );
              }
            },
      );
  }
}

enum MenuAction {logout}

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
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
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
      content: const Text('Are you sure you want to LogOut'),
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