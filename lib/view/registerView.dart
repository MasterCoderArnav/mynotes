import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: Text('Register'),
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
                              .createUserWithEmailAndPassword(email: email,
                              password: password);
                          print(userCredential);
                        }on FirebaseAuthException catch(e){
                          if(e.code == 'weak-password'){
                            print("Weak Password");
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
                      child: Text('Register'),
                    ),
                    SizedBox(height: 20.0,),
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