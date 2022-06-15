import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState(){
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose(){
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              return Container(
                margin: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Please enter the email',
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
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Please enter the password',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.pink,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextButton(
                      onPressed: () async{
                        try {
                          final email = _email.text;
                          final password = _password.text;
                          final userCredential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(email: email,
                              password: password);
                          print(userCredential);
                        } on FirebaseAuthException catch(e){
                            if(e.code=='wrong-password'){
                              print('Wrong Password');
                            }
                            else if(e.code == 'invalid-email'){
                              print("Invalid Email");
                            }
                            else{
                              print(e.code);
                            }
                        }
                        catch(e){
                          print("Something bad happened");
                          print(e);
                        }
                      },
                      child: Text('Sign In'),
                    ),
                  ],
                ),
              );
            default:
              return Container(
                decoration: BoxDecoration(
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