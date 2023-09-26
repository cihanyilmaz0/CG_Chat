import 'dart:typed_data';
import 'package:cgchat/Models/LoginOrRegister.dart';
import 'package:cgchat/Models/Navigation.dart';
import 'package:cgchat/Screens/HomePage.dart';
import 'package:cgchat/Services/auth_service.dart';
import 'package:cgchat/Services/load_data.dart';
import 'package:cgchat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../Models/image_pick.dart';

class ProfileScreen extends StatefulWidget {

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  Uint8List? image;


  Future<void> editField(String field,String newValue) async{
    if(newValue.trim().length>0){
      var a = FirebaseFirestore.instance.collection('Users').where('uid',isEqualTo: AuthService().firebaseAuth.currentUser!.uid).get();
       a.then((value) => {value.docs.single.reference.update({field:newValue})});
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(field + "Değiştirilemedi.")));
    }
  }
  int counter = 1;
  void selectImage() async{
    Uint8List img= await pickImage(ImageSource.gallery);
    setState(() {
      image=img;
    });
    StoreData().uploadImage('image/${FirebaseAuth.instance.currentUser!.uid + "  " + counter.toString()}', image!);
    counter+=1;
    StoreData().saveData(file: image!);
  }
  

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Ayarları",style: TextStyle(fontFamily: "Pacifico")),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        toolbarHeight: 65,
      ),
      backgroundColor: Colors.grey[300],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').where('uid',isEqualTo: AuthService().firebaseAuth.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            final userData=snapshot.data!.docs;
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 15,),
                    Stack(
                      children: [
                            CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.black,
                            backgroundImage: userData[0].get('imageURL').length != 0 ? NetworkImage(userData[0].get('imageURL')) : null
                            ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),color: Colors.white
                            ),
                            child: IconButton(
                              icon: Icon(Icons.camera_alt),
                              onPressed: () {
                                selectImage();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10,top: 20,right: 10,bottom: 20),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            hintText: userData[0].get('username'),
                            labelText: "Kullanıcı Adı",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10,right: 10,bottom: 20),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: userData[0].get('name'),
                            labelText: "Adı Soyadı",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10,right: 10,bottom: 20),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          controller: bioController,
                          decoration: InputDecoration(
                            hintText: userData[0].get('bio'),
                            labelText: "Biyografi",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10,right: 10,bottom: 20),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          controller: numberController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: userData[0].get('number'),
                            labelText: "Telefon Numarası",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          editField('username', usernameController.text);
                          editField('name', nameController.text);
                          editField('bio', bioController.text);
                          editField('number', numberController.text);
                        },
                        child: Text("Kaydet"),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                            child: Text("Kayıt tarihi ${DateFormat("dd/MM/yyyy").format(userData[0].get('date').toDate()).toString()}")),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Text("Hesabı silmek istediğinize emin misiniz ?"),
                                    actions: [
                                      TextButton(
                                        child: Text("Evet"),
                                        onPressed: () async {
                                          QuerySnapshot snapuser = await FirebaseFirestore.instance.collection('Users').where('uid',isEqualTo: AuthService().firebaseAuth.currentUser!.uid).get();
                                          QuerySnapshot snappost = await FirebaseFirestore.instance.collection('UsersPost').where('UserMail',isEqualTo: AuthService().firebaseAuth.currentUser!.email).get();
                                          QuerySnapshot snapmessage = await FirebaseFirestore.instance.collection('Messages').where('users',arrayContains: AuthService().firebaseAuth.currentUser!.uid).get();
                                          for (DocumentSnapshot document in snappost.docs) {
                                            await document.reference.delete();
                                          }for (DocumentSnapshot document in snapmessage.docs) {
                                            await document.reference.delete();
                                          }for (DocumentSnapshot document in snapuser.docs) {
                                            await document.reference.delete();
                                          }
                                          FirebaseAuth.instance.currentUser!.delete();
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                                        },
                                      ),
                                      TextButton(
                                        child: Text("Hayır"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text("Sil"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }else{
            return CircularProgressIndicator();
          }
        },
      ),
      bottomNavigationBar: Navigation(index: 2),
    );
  }
}