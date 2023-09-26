import 'package:cgchat/Screens/LoginScreen.dart';
import 'package:cgchat/Services/auth_service.dart';
import 'package:cgchat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  bool visible = true;
  bool loading= false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [ Color(0xFF846AFF), Color(0xFF755EE8), Colors.purpleAccent,Colors.amber,],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("CG Chat",style: TextStyle(fontFamily: 'Pacifico',fontSize: 50,color: Colors.white)),
                SizedBox(height: 100),
                TextField(
                  controller: mailController,
                  style: TextStyle(color: Colors.black),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Mail Girin",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: passwordController,
                  style: TextStyle(),
                  obscureText: visible ? true : false,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Şifre Girin",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: confirmController,
                  style: TextStyle(),
                  obscureText: visible ? true : false,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Şifre Tekrar",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
                Row(
                  children: [
                    Checkbox(value: !visible, checkColor: Colors.deepPurpleAccent,
                      onChanged: (value) {
                        visible=!visible;
                        setState(() {

                        });
                      },
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                      activeColor: Colors.white,
                    ),
                    const Padding(padding: EdgeInsets.only(),
                        child: Text("Şifreyi Göster",)
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: loading ? const SizedBox(width: 50,height: 50,child: CircularProgressIndicator()) : ElevatedButton(
                    child: Text("Kayıt Ol",style: TextStyle(color: Colors.black),),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)),side: BorderSide(color: Colors.black38)),
                    ),
                    onPressed: () async {
                      loading=true;
                      if(mailController.text=="" || passwordController.text=="" || confirmController.text=="" ) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tüm alanları doldurun !"),backgroundColor: Colors.red,));
                        setState(() {
                          loading=false;
                        });
                      }else if(passwordController.text!=confirmController.text){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Şifreler aynı değil !"),backgroundColor: Colors.red,));
                        setState(() {
                          loading=false;
                        });
                      }
                      else{
                        User? result = await AuthService().register(mailController.text, passwordController.text,context);
                        final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("Users").where('mail',isEqualTo: mailController.text).get();
                        if(snapshot.docs.isEmpty){
                          Map<String,dynamic> data = {'uid':AuthService().firebaseAuth.currentUser!.uid,'mail':mailController.text,'date':DateTime.now(),'username':mailController.text.split('@')[0],'bio':'Empty bio...','imageURL':'','name':'','number':''};
                          FirebaseFirestore.instance.collection("Users").add(data);
                             if(result != null){
                                mailController.text="";
                                passwordController.text="";
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                            }
                        }
                        setState(() {
                          loading=false;
                        });
                      }
                    },
                  ),
                ),
                TextButton(
                  child: Text("Hesabın Var Mı ?",style: TextStyle(color: Colors.blue,),),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                ),
                Divider(),
                SignInButton(
                  buttonType: ButtonType.googleDark,
                  btnText: "Google ile giriş yap",
                  btnColor: Colors.white,
                  btnTextColor: Colors.black,
                  onPressed: () async{
                    await AuthService().signinWithGoogle();
                    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("Users").where('mail',isEqualTo: AuthService().firebaseAuth.currentUser?.email).get();
                    if(snapshot.docs.isEmpty){
                      Map<String,dynamic> data = {'uid':AuthService().firebaseAuth.currentUser!.uid,'mail':AuthService().firebaseAuth.currentUser?.email,'date':DateTime.now(),'username':AuthService().firebaseAuth.currentUser?.email!.split('@')[0],'bio':'Empty bio...','imageURL':'','name':'','number':''};
                      FirebaseFirestore.instance.collection("Users").add(data);
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
                  },
                ),
              ],
            ),
          ),
        )
    );
  }
}
