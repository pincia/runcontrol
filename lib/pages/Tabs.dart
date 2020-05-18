import 'package:RunControl/pages/home.dart';
import 'package:RunControl/pages/new-itinerary.dart';
import 'package:RunControl/pages/prerunpage.dart';
import 'package:RunControl/pages/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Tabs extends StatefulWidget {
  @override
  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<Tabs>     with TickerProviderStateMixin {
  int index;

  @override
  void initState() {
    index = 0;
  }

  setIndex(int ind) {
    this.index = ind;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: CupertinoTabController(initialIndex: index),
      tabBar: CupertinoTabBar(
        onTap: (index) {},
        backgroundColor: Color(0xff383838),
        iconSize: 24,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/home.png"),
              color: Color(0xFFf0c306),
            ),
            activeIcon: ImageIcon(
              AssetImage("assets/icons/home_filled.png"),
              color: Color(0xFFf0c306),
            ),
          ),
          /* BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/itinerary.png"),
              color: Color(0xFFf0c306),
            ),
            activeIcon: ImageIcon(
              AssetImage("assets/icons/itinerary_filled.png"),
              color: Color(0xFFf0c306),
            ),
          ),*/
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/run.png"),
              color: Color(0xFFf0c306),
            ),
            activeIcon: ImageIcon(
              AssetImage("assets/icons/run_filled.png"),
              color: Color(0xFFf0c306),
            ),
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/user.png"),
              color: Color(0xFFf0c306),
            ),
            activeIcon: ImageIcon(
              AssetImage("assets/icons/user_filled.png"),
              color: Color(0xFFf0c306),
            ),
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
              setIndex(index);
              return Home();
            break;
          case 1:
            setIndex(index);
            return PreRunPage();
            break;
          case 2:
            setIndex(index);
            return ProfilePage();
        }
      },
    );
  }
}
