import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:geolocator/geolocator.dart';

import 'package:intl/intl.dart';
class Utility {

  static double calculateDistance(double latFrom ,double lngFrom, double latTo, double lngTo){
   return  SphericalUtil.computeDistanceBetween(LatLng(latFrom,lngFrom),LatLng(latTo,lngTo));
  }

  static Future<double> caluclateDistanceBetween(double latFrom ,double lngFrom, double latTo, double lngTo){
   return  Geolocator().distanceBetween(latFrom, lngFrom, latTo, lngTo);
  }

   static String timeFormat(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }
}


