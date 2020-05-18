import 'dart:ui';

import 'package:RunControl/models/appstate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

AppState reducer(AppState prevState, dynamic action) {
  AppState newState = AppState.fromAppState(prevState);
if (action is UserDetail) {
    newState.user = action.payload;
  }  else if (action is SetUser) {
    newState.user = action.payload;
  } else if (action is SetUserProfileImage) {
    newState.user.profileImagePath = action.payload;
  } else if (action is SetUserBackgroundImage) {
    newState.user.backgroundImagePath = action.payload;
  } else if (action is ChangeRunStatusState) {
    newState.runStatus.isRunning = action.payload;}
    else if (action is ChangeRunStatusPosition) {
    newState.runStatus.currentPosition= action.payload;}
        else if (action is UpdateItinerary) {
    newState.runStatus.currentItinerary= action.payload; }
           else if (action is AddItienraryToPolylines) {
     newState.runStatus.polylines.add(Polyline(
            width: 2, // set the width of the polylines
            polylineId: PolylineId("poly"),
            color: Color.fromARGB(255, 4, 4, 4),
            points: action.payload));
    }
return newState;

}

