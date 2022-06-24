import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth_provider.dart';
import 'package:mynotes/services/bloc/auth_event.dart';
import 'package:mynotes/services/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialised(isLoading: true)){
    on<AuthEventForgotPassword>((event, emit) async{
      emit(const AuthStateForgotPassword(exception: null, hasSentEmail: false, isLoading: false));
      final email = event.email;
      if(email==null){
        return;//User just wants to go to forgot password screen
      }
        emit(const AuthStateForgotPassword(exception: null, hasSentEmail: false, isLoading: true));
        bool didSendEmail;
        Exception? exception;
        try{
          await provider.sendPasswordReset(email: email);
          didSendEmail = true;
          exception = null;
        }on Exception catch(e){
          didSendEmail = false;
          exception = e;
        }
        emit(AuthStateForgotPassword(exception: exception, hasSentEmail: didSendEmail, isLoading: false));
    });
    on<AuthEventShouldRegister>((event, emit) async{
      emit(const AuthStateRegistering(
        isLoading: false,
        exception: null,
      ));
    });
    on<AuthEventSendEmailVerification>((event, emit) async{
      await provider.sendEmailVerification();
      emit(state);
    });
    on<AuthEventRegister>((event, emit) async{
      final String email = event.email;
      try {
        final String password = event.password;
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(isLoading: false));
      }on Exception catch(exception){
        emit(AuthStateRegistering(isLoading: false, exception: exception));
      }
    });
    on<AuthEventInitialise>((event, emit)async {
      await provider.initialise();
      final user = provider.currentUser;
      if(user==null){
        emit(const AuthStateLoggedOut(isLoading: false, exception: null));
      }
      else{
        if(!user.isEmailVerified){
          emit(const AuthStateNeedsVerification(isLoading: false));
        }
        else{
          emit(AuthStateLoggedIn(isLoading: false, user: user));
        }
      }
    });
    on<AuthEventLogin>((event, emit) async{
      emit(const AuthStateLoggedOut(loadingText: 'Please wait a moment while screen is loading', isLoading: true, exception: null));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        if(user.isEmailVerified) {
          emit(const AuthStateLoggedOut(loadingText: null, isLoading: false, exception: null));
          emit(AuthStateLoggedIn(isLoading: false, user: user));
        }
        else{
          emit(const AuthStateLoggedOut(isLoading: true, exception: null));
          emit(const AuthStateNeedsVerification(isLoading: false));
        }
      }
      on Exception catch(e){
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
    on<AuthEventLogout>((event, emit) async{
      try{
        await provider.logOut();
        emit(const AuthStateLoggedOut(isLoading: false, exception: null));
      }
      on Exception catch(e){
        emit(AuthStateLoggedOut(isLoading: false, exception: e));
      }
    });
  }
}