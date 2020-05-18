import 'package:flutter/material.dart';

import 'currentmap.dart';

class MapPage extends StatefulWidget {


  @override
    _MapState createState() => _MapState();
    }


class _MapState extends State<MapPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CurrentMap(),
    );
  }
  @override
  void initState() {
    super.initState();
    }


}