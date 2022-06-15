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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please verify your email'),
            TextButton(
              onPressed: () async{
                final user = FirebaseAuth.instance.currentUser;
                print(user!.uid);
                await user.sendEmailVerification();
              },
              child: const Text('Verify Email'),
            )
          ],
        ),
      ),
    );
  }
}