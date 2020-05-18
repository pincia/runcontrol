import 'package:RunControl/authentication_bloc/authentication_bloc.dart';
import 'package:RunControl/components/circular_image.dart';
import 'package:RunControl/components/option_card.dart';
import 'package:RunControl/models/appstate.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  StorageReference storageReference;
  String imageUrl = "";
  dynamic _profileImagePath;
  String uid;
  Widget profilePhoto() {}

  @override
  void initState() {
    _getUid();
    storageReference = FirebaseStorage().ref();
  }

  _getUid() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'UID';
    final value = prefs.getString(key) ?? 0;
    uid = value;
  }

  Widget buildCustomAppBar() {
    List<Widget> _navigationWidgetList = [
      IconButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/editprofile');
        },
        icon: Icon(
          Icons.edit,
          color: Colors.black87,
        ),
        padding: EdgeInsets.all(32),
      ),
      Text(
        "Profilo",
        style: TextStyle(color: Colors.black87, fontSize: 20),
      ),
      IconButton(
        onPressed: () {
          BlocProvider.of<AuthenticationBloc>(context).add(
            LoggedOut(),
          );
        },
        icon: Icon(
          Icons.exit_to_app,
          color: Colors.black87,
        ),
        padding: EdgeInsets.all(32),
      ),
    ];

    return  StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
    
   return Container(
      height: 175,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: 125,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFf0c306),
                  Color(0xFFfcd93f),
                ],
              ),
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(80),
                  bottomLeft: Radius.circular(80)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: state.user.profileImagePath != null
                ? CircularImage(
                    NetworkImage(state.user.profileImagePath),
                    width: 90,
                    height: 90,
                    showBorder: true,
                  )
                : Container(),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _navigationWidgetList,
              ),
            ),
          ),
        ],
      ),
    );
      },);
  }

  Widget buildOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        OptionCard('Itineraries', Icons.map, () {
          Navigator.of(context).pushNamed('/itineraries');
        }),
        OptionCard('Statistiche', Icons.insert_chart, () {
          Navigator.of(context).pushNamed('/stats');
        }),
        OptionCard('Attività', Icons.directions_run, () {
                    Navigator.of(context).pushNamed('/activities');
        }),
      ],
    );
  }

  Widget buildUserName() {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return Container(
          height: 60,
          child: ListView(padding: EdgeInsets.all(5), children: [
            Text(
              state.user.fullName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Text(state.user.address,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                )),
          ]),
        );
      },
    );
  }

  buildUserInfo() {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return Container(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                  child: Column(
                    children: <Widget>[
                      Text("SESSO",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400)),
                      Text(state.user.gender,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  )),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                  child: Column(
                    children: <Widget>[
                      Text("PESO",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400)),
                      Text(state.user.weight.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  )),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                  child: Column(
                    children: <Widget>[
                      Text("ALTEZZA",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400)),
                      Text(state.user.height.toString() + " m",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff212121),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          buildCustomAppBar(),
          buildUserName(),
          buildUserInfo(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Column(
                children: <Widget>[
                  buildOptions(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
