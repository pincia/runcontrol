import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class ItineraryPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tutorials',
      home: Itineraries()
    );
  }
}

class Itineraries extends StatefulWidget {
  @override
  _ItinerariesState createState() => _ItinerariesState();
}
enum ConfirmAction { CANCEL, ACCEPT }

class _ItinerariesState extends State<Itineraries> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itinerary'),
      ),
      body: Center(
        child: RawMaterialButton(
      onPressed: getItineraries,
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: Colors.red,
      padding: const EdgeInsets.all(7.0),
    ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
  //  getItineraries();
    }

  
getItineraries() async {
     var response = await http.get('http://192.168.1.228:80/api/itineraries/');
      if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
      print(response.body);
    print(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
  
}

}