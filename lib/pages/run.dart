import 'dart:async';
import 'package:RunControl/models/appstate.dart';
import 'package:RunControl/pages/endrunpage.dart';
import 'package:RunControl/utils/circular-buffer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../utility.dart';
import 'currentmap.dart';

final CURRENT_PACE_SAMPLES = 4;
final SAMPLE_TIME = 1000;
final MIN_DISTANCE = 0.25;
final LOCATION_SAMPLE_TIME = 7000;

class RunPage extends StatefulWidget {
  @override
  _RunPageState createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  Stopwatch stopwatch = new Stopwatch();
  Timer timer;
  Views currentView;
  Location location;
  Icon customIcon;
  int kCal;
  int totalTime;
  double weight;
  List<LatLng> _currentItinerary;
  LocationData currentPosition;
  double totalDistance; // in meters
  double totalDistanceInterval;
  int currentPace; // secs per Km
  int averagePace; // secs per Km
  double currentSpeed; // Km/h
  double averageSpeed; // Km/h
  bool currentPaceInMins;
  bool averagePaceInMins;
  double coeffCal;
  StreamSubscription  streamSubscription;
  @override
  void initState() {
    super.initState();
    _currentItinerary = List<LatLng>();
    currentPaceInMins = false;
    averagePaceInMins = false;
    kCal = 0;
    totalTime = 0;
    weight = 0;
    coeffCal = 0;
    totalDistance = 0.0;
    currentSpeed = 0.0;
    averageSpeed = 0.0;
    currentPace = 0;
    averagePace = 0;
    currentView = Views.timer;
    int locationSamples = 0;
    location = new Location();
    location.changeSettings(
        accuracy: LocationAccuracy.NAVIGATION,
        interval: SAMPLE_TIME,
        distanceFilter: 0);
    streamSubscription = location.onLocationChanged().listen((LocationData cLoc) async {
      var distance = 0.0;
      if (currentPosition != null) {
        distance = Utility.calculateDistance(currentPosition.latitude,
            currentPosition.longitude, cLoc.latitude, cLoc.longitude);
        print("DISTANCE CALCULATED : " + distance.toString());
      }
      currentPosition = cLoc;
      setCurrentPaces(distance);
      StoreProvider.of<AppState>(context)
              .dispatch(ChangeRunStatusPosition(cLoc));
      //ogni 6 campioni inserisco la posizione nell'itinerario
      if (stopwatch.isRunning && locationSamples == 6) {
        setState(() {
          if (distance < MIN_DISTANCE) {
            distance = 0.0;
          } else {
            //_lastDistancesBuffer.insert(distance);
            _currentItinerary.add(
                LatLng(currentPosition.latitude, currentPosition.longitude));
            StoreProvider.of<AppState>(context)
                .dispatch(UpdateItinerary(_currentItinerary));
          }

        
        });
        locationSamples = 0;
      }
      locationSamples++;
    });

    startRun();
  }

  setCurrentPaces(double distance) {
    /*   totalDistanceInterval = 0.0;
    _lastDistancesBuffer.forEach((val) {
      totalDistanceInterval += val;
    });
*/
//if (zeroCount(_lastDistancesBuffer)<2) {
    // if (totalDistanceInterval > CURRENT_PACE_SAMPLES * MIN_DISTANCE) {
    //if (true) {
    if (stopwatch.isRunning && distance != 0) {
      totalDistance = totalDistance + distance;
      //     _lastDistancesBuffer.insert(distance);
      //     print("BUFFER " + _lastDistancesBuffer.toString());
      currentSpeed = distance / SAMPLE_TIME * 3600;
      currentPace = (3600 ~/ currentSpeed);

      print("CURRENT SPEED: " + currentSpeed.toString());
      print("CURRENT PEACE: " + currentPace.toString());
      print((currentPace ~/ 60).toString() +
          " MIN" +
          (currentPace % 60).toString() +
          " SEC");
      print((averagePace ~/ 60).toString() +
          " MIN" +
          (averagePace % 60).toString() +
          " SEC");
    } else {
      currentSpeed = 0;
      currentPace = 0;
    }

    averageSpeed = (totalDistance / stopwatch.elapsed.inSeconds) * 3600 / 1000;
    if (averageSpeed > 0) averagePace = (3600 ~/ averageSpeed);
  }

  timerCallback() {
    if (stopwatch.isRunning) {
      if (this.mounted) {
        setState(() {
          if (averageSpeed > 2) {
            coeffCal = averageSpeed * 0.02009179 - 0.02349732;
          } else
            coeffCal = 0.03;
          totalTime = stopwatch.elapsedMilliseconds ~/ 1000;
          kCal = (weight * coeffCal * totalTime / 60).toInt();
        });
      }
    }
  }

  startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => timerCallback());
  }

  zeroCount(CircularBuffer<double> list) {
    int res = 0;
    list.forEach((element) {
      if (element > 0) res = res + 1;
    });
    return res;
  }

  pauseStartRun() {
    setState(() {
      if (stopwatch.isRunning) {
        stopwatch.stop();
        timer.cancel();
      } else {
        stopwatch.start();
        startTimer();
      }
    });
  }

  startRun() {
    setState(() {
      startTimer();
      currentView = Views.timer;
      stopwatch.start();
    });
  }

  endRun() {
    resetRun();
    StoreProvider.of<AppState>(context).dispatch(ChangeRunStatusState(false));
  streamSubscription?.cancel();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EndRunPage(
              totalTime: totalTime, kcal: kCal, distance: totalDistance/1000 ,peaceSpeed: averageSpeed, itinerary: _currentItinerary)),
    );
    //  Navigator.pushNamed(context, "/endrun");
  }

  resetRun() {
    setState(() {
      // _currentItinerary= new List<LatLng>();
      stopwatch.reset();
      timer.cancel();
    });
  }

  goBack() {
    print(ModalRoute.of(context).settings.name);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
    currentView = Views.timer;
  }

  @override
  Widget build(BuildContext context) {
    switch (currentView) {
      case Views.map:
        return Scaffold(
          backgroundColor: Color(0xff212121),
          body: CurrentMap(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                currentView = Views.timer;
              });
            },
            child: Icon(Icons.timer),
            backgroundColor: Color(0xFFf0c306),
          ),
        );

        break;
      case Views.timer:
        return StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              weight = double.parse(state.user.weight);
              return Scaffold(
                backgroundColor: Color(0xff212121),
                body: Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          Expanded(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    Utility.timeFormat(
                                        stopwatch.elapsedMilliseconds),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 70,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "TEMPO",
                                    style: TextStyle(
                                        color: Colors.white30, fontSize: 20),
                                  ),
                                ]),
                          ),
                        ],
                      )),
                      Expanded(
                          child: Row(
                        children: [
                          Expanded(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    (totalDistance / 1000).toStringAsFixed(1),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 70,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "KM",
                                    style: TextStyle(
                                        color: Colors.white30, fontSize: 20),
                                  ),
                                ]),
                          ),
                          Expanded(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    kCal.toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 70,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Kcal",
                                    style: TextStyle(
                                        color: Colors.white30, fontSize: 20),
                                  ),
                                ]),
                          ),
                        ],
                      )),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    currentPaceInMins = !currentPaceInMins;
                                  },
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        currentPaceInMins == true
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                    Text(
                                                      (currentPace ~/ 60)
                                                              .toString() +
                                                          ":" +
                                                          (currentPace % 60)
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 40,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      " al Km",
                                                      style: TextStyle(
                                                          color: Colors.white30,
                                                          fontSize: 20),
                                                    ),
                                                  ])
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                    Text(
                                                      currentSpeed
                                                          .toStringAsFixed(2),
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 40,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      "Km/h",
                                                      style: TextStyle(
                                                          color: Colors.white30,
                                                          fontSize: 20),
                                                    ),
                                                  ]),
                                        Text(
                                          "PASSO ATTUALE",
                                          style: TextStyle(
                                              color: Colors.white30,
                                              fontSize: 20),
                                        ),
                                      ])),
                            ),
                            Expanded(
                                child: GestureDetector(
                              onTap: () {
                                averagePaceInMins = !averagePaceInMins;
                              },
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    averagePaceInMins == true
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                                Text(
                                                  (averagePace ~/ 60)
                                                          .toString() +
                                                      ":" +
                                                      (averagePace % 60)
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 40,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  " al Km",
                                                  style: TextStyle(
                                                      color: Colors.white30,
                                                      fontSize: 20),
                                                ),
                                              ])
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                                Text(
                                                  averageSpeed
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 40,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "Km/h",
                                                  style: TextStyle(
                                                      color: Colors.white30,
                                                      fontSize: 20),
                                                ),
                                              ]),
                                    Text(
                                      "PASSO MEDIO",
                                      style: TextStyle(
                                          color: Colors.white30, fontSize: 20),
                                    ),
                                  ]),
                            )),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Icon(Icons.camera_alt,
                                  color: Color(0xFFf0c306), size: 46)),
                          Expanded(
                            flex: 6,
                            child: stopwatch.isRunning == false
                                ? Row(children: [
                                    MaterialButton(
                                      onPressed: () {
                                        pauseStartRun();
                                      },
                                      color: Colors.lightGreen,
                                      textColor: Colors.white,
                                      child: Icon(Icons.play_arrow,
                                          color: Colors.white, size: 60),
                                      padding: EdgeInsets.all(5),
                                      shape: CircleBorder(),
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        endRun();
                                      },
                                      color: Colors.red,
                                      textColor: Colors.white,
                                      child: Icon(Icons.stop,
                                          color: Colors.white, size: 60),
                                      padding: EdgeInsets.all(5),
                                      shape: CircleBorder(),
                                    )
                                  ])
                                : Container(
                                    margin: EdgeInsets.all(10),
                                    width: 90,
                                    height: 90,
                                    child: MaterialButton(
                                      onPressed: () {
                                        pauseStartRun();
                                      },
                                      color: Color(0xFFf0c306),
                                      textColor: Colors.white,
                                      child: Icon(Icons.pause,
                                          color: Colors.white, size: 46),
                                      padding: EdgeInsets.all(5),
                                      shape: CircleBorder(),
                                    ),
                                  ),
                          ),
                          Expanded(
                            flex: 3,
                            child: IconButton(
                              icon: Icon(Icons.my_location,
                                  color: Color(0xFFf0c306), size: 38),
                              onPressed: () {
                                setState(() {
                                  currentView = Views.map;
                                });
                              },
                            ),
                          ),
                        ],
                      ))
                    ],
                  ),
                ),
              );
            });
        break;
    }
  }
}

enum Views {
  map,
  timer,
}
