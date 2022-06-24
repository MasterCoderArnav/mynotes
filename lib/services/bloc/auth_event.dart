import 'package:flutter/material.dart' show immutable;

@immutable
class AuthEvent{
  const AuthEvent();
}

class AuthEventInitialise extends AuthEvent{
  const AuthEventInitialise();
}

class AuthEventSendEmailVerification extends AuthEvent{
  const AuthEventSendEmailVerification();
}

class AuthEventRegister extends AuthEvent{
  final String email;
  final String password;
  const AuthEventRegister({required this.email, required this.password});
}

class AuthEventShouldRegister extends AuthEvent{
  const AuthEventShouldRegister();
}

class AuthEventLogin extends AuthEvent{
  final String email;
  final String password;
  const AuthEventLogin({required this.email, required this.password});
}

class AuthEventLogout extends AuthEvent{
  const AuthEventLogout();
}

class AuthEventForgotPassword extends AuthEvent{
  final String? email;
  const AuthEventForgotPassword({this.email});
}