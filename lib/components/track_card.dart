
import 'package:RunControl/components/circular_image.dart';
import 'package:flutter/material.dart';

class TrackCard extends StatelessWidget{
  final String member;

  TrackCard(this.member);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 4, right: 4),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: CircularImage(NetworkImage('https://celebritypets.net/wp-content/uploads/2016/12/Adriana-Lima.jpg')),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(member,),
                      Text('0.8 KM for your position',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0a3868), 
                        ),
                      )
                    ],
                  ),
                ],
              ),

              Row(
                children: <Widget>[
                  Switch(
                    value: true,
                    activeColor: Color(0xFF0a3868), 
                    onChanged: (currentValue){},
                  ),
                  Text('Track')
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}