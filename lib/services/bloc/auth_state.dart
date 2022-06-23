import 'package:flutter/material.dart' show immutable;
import 'package:mynotes/services/auth_user.dart';

@immutable
abstract class AuthState{
  const AuthState();
}
class AuthStateLoading extends AuthState{
  const AuthStateLoading();
}
class AuthStateLoggedIn extends AuthState{
  final AuthUser user;
  const AuthStateLoggedIn({required this.user});
}
class AuthStateNeedsVerification extends AuthState{
  const AuthStateNeedsVerification();
}
class AuthStateLoggedOut extends AuthState{
  final Exception? exception;
  const AuthStateLoggedOut({required this.exception});
}
class AuthStateLogoutFailure extends AuthState{
  final Exception exception;
  const AuthStateLogoutFailure({required this.exception});
}