import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';
import '../constants/routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
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
            const SizedBox(height: 20.0,),
            TextButton(
              onPressed: () async {
                try {
                  final email = _email.text;
                  final password = _password.text;
                  final userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(email: email,
                      password: password);
                  final user = FirebaseAuth.instance.currentUser;
                  await user?.sendEmailVerification();
                  Navigator.of(context).pushNamed(verifyRoute);
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    await showErrorDialog(context, "Weak Password");
                  }
                  else if (e.code == 'invalid-email') {
                    await showErrorDialog(context, 'Invalid Email');
                  }
                  else if(e.code == 'email-already-in-use'){
                    await showErrorDialog(context, "Email is already in use");
                  }
                  else {
                    await showErrorDialog(context, "Error: ${e.code}");
                  }
                }
                catch (e) {
                  await showErrorDialog(context, e.toString());
                }
              },
              child: const Text('Register'),
            ),
            const SizedBox(height: 20.0,),
            TextButton(
                onPressed: (){
                  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: const Text('Already registered? Login Here'))
          ],
        ),
      ),
    );
  }
}