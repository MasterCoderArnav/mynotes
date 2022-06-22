import 'package:flutter/material.dart' show immutable;

@immutable
class AuthEvent{
  const AuthEvent();
}

class AuthEventInitialise extends AuthEvent{
  const AuthEventInitialise();
}

class AuthEventLogin extends AuthEvent{
  final String email;
  final String password;
  const AuthEventLogin({required this.email, required this.password});
}

class AuthEventLogout extends AuthEvent{
  const AuthEventLogout();
}