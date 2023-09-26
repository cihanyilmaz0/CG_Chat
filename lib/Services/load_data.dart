import 'dart:typed_data';
import 'package:cgchat/Services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage storage = FirebaseStorage.instance;

class StoreData{

  Future<String> uploadImage(String childName,Uint8List file) async {
    Reference ref = storage.ref().child(childName);
    UploadTask task = ref.putData(file);
    TaskSnapshot snapshot = await task;
    String downloadUrl= await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future saveData({required Uint8List file}) async{
    try{
      String imgUrl= await uploadImage('image/${FirebaseAuth.instance.currentUser!.uid}', file);
      var a = FirebaseFirestore.instance.collection('Users').where('uid',isEqualTo: AuthService().firebaseAuth.currentUser!.uid).get();
      a.then((value) => {value.docs.single.reference.update({'imageURL':imgUrl})});
    }catch(e){
      print(e.toString());
    }
  }


}