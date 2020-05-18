part of 'run_bloc.dart';

@immutable
abstract class RunEvent extends Equatable {
  @override
  List<Object> get props => [];}

class RunStarted extends RunEvent {}

class RunEnded extends RunEvent {}

class RunSaved extends RunEvent {}
