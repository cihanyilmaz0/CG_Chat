import 'package:cgchat/Screens/RegisterScreen.dart';
import 'package:cgchat/Services/auth_service.dart';
import 'package:cgchat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool visible = true;
  bool loading=false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          colors: [ Color(0xFF846AFF), Color(0xFF755EE8), Colors.purpleAccent,Colors.amber,],
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
              SizedBox(
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
              Row(
                children: [
                  Checkbox(value: !visible, checkColor: Colors.deepPurpleAccent,
                    onChanged: (value) {
                    visible=!visible;
                    setState(() {

                    });
                  },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    activeColor: Colors.white,
                  ),
                  const Padding(padding: EdgeInsets.only(),
                      child: Text("Şifreyi Göster",)
                  ),
                ],
              ),
              SizedBox(height: 20,),
              SizedBox(
                width: 150,
                height: 50,
                child: loading ? SizedBox(height: 50,width: 50,child: CircularProgressIndicator()) : ElevatedButton(
                  child: Text("Giriş Yap",style: TextStyle(color: Colors.black),),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)),side: BorderSide(color: Colors.black38)),
                  ),
                  onPressed: () {
                    setState(() {
                      loading=true;
                    });
                    if(mailController.text=="" || passwordController.text==""){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tüm bilgileri eksiksiz girin!"),backgroundColor: Colors.red,));
                      setState(() {
                        loading=false;
                      });
                    }
                    else{
                      AuthService().login(mailController.text, passwordController.text, context);
                      setState(() {
                        loading=false;
                      });
                    }
                  },
                ),
              ),
              TextButton(
                child: Text("Hesabın Yok Mu ?",style: TextStyle(color: Colors.blue,),),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                },
              ),
              Divider(),
              loading? CircularProgressIndicator() : SignInButton(
                buttonType: ButtonType.googleDark,
                btnText: "Google ile giriş yap",
                btnTextColor: Colors.black,
                btnColor: Colors.white,
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
