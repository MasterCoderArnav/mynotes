import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth_provider.dart';
import 'package:mynotes/services/bloc/auth_event.dart';
import 'package:mynotes/services/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialised()){
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(
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
        emit(const AuthStateNeedsVerification());
      }on Exception catch(exception){
        emit(AuthStateRegistering(exception: exception));
      }
    });
    on<AuthEventInitialise>((event, emit)async {
      await provider.initialise();
      final user = provider.currentUser;
      if(user==null){
        emit(const AuthStateLoggedOut(loadingState: false, exception: null));
      }
      else{
        if(!user.isEmailVerified){
          emit(const AuthStateNeedsVerification());
        }
        else{
          emit(AuthStateLoggedIn(user: user));
        }
      }
    });
    on<AuthEventLogin>((event, emit) async{
      emit(const AuthStateLoggedOut(loadingState: true, exception: null));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        if(user.isEmailVerified) {
          emit(const AuthStateLoggedOut(loadingState: false, exception: null));
          emit(AuthStateLoggedIn(user: user));
        }
        else{
          emit(const AuthStateLoggedOut(loadingState: true, exception: null));
          emit(const AuthStateNeedsVerification());
        }
      }
      on Exception catch(e){
        emit(AuthStateLoggedOut(exception: e, loadingState: false));
      }
    });
    on<AuthEventLogout>((event, emit) async{
      try{
        await provider.logOut();
        emit(const AuthStateLoggedOut(loadingState: false, exception: null));
      }
      on Exception catch(e){
        emit(AuthStateLoggedOut(loadingState: false, exception: e));
      }
    });
  }
}