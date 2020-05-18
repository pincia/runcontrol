import 'package:RunControl/models/appstate.dart';
import 'package:RunControl/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'currentmap.dart';
import 'package:polyline/polyline.dart' as PolyEncode;

class EndRunPage extends StatefulWidget {
  final int totalTime;
  final int kcal;
  final double peaceSpeed;
  final double distance;
   final List<LatLng> itinerary;
  EndRunPage({this.totalTime, this.kcal, this.peaceSpeed, this.distance, this.itinerary});
  @override
  _EndRunPageState createState() =>
      _EndRunPageState(totalTime, kcal, peaceSpeed, distance, itinerary);
}

class _EndRunPageState extends State<EndRunPage> {
  _EndRunPageState(
      int totalTime, int kcal, double peaceSpeed, double distance,  List<LatLng> itinerary) {
    this.totalTime = totalTime;
    this.kcal = kcal;
    this.peaceSpeed = peaceSpeed;
    this.distance = distance;
    this._itinerary = itinerary;
  }
  Icon customIcon;
  final databaseReference = Firestore.instance;
  LocationData currentPosition;
  Location location;
  List<LatLng> _itinerary;
  String _uid;
  int totalTime;
  int kcal;
  double peaceSpeed;
  double distance;
  PolyEncode.Polyline encopolyline;
  bool isLoading;
  @override
  void initState() {
    super.initState();
    isLoading=false;
    location = new Location();
  if (_itinerary!=null) {
    var coordinates = List<List<double>>();
    _itinerary.forEach((element) {
      var el = List<double>();
      el.add(element.latitude);
      el.add(element.longitude);
      coordinates.add(el);
    });
   encopolyline = coordinates.length > 0
        ? PolyEncode.Polyline.Encode(decodedCoords: coordinates, precision: 5)
        : null; }
  }

  setLocation(LocationData loc) {
    setState(() {
      this.currentPosition = loc;
    });
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

  @override
  void dispose() {
    super.dispose();
  }

  save() async {
    setState((){
      isLoading=true;
    });

    DocumentReference ref =
        await databaseReference.collection("activities").add({
      'userid': _uid,
      'name': 'TEST',
      'duration': totalTime.toString(),
      'distance': distance.toStringAsFixed(2),
      'kcal': kcal.toString(),
      'itinerary': coordinatesListToString(_itinerary),
      'encodedItinerary': encopolyline != null ? encopolyline.encodedString : "",
      'averagePeace': peaceSpeed.toStringAsFixed(2),
      'date': DateTime.now().toUtc().toUtc().toString()
    });
    setState((){
      isLoading=false;
    });
    StoreProvider.of<AppState>(context)
        .dispatch(UpdateItinerary(List<LatLng>()));
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  coordinatesListToString(List<LatLng> list) {
    if (list.length > 0) {
      String res = "[";
      list.forEach((element) => res += "{\"lat\":\"" +
          element.latitude.toString() +
          "\",\"lng\":\"" +
          element.longitude.toString() +
          "\"},");
      return res.substring(0, res.length - 1) + "]";
    }
    return "[]";
  }

  @override
  Widget build(BuildContext context) {
    return     isLoading == true ? Center(
                child: CircularProgressIndicator(),
              ): StoreConnector<AppState, AppState>(converter: (store) {
      _itinerary = store.state.runStatus.currentItinerary;
      _uid = store.state.user.id;
      return store.state;
    }, builder: (context, state) {
      return Scaffold(
          backgroundColor: Color(0xff212121),
          body: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [  Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                 
                                  Container(
                                    
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 20),
                                      child: Text("DATA "+DateFormat('dd/MM/yyyy hh:mm').format(DateTime.now()),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                         
                                      ),
                                     
                                ]),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Container(
                            margin: EdgeInsets.all(5),
                            child:                                   new Padding(
                                    padding: new EdgeInsets.all(7.0),
                                    child: new Row(
                                      children: <Widget>[
                                        Expanded(
                                            child: Container(
                                                child: encopolyline !=
                                                        null
                                                    ? Image.network(getMapUrl(
                                                        encopolyline.encodedString))
                                                    : Center(child:Text("NO MAP"))))
                                      ],
                                    )),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                //                   <--- left side
                                color: Colors.white30,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Row(children: [
                            Expanded(
                              flex: 3,
                              child: Text("NOME",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400)),
                            ),
                            Expanded(
                              flex: 9,
                              child: Text("Durato $totalTime secondi",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400)),
                            ),
                          ]),
                        )
                      ]),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: ButtonBar(
                      mainAxisSize: MainAxisSize.max,
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ProgressButton(
                          color: Colors.redAccent,
                          defaultWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Elimina"),
                                Icon(Icons.delete,
                                    size: 32, color: Colors.white),
                              ]),
                          progressWidget: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black)),
                          width: 114,
                          height: 48,
                          borderRadius: 24,
                          animate: false,
                          type: ProgressButtonType.Raised,
                          onPressed: () async {
                            StoreProvider.of<AppState>(context)
                                .dispatch(UpdateItinerary(List<LatLng>()));
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (_) => false);
                          },
                        ),
                        ProgressButton(
                          color: Colors.green,
                          defaultWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Salva"),
                                Icon(Icons.save, size: 32, color: Colors.white),
                              ]),
                          progressWidget: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)),
                          width: 114,
                          height: 48,
                          borderRadius: 24,
                          animate: false,
                          type: ProgressButtonType.Raised,
                          onPressed: () async {
                            save();
                          },
                        ),
                      ]),
                ),
              )
            ],
          ));
    });
  }
    String getMapUrl(String encodedPath) {
    return "http://maps.googleapis.com/maps/api/staticmap?size=400x250&key=AIzaSyBl_rdTysgTaRqJNbovvjfsy1xo7f_1Gmo&path=enc:" +
        encodedPath;
  }
}
