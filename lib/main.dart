import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth_service.dart';
import 'package:mynotes/view/notes/new_note_view.dart';
import 'package:mynotes/view/registerView.dart';
import 'package:mynotes/view/loginView.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mynotes/view/verify_email_view.dart';
import 'dart:developer' as devtools show log;
import 'package:mynotes/view/notesView.dart';

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
        loginRoute : (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyRoute : (context) => const verifyEmailView(),
        newNotesRoute : (context) => const newNoteView(),
      },
    );
  }
}

class HomePage extends StatelessWidget{
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context){
    return FutureBuilder(
            future: AuthService.firebase().initialise(),
          builder: (context, snapshot){
              switch(snapshot.connectionState){
                case ConnectionState.done:
                    final user = AuthService.firebase().currentUser;
                    final userVerified = user?.isEmailVerified ?? false;
                    if(userVerified){
                      devtools.log("User verified");
                      return const NotesView();
                    }
                    else if(user!=null){
                      devtools.log("Verify your email id");
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