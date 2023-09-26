import 'package:cgchat/Services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message extends StatefulWidget {
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot;


  Message(this.snapshot);

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(50),topRight: Radius.circular(50)),
          color: Colors.black87,
        ),
        margin: const EdgeInsets.only(top: 30),
        padding: const EdgeInsets.only(top: 20,left: 10,right: 10,bottom: 60),
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                reverse: true,
                itemCount: widget.snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: widget.snapshot.data!.docs[index]['sendBy']==AuthService().firebaseAuth.currentUser!.uid ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.snapshot.data!.docs[index]['sendBy']==AuthService().firebaseAuth.currentUser!.uid ? Colors.white : Colors.grey,
                        borderRadius: const BorderRadius.all(Radius.circular(10))
                      ),
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(8),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width*0.66
                      ),
                        child: Text(widget.snapshot.data!.docs[index]['message'],style: const TextStyle(fontSize: 14)),
                      ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
