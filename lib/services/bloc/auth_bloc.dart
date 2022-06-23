import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth_provider.dart';
import 'package:mynotes/services/bloc/auth_event.dart';
import 'package:mynotes/services/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()){
    on<AuthEventInitialise>((event, emit)async {
      await provider.initialise();
      final user = provider.currentUser;
      if(user==null){
        emit(const AuthStateLoggedOut(exception: null));
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
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        emit(AuthStateLoggedIn(user: user));
      }
      on Exception catch(e){
        emit(AuthStateLoggedOut(exception: e));
      }
    });
    on<AuthEventLogout>((event, emit) async{
      emit(const AuthStateLoading());
      try{
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null));
      }
      on Exception catch(e){
        emit(AuthStateLogoutFailure(exception: e));
      }
    });
  }
}