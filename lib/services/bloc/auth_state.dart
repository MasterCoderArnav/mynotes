import 'package:flutter/material.dart' show immutable;
import 'package:mynotes/services/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState{
  final bool isLoading;
  final String? loadingText;
  const AuthState({required this.isLoading, this.loadingText = 'Please wait a moment'});
}
class AuthStateUninitialised extends AuthState{
  const AuthStateUninitialised({required bool isLoading}):super(isLoading: isLoading);
}

class AuthStateRegistering extends AuthState{
  final Exception? exception;
  const AuthStateRegistering({required this.exception, required bool isLoading}):super(isLoading:isLoading);
}
class AuthStateLoggedIn extends AuthState{
  final AuthUser user;
  const AuthStateLoggedIn({required this.user, required bool isLoading}):super(isLoading: isLoading);
}
class AuthStateNeedsVerification extends AuthState{
  const AuthStateNeedsVerification({required bool isLoading}):super(isLoading: isLoading);
}
class AuthStateLoggedOut extends AuthState with EquatableMixin{
  final Exception? exception;
  const AuthStateLoggedOut({required bool isLoading, String? loadingText, required this.exception}): super(isLoading: isLoading, loadingText: loadingText);

  @override
  // TODO: implement props
  List<Object?> get props => [exception, isLoading];
}
class AuthStateForgotPassword extends AuthState{
  final Exception? exception;
  final bool hasSentEmail;
  final bool isLoading;
  const AuthStateForgotPassword({required this.exception, required this.hasSentEmail, required this.isLoading}):super(isLoading: isLoading);
}