import 'package:RunControl/models/appstate.dart';
import 'package:RunControl/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:location/location.dart';
import 'currentmap.dart';

class PreRunPage extends StatefulWidget {
  @override
  _PreRunPageState createState() => _PreRunPageState();
}

class _PreRunPageState extends State<PreRunPage> {
  Icon customIcon;
  
  LocationData currentPosition;
  Location location;

  @override
  void initState() {
    super.initState();
    location = new Location();
    location.getLocation().then((cLoc){
  setState(() {
        currentPosition = cLoc;
        StoreProvider.of<AppState>(context)
            .dispatch(ChangeRunStatusPosition(cLoc));
        setLocation(cLoc);
      });
    });
  }

  setLocation(LocationData loc) {
    setState(() {
      this.currentPosition = loc;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff212121),
        body: Stack(
          children: <Widget>[
            CurrentMap(),
            currentPosition != null ?  Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.all(10),
                width: 80.0,
                height: 80.0,
                child: FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Color(0xFFf0c306),
                  onPressed: () {
                    StoreProvider.of<AppState>(context)
                        .dispatch(ChangeRunStatusState(true));
                    Navigator.pushNamed(context, "/run");
                  },
                  child: Text("START",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ):Container(),
            /*
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.all(10),
                width: 50.0,
                height: 50.0,
                child: FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.blueGrey,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 30.0,
                  ),
                ),
              ),
            ),*/
   
          ],
        ));
  }
}
