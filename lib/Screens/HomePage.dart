import 'dart:ui';

import 'package:cgchat/Models/Navigation.dart';
import 'package:cgchat/Models/WallPost.dart';
import 'package:cgchat/Screens/SendMessageScreen.dart';
import 'package:cgchat/Services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin{
  TextEditingController message = TextEditingController();
  final currentUser = AuthService().firebaseAuth.currentUser!.email;
  PageController pageController = PageController();
  int selectedIndex=0;

  void closeKeyboard() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
  }


  void postMessage(){
    if(message.text.isNotEmpty){
      FirebaseFirestore.instance.collection("UsersPost").add(
          {'UserMail':currentUser,
            'Message':message.text,
            'TimeStamp':DateTime.now(),
            'Likes':[]
          });
    }
  }



  Future<String?> getUserProfileImageURL() async {

      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('mail', isEqualTo: currentUser)
          .limit(1)
          .get();

      if (userQuerySnapshot.size > 0) {
        DocumentSnapshot userSnapshot = userQuerySnapshot.docs[0];
        return userSnapshot.get('imageURL').toString();
      }
    }

  Future getUserDetail(String mail) async {

    QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('mail', isEqualTo: mail)
        .limit(1)
        .get();

    if (userQuerySnapshot.size > 0) {
      DocumentSnapshot userSnapshot = userQuerySnapshot.docs[0];
      return userSnapshot.data();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CG",style: TextStyle(fontFamily: "Pacifico")),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        toolbarHeight: 65,
      ),
      backgroundColor: Colors.grey[300],
      body: GestureDetector(
        onTap: () {
          closeKeyboard();
        },
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("UsersPost").orderBy("TimeStamp",descending: true).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                      final post = snapshot.data!.docs[index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(context: context, builder: (context) {
                            return FutureBuilder(
                              future: getUserDetail(post.get('UserMail')),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final user = snapshot.data!;
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                    backgroundColor: Colors.transparent,
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      clipBehavior: Clip.none,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(top: 10),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              boxShadow: const [
                                                BoxShadow(color: Colors.black,offset: Offset(0,10),
                                                    blurRadius: 10
                                                ),
                                              ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              SizedBox(height: 50,),
                                              Text(user['username'],style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
                                              SizedBox(height: 15,),
                                              Text(user['mail'],style: TextStyle(fontSize: 14),textAlign: TextAlign.center,),
                                              SizedBox(height: 15,),
                                              Text("Hakkında : "+user['bio'],style: TextStyle(fontSize: 14),textAlign: TextAlign.center,),
                                              SizedBox(height: 22,),
                                              Align(
                                                alignment: Alignment.bottomRight,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => SendMessageScreen(yollayan: AuthService().firebaseAuth.currentUser!.uid,alan: user['uid'],username: user['username'],imgURL: user['imageURL'],)));
                                                      },
                                                      child: Text("Mesaj Gönder"),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: -50,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            radius: 50,
                                            backgroundImage: user['imageURL'] != "" ? NetworkImage(user['imageURL']) : NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdslTMhVTjNETp90xvGrt1MMl9BxFxHygX9g&usqp=CAU")
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else{
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                              },
                            );
                          },);
                        },
                        child: WallPost(
                          message: post['Message'],
                          user: post['UserMail'],
                          time: post['TimeStamp'].toDate(),
                          likes: post['Likes'] ?? [],
                          id: post.id,
                        ),
                      );
                      },
                    );
                  }else if(snapshot.hasError){
                    return Center(child: Text(snapshot.error.toString()),);
                  }else{
                    return const Center(child: CircularProgressIndicator(),);
                  }
                },
              ),
            ),


            Row(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: EdgeInsets.only(left: 21,top: 8,),
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: message,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                          hintText: "Mesaj girin",
                          contentPadding: EdgeInsets.only(top: 8,left: 6),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  padding: EdgeInsets.only(top: 10),
                  onPressed: () {
                    postMessage();
                    message.clear();
                    closeKeyboard();
                  },
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Navigation(index: 0),
    );
  }
}