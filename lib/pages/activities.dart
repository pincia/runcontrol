import 'package:RunControl/models/activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../utility.dart';

class ActivitiesPage extends StatefulWidget {
  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  List<Activity> activities;
  List<Widget> cardList;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff212121),
        body: activities != null
            ? new Column(children: <Widget>[
                new Expanded(
                    child: new ListView.builder(
                        itemCount: activities.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          var act = activities[index];
                          return Card(
                            child: new Column(
                              children: <Widget>[
                                   Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                 
                                  Container(
                                    
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 20),
                                      child: Text("DATA "+DateFormat('dd/MM/yyyy hh:mm').format(DateTime.parse(act.date).toLocal()),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                         
                                      ),
                                     
                                ]),
                                  new Padding(
                                    padding: new EdgeInsets.all(7.0),
                                    child: new Row(
                                      children: <Widget>[
                                        Expanded(
                                            child: Container(
                                                child: act.encodedItinerary !=
                                                        null
                                                    ? Image.network(getMapUrl(
                                                        act.encodedItinerary))
                                                    : Container()))
                                      ],
                                    )),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                  Container(
                                    height: 50,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Column(
                                        children: <Widget>[
                                              Text(Utility.timeFormat(act.duration*1000),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                          Text("DURATA",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black26,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400)),
  
                                        ],
                                      )),
                                  Container(
                                    height: 50,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Column(
                                        children: <Widget>[
                                              Text((act.distance).toStringAsFixed(2)+" Km",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                          Text("DISTANZA",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black26,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400)),
  
                                        ],
                                      )),
                                      Container(
                                    height: 50,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Column(
                                        children: <Widget>[
                                              Text(act.averagePeace.toString()+ "Km/h",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                          Text("PASSO MEDIO",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black26,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400)),
  
                                        ],
                                      )),
                                ]),
                              
                              ],
                            ),
                          );
                        }))
              ])
            : Center(child: Center(child: CircularProgressIndicator())));
  }

  @override
  void initState() {
    getActivities().then((_activities) {
      setState(() {
       activities = _activities;
      });
    });
  }

  String getMapUrl(String encodedPath) {
    return "http://maps.googleapis.com/maps/api/staticmap?size=400x250&key=AIzaSyBl_rdTysgTaRqJNbovvjfsy1xo7f_1Gmo&path=enc:" +
        encodedPath;
  }

  Set<Polyline> newPolyline(List<LatLng> list) {
    Set<Polyline> polylines = Set<Polyline>();
    polylines.add(Polyline(
        width: 3, // set the width of the polylines
        polylineId: PolylineId("poly"),
        color: Colors.blue,
        points: list));
    return polylines;
  }

  Future<List<Activity>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'UID';
    final uid = prefs.getString(key) ?? 0;
    var result = await Firestore.instance
        .collection('activities')
        .where('userid', isEqualTo: uid)
        .getDocuments();
    var tempAct = List<Activity>();
    for (var doc in result.documents) {
      tempAct.add(Activity.fromData(doc.data));
    }

    return tempAct;
  }
}
