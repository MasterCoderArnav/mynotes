import 'package:flutter/material.dart' show immutable;
import 'package:mynotes/services/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState{
  const AuthState();
}
class AuthStateUninitialised extends AuthState{
  const AuthStateUninitialised();
}

class AuthStateRegistering extends AuthState{
  final Exception? exception;
  const AuthStateRegistering({required this.exception});
}
class AuthStateLoggedIn extends AuthState{
  final AuthUser user;
  const AuthStateLoggedIn({required this.user});
}
class AuthStateNeedsVerification extends AuthState{
  const AuthStateNeedsVerification();
}
class AuthStateLoggedOut extends AuthState with EquatableMixin{
  final Exception? exception;
  final bool loadingState;
  const AuthStateLoggedOut({required this.loadingState,required this.exception});

  @override
  // TODO: implement props
  List<Object?> get props => [exception, loadingState];
}
