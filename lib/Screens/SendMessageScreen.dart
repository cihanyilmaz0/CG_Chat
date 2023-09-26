import 'package:cgchat/Models/Message.dart';
import 'package:cgchat/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendMessageScreen extends StatefulWidget {
  final String yollayan;
  final String alan;
  final String username;
  final String imgURL;


  const SendMessageScreen({super.key,required this.yollayan,required this.alan,required this.username,required this.imgURL});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  TextEditingController controller = TextEditingController();

  Future<bool> checkAndRetrieveData(String docID) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('Messages')
        .where('docID', isEqualTo: docID)
        .get();
    if (querySnapshot.docs.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  void closeKeyboard() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
  }




  void postMessage(bool data,String docID) async{
    if(controller.text.isNotEmpty){
      if(data){
        await FirebaseFirestore.instance.collection('Messages').doc(docID).collection('message').add(
            {
              'message':controller.text,
              'sendBy':widget.yollayan,
              'sendTo':widget.alan,
              'time':DateTime.now(),
              'isRead':false
            }
        );
        }else{

        await FirebaseFirestore.instance.collection('Messages').doc(docID).collection('message').add(
            {
              'message':controller.text,
              'sendBy':widget.yollayan,
              'sendTo':widget.alan,
              'time':DateTime.now(),
              'isRead':false
            }
        );
        await FirebaseFirestore.instance.collection('Messages').doc(docID).set(
            {
              'users':[widget.yollayan,widget.alan],
              'docID': docID
            }
        );
      }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          closeKeyboard();
        },
        child: Container(
          decoration: const BoxDecoration(
              color: Colors.deepPurple
          ),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(height: 40,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  Text(widget.username,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  const Spacer(),
                  Padding(padding: const EdgeInsets.only(right: 10),child: CircleAvatar(backgroundImage: widget.imgURL != "" ? NetworkImage(widget.imgURL) : const NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdslTMhVTjNETp90xvGrt1MMl9BxFxHygX9g&usqp=CAU"))),
                ],
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Messages')
                    .doc('${widget.yollayan}-${widget.alan}')
                    .collection('message')
                    .orderBy('time',descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Veri okuma hatası: ${snapshot.error}');
                  }
                  if(snapshot.data!.docs.isNotEmpty){
                    if(snapshot.data!.docs[0]['sendBy']!=AuthService().firebaseAuth.currentUser!.uid){
                      snapshot.data!.docs.forEach((element) {element.reference.update(
                          {
                            'isRead':true
                          });});
                    }
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Messages')
                          .doc('${widget.alan}-${widget.yollayan}')
                          .collection('message')
                          .orderBy('time',descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Veri okuma hatası: ${snapshot.error}');
                        }
                        if(snapshot.data!.docs.isNotEmpty){
                          if(snapshot.data!.docs[0]['sendBy']!=AuthService().firebaseAuth.currentUser!.uid){
                            snapshot.data!.docs.forEach((element) {element.reference.update(
                                {
                                  'isRead':true
                                });});
                          }
                        }
                        return Message(snapshot);
                      },
                    );
                  }
                  return Message(snapshot);
                  },
              ),
            ],
          ),
        ),
      ),
      bottomSheet: SizedBox(
        height: 40,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Mesaj gönder...",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none
            ),
            contentPadding: const EdgeInsets.only(left: 10),
            suffixIcon: IconButton(
              onPressed: () async{
                bool hasData= await checkAndRetrieveData("${widget.yollayan}-${widget.alan}");
                if(hasData){
                  postMessage(hasData,"${widget.yollayan}-${widget.alan}");
                }
                else{
                  bool hasData2= await checkAndRetrieveData("${widget.alan}-${widget.yollayan}");
                  if(hasData2){
                    postMessage(hasData2,"${widget.alan}-${widget.yollayan}");
                  }else{
                    postMessage(hasData2,"${widget.yollayan}-${widget.alan}");
                  }
                }
                controller.clear();
              },
              icon: const Icon(Icons.send),
            ),
          ),
        ),
      ),
    );
  }
}