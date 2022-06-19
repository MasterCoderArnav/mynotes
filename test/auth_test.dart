import 'package:mynotes/services/auth_exceptions.dart';
import 'package:mynotes/services/auth_user.dart';
import 'package:test/test.dart';
import 'package:mynotes/services/auth_provider.dart';

void main(){
  group('Mock Authentication', (){
    final provider = MockAuthProvider();
    
    test('Should not be initialised to begin with', (){
      expect(provider.isInitialised, false);
    });
    
    test('Cannot logout if not initialised', (){
      expect(provider.logOut(), throwsA(const TypeMatcher<NotInitialisedException>()));
    });
    
    test('Should be initialised', () async{
      await provider.initialise();
      expect(provider.isInitialised, true);
    });
    
    test('User should be null after initialization', (){
      expect(provider.currentUser, null);
    });
    
    test('Should be able to initialise in less than 2 seconds', () async{
      await provider.initialise();
      expect(provider.isInitialised, true);
    }, timeout: const Timeout(Duration(seconds: 2)));
    
    test('Create user should delegate to log in', () async{
      final badEmailUser = provider.createUser(email: 'foo@bar.com', password: 'anypassword');
      expect(badEmailUser, throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser = provider.createUser(email: 'someone@bar.com', password: 'foobar');
      expect(badPasswordUser, throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(email: 'foo', password: 'bar');
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Login User should be able to get verified', (){
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to logout and login again', () async{
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitialisedException implements Exception{}

class MockAuthProvider implements AuthProvider{
  AuthUser? _user;
  var _isInitialised = false;
  bool get isInitialised => _isInitialised;
  @override
  Future<AuthUser> createUser({required String email, required String password}) async{
    if(!_isInitialised) throw NotInitialisedException();
    await Future.delayed(const Duration(seconds: 2));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialise() async{
    await Future.delayed(const Duration(seconds: 2));
    _isInitialised = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if(!_isInitialised) throw NotInitialisedException();
    if(email == 'foo@bar.com') throw UserNotFoundAuthException();
    if(password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false, email: 'foo@bar.com');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async{
    if(!_isInitialised) throw NotInitialisedException();
    if(_user==null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 2));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async{
    if(!_isInitialised) throw NotInitialisedException();
    final user = _user;
    if(user==null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: 'foo@bar.com');
    _user = newUser;
  }
}