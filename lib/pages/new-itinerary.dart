import 'package:RunControl/data/fake-itineraries.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:RunControl/utility.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';




class NewItinerary extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tutorials',
      home: Map()
    );
  }
}
class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}
enum ConfirmAction { CANCEL, ACCEPT }

class _MapState extends State<Map> {
  //MAP elements
  String googleAPIKey = "AIzaSyBl_rdTysgTaRqJNbovvjfsy1xo7f_1Gmo";
  Completer<GoogleMapController> controller1;
  LatLng _start;
  LatLng _initialPosition;
  LatLng _lastMapPosition ;
  Marker _startMarker;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  double currentDistance = 0.0;


  List<LatLng> polylineCoordinates = [];
  List<PartialMap> polylineCoordinatesHistory = [];

  // for my custom icons
  BitmapDescriptor customIcon;
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;

//mocked data

List<LatLng> mockedItinerary;
  String _itineraryName;
  @override
  void initState() {
    super.initState();
BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)),
        'assets/icons/start_marker.png')
    .then((d) {
  customIcon = d;
});
    _getUserLocation();
  //mockedItinerary=FakeItineraries().getParsedRoute();
  }

  void _getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }



  _onMapCreated(GoogleMapController controller) {
     controller.setMapStyle(Utils.mapStyles);
     drawFakeRoute();
    setState(() {

     // controller1.complete(controller);
    });
  }

  MapType _currentMapType = MapType.normal;

 Future<void> _onSaveButtonPressed() async {
    var res = await _asyncSaveButtonPressed(context);
 if(res == ConfirmAction.ACCEPT) {
 //  var _itinerary =new  Itinerary(0,_itineraryName,currentDistance,polylineCoordinates);
 }
  }

  
Future<ConfirmAction> _asyncSaveButtonPressed(BuildContext context) async{
   return await showDialog<ConfirmAction>(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
        title: Text('Salvataggio itinerario'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Nome'),
              TextField(
                onChanged: (text) {
                  _itineraryName =text;
                },
                decoration: InputDecoration(
                border: new OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.black, width: 0.5)),
  ),
),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Annulla'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          ),
          FlatButton(
            child: Text('Salva'),
            onPressed: () {
             Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          ),
        ],
      );
  }
);
 }
  _onCameraMove(CameraPosition position) {
  // _lastMapPosition = position.target;
  }

  Widget mapButton(Function function, Icon icon, Color color) {
    return RawMaterialButton(
      onPressed: function,
      child: icon,
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: color,
      padding: const EdgeInsets.all(7.0),
    );
  }

drawFakeRoute() {

      setState(() {
          Polyline polyline = Polyline(
            width:10,
              polylineId: PolylineId("poly"),
              color: Color.fromARGB(255, 40, 122, 198),
              points: mockedItinerary);

     
          _polylines.add(polyline);
          });
        }
tapFunction(LatLng position){
  if (_start == null) {
    _start = position;
_lastMapPosition = position;
    setState(() {
      _startMarker =     Marker(
              markerId: MarkerId(position.toString()),
              position: position,
              infoWindow: InfoWindow(
                  title: "INIZIO",
                 // snippet: "Inizio",
                  onTap: (){
                  }
              ),
              onTap: (){
              },
              icon: customIcon);
      _markers.add(_startMarker);});
  }
  else setPolylines(position);
}
 setPolylines(LatLng newPosition) async {

        List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
            googleAPIKey,
            _lastMapPosition.latitude,
           _lastMapPosition.longitude,
            newPosition.latitude,
            newPosition.longitude);
        if (result.isNotEmpty) {
          result.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
        }

      setState(() {
          Polyline polyline = Polyline(
              polylineId: PolylineId("poly"),
              color: Color.fromARGB(255, 40, 122, 198),
              points: polylineCoordinates);

     
          _polylines.add(polyline);
          polylineCoordinatesHistory.add(new PartialMap(polylineCoordinates));
            _lastMapPosition = newPosition;
          currentDistance=0;
          for(var i=0;i<polyline.points.length-1;i++){
            currentDistance += Utility.calculateDistance(polyline.points.elementAt(i).latitude,polyline.points.elementAt(i).longitude, polyline.points.elementAt(i+1).latitude, polyline.points.elementAt(i+1).longitude);
          }
      });
        
  }
_onUndoPressed(){
  setState(() {
    if (polylineCoordinatesHistory.length>0){
      polylineCoordinatesHistory.removeLast();
          _polylines = {};
          polylineCoordinates = [];
          if (polylineCoordinatesHistory.length>0) {
                Polyline polyline = Polyline(
              polylineId: PolylineId("poly"),
              color: Color.fromARGB(255, 40, 122, 198),
              points: polylineCoordinatesHistory.last.polyline);
              _polylines.add(polyline);
              polylineCoordinates =  polylineCoordinatesHistory.last.polyline;
                 currentDistance=0;
                for(var i=0;i<polyline.points.length-1;i++){
                currentDistance += Utility.calculateDistance(polyline.points.elementAt(i).latitude,polyline.points.elementAt(i).longitude, polyline.points.elementAt(i+1).latitude, polyline.points.elementAt(i+1).longitude);
              }
          }
     }
     else{
       _markers.remove(_startMarker);
       _start = null;
       currentDistance = 0;
     }
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialPosition == null ? Container(child: Center(child:Text('loading map..', style: TextStyle(fontFamily: 'Avenir-Medium', color: Colors.grey[400]),),),) : Container(
        child: Stack(children: <Widget>[
          GoogleMap(
            markers: _markers,
            polylines: _polylines,
            mapType: _currentMapType,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 13.4746,
            ),
            onMapCreated: _onMapCreated,
            zoomGesturesEnabled: true,
            onCameraMove: _onCameraMove,
            myLocationEnabled: true,
            compassEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled:false,
            onTap: (latLng) {
                tapFunction(latLng);
              },
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
                margin: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
                child: Column(
                  children: <Widget>[
                    mapButton(_onUndoPressed,
                        Icon(
                            Icons.undo,color: Colors.white,
                        ), Color(0xFF0a3868)),
                    mapButton(
                        _onSaveButtonPressed,
                        Icon(
                          Icons.check,color: Colors.white,
                        ),
                        Colors.green),
                   RichText(
                         textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'Distanza\n',
                            style:  TextStyle(backgroundColor: Colors.white,fontSize: 15 ,color: Color(0xFF0a3868),  fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              TextSpan(text: (currentDistance/1000).toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold)),
                        
                              TextSpan(text: " Km", style: TextStyle( fontWeight: FontWeight.bold)),
                            ],
                          ),
                          ),
                  ],
                )),
          )
        ]),
      ),
    );
  }
}
class PartialMap {
  List<LatLng> polyline;
  PartialMap (  List<LatLng> poly){
    this.polyline=[]..addAll(poly);
  }
}
class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}
