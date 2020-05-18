import 'package:flutter/material.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsState createState() => _StatsState();
}
enum ConfirmAction { CANCEL, ACCEPT }

class _StatsState extends State<StatsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiche'),
      ),
      body: Center(
        child: RawMaterialButton(
   
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: Colors.red,
      padding: const EdgeInsets.all(7.0), onPressed: () {  },
    ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    }


}