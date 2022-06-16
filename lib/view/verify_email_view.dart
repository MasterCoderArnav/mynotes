import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class verifyEmailView extends StatefulWidget {
  const verifyEmailView({Key? key}) : super(key: key);

  @override
  State<verifyEmailView> createState() => _verifyEmailViewState();
}

class _verifyEmailViewState extends State<verifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("We've sent you an email verification please verify it"),
            const Center(child: Text('If you have\'nt recieved your verification email click below\nBut please check your spam folder as well')),
            TextButton(
              onPressed: () async{
                final user = FirebaseAuth.instance.currentUser;
                print(user!.uid);
                await user.sendEmailVerification();
              },
              child: const Text('Verify Email'),
            ),
            TextButton(
                onPressed: (){
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}