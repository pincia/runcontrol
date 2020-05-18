import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:RunControl/components/circular_image.dart';
import 'package:RunControl/models/appstate.dart';
import 'package:RunControl/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Color(0xff212121),
        body: new EditProfileScreen(),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  @override
  State createState() => new EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  User _currentUser;
  User _oldUser;
  File avatarImageFile, backgroundImageFile;
  String sex;
  StorageReference storageReference;
  String imageUrl = "";
  String uid;
  String weight;
  String height;
  Firestore firestoreInstance;
  bool isLoading;
  ImageProvider profileFileImage;
  ImageProvider backgroundFileImage;
  File _profileFileImage;
  File _backgroundFileImage;
  @override
  void initState() {
    _getUid();
    profileFileImage=null;
    backgroundFileImage=null;
    firestoreInstance = Firestore.instance;
    storageReference = FirebaseStorage().ref();
    isLoading = false;
  }

  renderImages() async {
    setState(() {
      backgroundFileImage = NetworkImage(_currentUser.backgroundImagePath);
      profileFileImage = NetworkImage(_currentUser.profileImagePath);
    });
  }

  Widget buildCustomAppBar() {
    List<Widget> _navigationWidgetList = [
      Text(
        "Modifica Profilo",
        style: TextStyle(color: Colors.black87, fontSize: 20),
      )
    ];

    return Container(
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: 70,
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
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(top: 30),
              child: Text(
                "Modifica Profilo",
                style: TextStyle(color: Colors.black87, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWeightDialog() {
    showDialog<double>(
        context: context,
        builder: (BuildContext context) {
          return NumberPickerDialog.decimal(
            minValue: 0,
            maxValue: 150,
            title: Text("Inserisci il peso"),
            initialDoubleValue: double.parse(_currentUser.weight),
          );
        }).then((value) {
      if (value != null) {
        setState(() => _currentUser.weight = value.toString());
      }
    });
  }

  void _showHeightDialog() {
    showDialog<double>(
        context: context,
        builder: (BuildContext context) {
          return NumberPickerDialog.decimal(
            decimalPlaces: 2,
            minValue: 0,
            maxValue: 3,
            title: Text("Inserisci l'altezza"),
            initialDoubleValue: double.parse(_currentUser.height),
          );
        }).then((value) {
      if (value != null) {
        setState(() => _currentUser.height = value.toString());
      }
    });
  }

  Future<Codec> decoderCallback(Uint8List bytes) {}
  saveUser() async {
    profileFileImage.obtainKey(new ImageConfiguration()).then((val) {
      print(val);
    });
    if (_profileFileImage != null) {
      var url =
          await saveImageFirestore(await _profileFileImage.readAsBytes(), true);
      _currentUser.profileImagePath = url;
    }
    if (_backgroundFileImage != null) {
      var url = await saveImageFirestore(
          await _backgroundFileImage.readAsBytes(), false);
      _currentUser.backgroundImagePath = url;
    }

    await firestoreInstance
        .collection('users')
        .where('id', isEqualTo: uid)
        .getDocuments()
        .then((docs) async {
      var doc = docs.documents[0];
      var userJson = _currentUser.toJson();
      await firestoreInstance
          .collection("users")
          .document(doc.documentID)
          .updateData(userJson);
    });
    StoreProvider.of<AppState>(context).dispatch(SetUser(_currentUser));
  }

  _getUid() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'UID';
    final value = prefs.getString(key) ?? 0;
    uid = value;
    // getProfileImage();
    print('read UID: $value');
  }

  Future<String> saveImageFirestore(Uint8List bytes, bool isAvatar) async {
    var _path = "";
    if (isAvatar) {
      var uploadTask = storageReference
          .child("users")
          .child(uid)
          .child("profile_photo.png")
          .putData(bytes);
      var storageSnapshot = await uploadTask.onComplete;
      _path = await storageSnapshot.ref.getDownloadURL();
      setState(() {});
    } else {
      var uploadTask = storageReference
          .child("users")
          .child(uid)
          .child("background_photo.png")
          .putData(bytes);
      var storageSnapshot = await uploadTask.onComplete;
      _path = await storageSnapshot.ref.getDownloadURL();
      setState(() {});
    }
    return _path;
  }

  getProfileImage() async {
    var downloadUrl = await storageReference
        .child("users")
        .child(uid)
        .child("profile_photo.png")
        .getDownloadURL();
    setState(() {});
  }

  getImage(bool isAvatar) async {
    var result = await ImagePicker.pickImage(
        imageQuality: 30, source: ImageSource.camera);
    var url = "";
    if (isAvatar) {
      //url = await saveImageFirestore(result, isAvatar);
      //  StoreProvider.of<AppState>(context).dispatch(SetUserProfileImage(url));
      setState(() {
        profileFileImage = FileImage(result);
        _profileFileImage = result;
      });
    } else {
      // url = await saveImageFirestore(result, isAvatar);
      // StoreProvider.of<AppState>(context).dispatch(SetUserBackgroundImage(url));
      setState(() {
        backgroundFileImage = FileImage(result);
        _backgroundFileImage = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    return StoreConnector<AppState, AppState>(
      converter: (store) {
        if (_currentUser == null)
          _currentUser = User.cloneUser(store.state.user);

        if ((backgroundFileImage ==
                null /*&& store.state.user.backgroundImagePath!=""*/) ||
            (profileFileImage ==
                null /* && store.state.user.profileImagePath!=""*/)) {
          renderImages();
        }
        return store.state;
      },
      builder: (context, state) {
        return isLoading == false
            ? new SingleChildScrollView(
                child: new Column(
                  children: <Widget>[
                    Stack(alignment: Alignment.topCenter, children: <Widget>[
                      new Container(
                        child: new Stack(
                          children: <Widget>[
                            // Background
                            new Positioned.fill(
                              child: (backgroundFileImage == null)
                                  ? new Image.asset(
                                      'assets/images/bg_uit.jpg',
                                      width: MediaQuery.of(context).size.width,
                                      height: 250.0,
                                      fit: BoxFit.cover,
                                    )
                                  : backgroundFileImage != null
                                      ? new Container(
                                          height: 250,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: new BoxDecoration(
                                              image: new DecorationImage(
                                            fit: BoxFit.fitWidth,
                                            image: backgroundFileImage,
                                          )),
                                          margin: new EdgeInsets.only( top: 50.0),
                                        )
                                      : new Container(),
                            ),

                            // Button change background
                            new Positioned(
                              child: new Material(
                                child: new IconButton(
                                  icon: new Image.asset(
                                    'assets/images/ic_camera.png',
                                    width: 30.0,
                                    height: 30.0,
                                    fit: BoxFit.cover,
                                  ),
                                  onPressed: () {
                                    getImage(false);
                                  },
                                  padding: new EdgeInsets.all(0.0),
                                  highlightColor: Colors.black,
                                  iconSize: 30.0,
                                ),
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(30.0)),
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              right: 5.0,
                              top: 170.0,
                            ),

                            // Avatar and button
                            new Positioned(
                              child: new Stack(
                                children: <Widget>[
                                  (profileFileImage == null)
                                      ? new Image.asset(
                                          'assets/images/ic_avatar.png',
                                          width: 70.0,
                                          height: 70.0,
                                        )
                                      : profileFileImage != null
                                          ? CircularImage(
                                              profileFileImage,
                                              width: 70,
                                              height: 70,
                                              showBorder: true,
                                            )
                                          : Container(),
                                  new Material(
                                    child: new IconButton(
                                      icon: new Image.asset(
                                        'assets/images/ic_camera.png',
                                        width: 40.0,
                                        height: 40.0,
                                        fit: BoxFit.cover,
                                      ),
                                      onPressed: () => getImage(true),
                                      padding: new EdgeInsets.all(0.0),
                                      highlightColor: Colors.black,
                                      iconSize: 70.0,
                                    ),
                                    borderRadius: new BorderRadius.all(
                                        new Radius.circular(40.0)),
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ],
                              ),
                              top: 150.0,
                              left: MediaQuery.of(context).size.width / 2 -
                                  70 / 2,
                            )
                          ],
                        ),
                        width: double.infinity,
                        height: 225.0,
                      ),
                      buildCustomAppBar(),
                    ]),
                    new Column(
                      children: <Widget>[
                        // Username
                        new Container(
                          child: new Text(
                            'Email',
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.amber),
                          ),
                          margin: new EdgeInsets.only(left: 10.0, top: 15.0),
                        ),
                        new Container(
                          child: new Text(
                            _currentUser.email,
                            style: new TextStyle(
                                fontSize: 14.0, color: Colors.white54),
                          ),
                          margin: new EdgeInsets.only(left: 30.0, right: 30.0,top:10),
                        ),
                        new Container(
                          child: new Text(
                            'Nome Completo',
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.amber),
                          ),
                          margin: new EdgeInsets.only(left: 10.0, top: 15.0),
                        ),
                        new Container(
                          child: new TextFormField(
                            onChanged: (String value) {
                              _currentUser.fullName = value;
                            },
                            style: TextStyle(color: Colors.white),
                            decoration: new InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                hintText: _currentUser.fullName,
                                border: new UnderlineInputBorder(),
                                contentPadding: new EdgeInsets.all(5.0),
                                hintStyle: new TextStyle(color: Colors.grey)),
                          ),
                          margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                        // Indirizzo
                        new Container(
                          child: new Text(
                            'Indirizzo',
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.amber),
                          ),
                          margin: new EdgeInsets.only(left: 10.0, top: 15.0),
                        ),
                        new Container(
                          child: new TextFormField(
                            style: TextStyle(color: Colors.white),
                            decoration: new InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                hintText: state.user.address,
                                border: new UnderlineInputBorder(),
                                contentPadding: new EdgeInsets.all(5.0),
                                hintStyle: new TextStyle(color: Colors.grey)),
                          ),
                          margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                        ),

                        // Address
                        new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Container(
                                  child: new Text(
                                    'Peso',
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        color: Colors.amber),
                                  ),
                                  margin: new EdgeInsets.only(
                                      left: 10.0, top: 24.0)),
                              GestureDetector(
                                onTap: _showWeightDialog,
                                child: new Container(
                                  child: new Text(
                                    _currentUser.weight,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        color: Colors.white54),
                                  ),
                                  margin: new EdgeInsets.only(
                                      left: 30.0, top: 24.0, right: 30.0),
                                ),
                              ),

                              // About me
                              new Container(
                                  child: new Text(
                                    'Altezza',
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        color: Colors.amber),
                                  ),
                                  margin: new EdgeInsets.only(
                                      left: 10.0, top: 24.0)),
                              new GestureDetector(
                                onTap: _showHeightDialog,
                                child: new Container(
                                  child: new Text(
                                    _currentUser.height,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        color: Colors.white54),
                                  ),
                                  margin: new EdgeInsets.only(
                                      left: 30.0, top: 24.0, right: 30.0),
                                ),
                              ),
                            ]),

                        // Sex
                        new Row(children: <Widget>[
                          new Container(
                            child: new Text(
                              'Sesso',
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Colors.amber),
                            ),
                            margin: new EdgeInsets.only(
                                left: 10.0, top: 24.0, bottom: 5.0),
                          ),
                        ]),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          padding: new EdgeInsets.only(
                              top: 16.0, left: 10, right: 10),
                          child: new FlatButton(
                            color: Colors.red,
                            child: new Text('Annulla'),
                            onPressed: () async {
                              setState(() {
                                profileFileImage = null;
                                backgroundFileImage = null;
                                _profileFileImage = null;
                                _backgroundFileImage = null;
                                _currentUser = state.user;
                              });

                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          padding: new EdgeInsets.only(
                              top: 16.0, left: 10, right: 10),
                          child: new FlatButton(
                            color: Colors.amber,
                            child: new Text('Salva'),
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              await saveUser();
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    )
                  ],
                ),
                padding: new EdgeInsets.only(bottom: 20.0),
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
}
