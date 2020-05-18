import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'run_event.dart';
part 'run_state.dart';

class RunBloc extends Bloc<RunEvent, RunState> {
  @override
  RunState get initialState => RunInitial();
  RunBloc();
  @override
  Stream<RunState> mapEventToState(
    RunEvent event,
  ) async* {
   if (event is RunStarted) {
      yield* _mapRunStartedToState();
    } else if (event is RunSaved) {
      yield* _mapSavedEndedToState();
    }
  }


   Stream<RunState> _mapRunStartedToState() async* {
      yield Running();
    }
  
  Stream<RunState> _mapSavedEndedToState() async* {
    yield Running();
  }
  }
