import 'package:cgchat/Screens/HomePage.dart';
import 'package:cgchat/Screens/MessageScreen.dart';
import 'package:cgchat/Screens/ProfileScreen.dart';
import 'package:cgchat/Services/auth_service.dart';
import 'package:cgchat/main.dart';
import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class Navigation extends StatefulWidget {
  final int index;


  Navigation({required this.index});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int selectedIndex=0;
  @override
  Widget build(BuildContext context) {
    return WaterDropNavBar(
      barItems: [
        BarItem(
          filledIcon: Icons.home,
          outlinedIcon: Icons.home_outlined,
        ),
        BarItem(
            filledIcon: Icons.chat_bubble,
            outlinedIcon: Icons.chat_bubble_outline
        ),
        BarItem(
          filledIcon: Icons.person_rounded,
          outlinedIcon: Icons.person_outline,
        ),
        BarItem(
          filledIcon: Icons.logout,
          outlinedIcon: Icons.logout_outlined,
        ),
      ],
      bottomPadding: 16,
      iconSize: 28,
      inactiveIconColor: Colors.grey,
      waterDropColor: Colors.deepPurple,
      selectedIndex: widget.index,
      backgroundColor: Colors.transparent,
      onItemSelected: (index) {
        setState(() {
          selectedIndex=index;
          if(index==0){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }
          else if (index==1){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MessageScreen()));
          }
          else if (index==2){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
          }
          else if (index==3){
            showDialog(context: context, builder: (context) {
              return AlertDialog(
                elevation: 0,
                title: Text("Uyarı !"),
                content: Text("Çıkış yapmak istediğinize emin misiniz ?"),
                actions: [TextButton(
                  child: Text("Evet"),
                  onPressed: () {
                    AuthService().signOut();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                  },
                ),
                TextButton(
                  child: Text("Hayır"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ]
              );
            },);
          }
        });

      },
    );
  }
}
