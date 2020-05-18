import 'package:flutter/material.dart';

class OptionCard extends StatelessWidget{

  final String title;
  final IconData icon;
  final GestureTapCallback _onTap;

  OptionCard(this.title, this.icon, this._onTap);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 90,
      margin: EdgeInsets.all(8),
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(0),
        child: Container(
          decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                   Color(0xFFf0c306),
                    Color(0xFFfcd93f),
                  ],
                ),),
          child :InkWell(
          onTap: _onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Icon(icon, color:  Color(0xff212121),),
                Spacer(),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold,),)
              ],

            ),
          ),
        ),
        ),
      ),
    );
  }
}