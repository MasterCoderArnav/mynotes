import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/view/registerView.dart';
import 'package:mynotes/view/loginView.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/firebase_options.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(),
    )
  );
}

class HomePage extends StatelessWidget{
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body:FutureBuilder(
            future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot){
              switch(snapshot.connectionState){
                  case ConnectionState.done:
                    final user = FirebaseAuth.instance.currentUser;
                    final userVerified = user?.emailVerified ?? false;
                    if(userVerified){
                      print("You are a verified user");
                    }
                    else{
                      print("You need to verify your email first");
                    }
                    return Scaffold(
                      appBar: AppBar(
                        title: Text('Home Page'),
                        centerTitle: true,
                        elevation: 0.0,
                      ),
                      body: Text('Done')
                    );
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
      ),
    );
  }
}


