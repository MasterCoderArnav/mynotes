import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/bloc/auth_bloc.dart';
import 'package:mynotes/services/bloc/auth_event.dart';
import 'package:mynotes/services/bloc/auth_state.dart';
import 'package:mynotes/utilities/error_dialog.dart';
import 'package:mynotes/utilities/password_reset_email_sent.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final _textEditingController;

  @override
  void initState(){
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose(){
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async{
          if(state is AuthStateForgotPassword){
            if(state.hasSentEmail){
              _textEditingController.clear();
              await showPasswordEmailSentDialog(context);
            }
            else if(state.exception!=null){
              await ErrorDialog(context, 'We could not process your request please make sure you are registered user');
            }
          }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
          elevation: 0.0,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text('If you have forgotten your password enter your email we will send you a reset link on your mail'),
              const SizedBox(height: 20.0),
              TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Write your email here',
                  filled: true,
                  fillColor: Colors.white,
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
                  onPressed: (){
                    final email = _textEditingController.text;
                    context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
                  },
                  child: const Text('Send me password reset link'),
              ),
              TextButton(
                onPressed: (){
                  context.read<AuthBloc>().add(const AuthEventLogout());
                },
                child: const Text('Back to Login View'),
              ),
            ],
          ),
        ),
      ),
      );
  }
}
