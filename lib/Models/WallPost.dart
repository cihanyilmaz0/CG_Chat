import 'package:cgchat/Models/Like.dart';
import 'package:cgchat/Services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final DateTime time;
  final List<dynamic> likes;
  final String id;

  WallPost({
    required this.message,
    required this.user,
    required this.time,
    required this.likes,
    required this.id,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  bool isLiked = false;

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
    FirebaseFirestore.instance.collection('UsersPost').doc(widget.id);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion(
          [AuthService().firebaseAuth.currentUser!.email],
        )
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove(
          [AuthService().firebaseAuth.currentUser!.email],
        )
      });
    }
  }

  Future<String?> getUserProfileImageURL() async {
    DocumentSnapshot postSnapshot =
    await FirebaseFirestore.instance.collection('UsersPost').doc(widget.id).get();

    if (postSnapshot.exists) {
      String userMail = postSnapshot.get('UserMail').toString();

      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('mail', isEqualTo: userMail)
          .limit(1)
          .get();

      if (userQuerySnapshot.size > 0) {
        DocumentSnapshot userSnapshot = userQuerySnapshot.docs[0];
        return userSnapshot.get('imageURL').toString();
      }
    }

    return null;
  }


  @override
  Widget build(BuildContext context) {
    if(widget.likes.contains(FirebaseAuth.instance.currentUser!.email)){
      isLiked=true;
    }else{
      isLiked=false;
    }
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateFormat('dd/MM/yyyy HH-mm').format(widget.time),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
          ),
          Row(
            children: [
              FutureBuilder<String?>(
                future: getUserProfileImageURL(),
                builder: (context, snapshot) {
                   if (snapshot.hasData) {
                    String? profileImageURL = snapshot.data;
                    return CircleAvatar(
                      radius: 30,
                      backgroundImage:
                      profileImageURL != "" ? NetworkImage(profileImageURL!) : NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdslTMhVTjNETp90xvGrt1MMl9BxFxHygX9g&usqp=CAU")
                    );
                  } else{
                    return CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 230,
                    child: Text(widget.message),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
          Like(isLiked: isLiked, onTap: toggleLike),
          Padding(
            padding: const EdgeInsets.only(right: 7),
            child: Text(widget.likes.length.toString()),
          ),
        ],
      ),
    );
  }
}
