import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class RunStatus{
   RunStatus(this.isRunning){
     this.currentItinerary = List<LatLng>();
this.polylines=  Set<Polyline>();
   }
  Set<Polyline> polylines;
  LocationData currentPosition;
  bool isRunning;
  Polyline currentPolylineItinerary;
  List<LatLng> currentItinerary;
  String currentRawItinerary;

 
  
}