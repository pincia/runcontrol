import 'package:flutter/material.dart';

class StartButton extends StatelessWidget{

  final Color _backgroundColor;

  StartButton({Color backgroundColor = Colors.red})
      : this._backgroundColor = backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8, top: 8),
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color:Color(0xFFf0c306),
        borderRadius: BorderRadius.all(Radius.circular(60)),
      ),
      child: Center(
          child: Text("INIZIO",
            style: TextStyle(
                fontSize: 18,
                color: _backgroundColor == Colors.red ? Colors.white : Colors.red,
                fontWeight: FontWeight.bold
            ),
          )
      ),
    );
  }
}