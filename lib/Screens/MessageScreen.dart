import 'package:cgchat/Models/Navigation.dart';
import 'package:cgchat/Screens/SendMessageScreen.dart';
import 'package:cgchat/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  String currentUseruid = AuthService().firebaseAuth.currentUser!.uid;

  Future<String?> getUserProfileImageURL(String karsiID) async {

    QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('uid', isEqualTo: karsiID)
        .limit(1)
        .get();

    if (userQuerySnapshot.size > 0) {
      DocumentSnapshot userSnapshot = userQuerySnapshot.docs[0];
      return userSnapshot.get('imageURL').toString();
    }
    return null;
  }

  Future getUserDetail(String gonderenid) async {

    QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('uid', isEqualTo: gonderenid)
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
        title: const Text("Mesajlar",style: TextStyle(fontFamily: "Pacifico")),
        backgroundColor: Colors.deepPurple,
        toolbarHeight: 65,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Messages').where('users', arrayContains: currentUseruid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Veriler yüklenirken bir hata oluştu.'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Hiç mesajınız yok.'),
                  );
                }
                List<QueryDocumentSnapshot> data = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  reverse: true,
                  padding: const EdgeInsets.only(top: 16),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final messageRef = data[index].reference.collection('message');
                    return StreamBuilder<QuerySnapshot>(
                      stream: messageRef.orderBy('time', descending: true).limit(1).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Veriler yüklenirken bir hata oluştu: ${snapshot.error.toString()}'),
                          );
                        }
                        final messages = snapshot.data!.docs;
                        if (messages.isEmpty) {
                          return const Center(
                            child: Text('Hiç mesajınız yok.'),
                          );
                        }
                        final messageData = messages.first.data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () async {
                            String otherUserID =
                            data[index].id.split('-')[0] == currentUseruid
                                ? data[index].id.split('-')[1]
                                : data[index].id.split('-')[0];
                            String? profileImageURL = await getUserProfileImageURL(otherUserID);
                            dynamic userDetail = await getUserDetail(otherUserID);
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => SendMessageScreen(
                                  yollayan: AuthService().firebaseAuth.currentUser!.uid,
                                  alan: data[index].id.split('-')[0] == currentUseruid
                                      ? data[index].id.split('-')[1]
                                      : data[index].id.split('-')[0],
                                  username: userDetail['username'],
                                  imgURL: profileImageURL!,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                            padding: const EdgeInsets.only(top: 25,bottom: 25,right: 10,left: 10),
                            child: Column(
                              children: [
                                FutureBuilder(
                                  future: data[index].id.split('-')[0] == currentUseruid ? getUserProfileImageURL(data[index].id.split('-')[1]):getUserProfileImageURL(data[index].id.split('-')[0]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (snapshot.hasData) {
                                      String? profileImageURL = snapshot.data;
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          CircleAvatar(radius: 30,backgroundImage: profileImageURL != "" ? NetworkImage(profileImageURL!) : const NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdslTMhVTjNETp90xvGrt1MMl9BxFxHygX9g&usqp=CAU")),
                                          FutureBuilder(
                                            future: data[index].id.split('-')[0] == currentUseruid ? getUserDetail(data[index].id.split('-')[1]):getUserDetail(data[index].id.split('-')[0]),
                                            builder: (context, snapshot) {
                                              var result = snapshot.data;
                                              if(snapshot.hasData){
                                                return Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Padding(padding: const EdgeInsets.only(left: 8),child: Text(result['username'],style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w700),)),
                                                      Padding(padding: const EdgeInsets.only(top: 8,left: 8),child: Text(messageData['message'].toString().length>30 ? messageData['message'].toString().substring(0, 20) + '...' : messageData['message']),),
                                                    ]
                                              );
                                              }else{
                                                return const CircularProgressIndicator();
                                              }
                                            },
                                          ),
                                          const Spacer(),
                                          Padding(padding: const EdgeInsets.only(right: 18), child: Text(DateFormat('hh:mm').format(messageData['time'].toDate()).toString(),style: const TextStyle(fontSize: 12),)),
                                          CircleAvatar(radius: 10,
                                              backgroundColor: messageData['isRead']==false &&
                                                  messageData['sendBy'] != currentUseruid ? Colors.blue : Colors.transparent)
                                        ],
                                      );
                                    }else{
                                      return const CircularProgressIndicator();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navigation(index: 1),
    );
  }
}
