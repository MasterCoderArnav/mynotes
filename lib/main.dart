import 'package:flutter/material.dart';
import 'package:mynotes/view/registerView.dart';
import 'package:mynotes/view/loginView.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/firebase_options.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(myApp());
}

class myApp extends StatelessWidget{
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(),
      routes: {
        '/login' : (context) => LoginView(),
        '/register': (context) => RegisterView(),
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
                    // final user = FirebaseAuth.instance.currentUser;
                    // final userVerified = user?.emailVerified ?? false;
                    // if(userVerified){
                    //   print(user);
                    // }
                    // else{
                    //   return verifyEmailView();
                    // }
                    // return Scaffold(
                    //   appBar: AppBar(
                    //     title: Text('Home Page'),
                    //     centerTitle: true,
                    //     elevation: 0.0,
                    //   ),
                    //   body: Text('Done')
                    // );
                  return RegisterView();
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
