import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';
import 'package:mynotes/constants/routes.dart';

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
        title: const Text('Sign In'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Container(
        margin: const EdgeInsets.all(10.0),
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
            const SizedBox(height: 20.0,),
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
            const SizedBox(
              height: 20.0,
            ),
            TextButton(
              onPressed: () async {
                try {
                  final email = _email.text;
                  final password = _password.text;
                  await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
                  final user = FirebaseAuth.instance.currentUser;
                  bool isVerified = user?.emailVerified ?? false;
                  if(isVerified){
                    Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  }
                  else{
                    Navigator.of(context).pushNamedAndRemoveUntil(verifyRoute, (route) => false);
                  }
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'wrong-password') {
                    await showErrorDialog(context, 'Wrong Password');
                  }
                  else if(e.code == 'user-not-found'){
                    await showErrorDialog(context, 'User Not Found');
                  }
                  else {
                    await showErrorDialog(context, "Error: ${e.code}");
                  }
                } catch (e) {
                  await showErrorDialog(context, e.toString());
                }
              },
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Not registered yet? Register Now!'),
            )
          ],
        ),
      ),
    );
  }
}

