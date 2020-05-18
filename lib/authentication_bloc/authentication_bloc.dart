import 'dart:async';
import 'package:RunControl/models/user.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:RunControl/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  AuthenticationState get initialState => Uninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    final isSignedIn = await _userRepository.isSignedIn();
    if (isSignedIn) {
      final name = await _userRepository.getUser();
      var user = await _userRepository.getFirebaseUser();
     _saveUID(user.id); 
      yield Authenticated(name,user);
    } else {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {

    var user = await _userRepository.getFirebaseUser();
     _saveUID(user.id); 
     final name = await _userRepository.getUser();
    if (user.id==""){
      user = await _userRepository.createNewFirebaseUser();
    }
    yield Authenticated(name,user);
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
         _saveUID(""); 
    yield Unauthenticated();
    _userRepository.signOut();
  }
  
  _saveUID(String uid) async {
        final prefs = await SharedPreferences.getInstance();
        final key = 'UID';
        final value = uid;
        prefs.setString(key, value);
        print('saved UID $value');
      }
}
