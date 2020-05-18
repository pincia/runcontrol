part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class Uninitialized extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final String displayName;
  final User user;
  const Authenticated(this.displayName, this.user);

  @override
  List<Object> get props => [displayName,user];

  @override
  String toString() => 'Authenticated { displayName: $displayName User: $user }';
}

class Unauthenticated extends AuthenticationState {}
