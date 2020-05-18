
import 'package:RunControl/models/run.dart';
import 'package:RunControl/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
class AppState {

  User user;
  RunStatus runStatus;
AppState(
      {@required this.user,@required this.runStatus});
AppState.fromAppState(AppState another) {

    user = another.user;
    runStatus = another.runStatus;
  }
  User  get viewUser => user;
  LocationData get viewCurrentPosition => runStatus.currentPosition;
  RunStatus  get viewRunStatus => runStatus;
}

/// Actions with Payload
class UserDetail {
  final User payload;
  UserDetail(this.payload);
}

class SetUser {
   final User payload;
  SetUser(this.payload);
}

class SetUserProfileImage {
   final String payload;
  SetUserProfileImage(this.payload);
}

class SetUserBackgroundImage {
   final String payload;
  SetUserBackgroundImage(this.payload);
}


class UpdateItinerary {
   final List<LatLng> payload;
  UpdateItinerary(this.payload);
}
class AddItienraryToPolylines {
   final List<LatLng> payload;
  AddItienraryToPolylines(this.payload);
}
class ChangeRunStatusState{
  final bool payload;
  ChangeRunStatusState(this.payload);
}
class ChangeRunStatusPosition{
  final LocationData payload;
  ChangeRunStatusPosition(this.payload);
}

