import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Activity {
  String id;
  String name;
  String notes;
  int kcal;
  int duration;
  double distance;
  String date;
  List<LatLng> itinerary;
  String encodedItinerary;
  double averagePeace;

  Activity.empty();
  Activity(this.id, this.name, this.notes, this.kcal, this.duration, this.date,
      this.itinerary,this.encodedItinerary,this.distance,this.averagePeace);

  Activity.fromData(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'],
        notes = data['notes'],
        distance = data['distance'] != null ? double.parse(data['distance']):0,
        kcal =data['kcal'] != null ? int.parse(data['kcal']):0,
        duration = data['duration'] != null ? int.parse(data['duration']):0,
        date = data['date'],
        itinerary = (json.decode(data['itinerary']) as List)
            .map((i) => latLngFromJson(i.toString()))
            .toList(),
      encodedItinerary=data['encodedItinerary'],
      averagePeace =  data['averagePeace'] != null ? double.parse(data['averagePeace']):0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'kcal': kcal.toString(),
      'duration': duration.toString(),
      'distance':distance.toString(),
      'date': date,
      'encodedItinerary':encodedItinerary,
      'averagePeace' : averagePeace,
    };
  }

  static LatLng latLngFromJson(String latlng) {
    var ind = latlng.indexOf(':');
    var ind2 = latlng.indexOf(',');
    var lat = latlng.substring(ind + 2, ind2);
    latlng = latlng.substring(ind2+1);
    ind = latlng.indexOf(':');
    ind2 = latlng.indexOf('}');
    var lng = latlng.substring(ind + 2, ind2);
    return LatLng(double.parse(lat), double.parse(lng));
  }

  static List<dynamic> decodeItinerary(String latlng) {}
}
