import 'package:ag4_notificaciones/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toast/toast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController mailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    ToastContext().init(context);
    checkUserAuth();
    super.initState();
  }

  checkUserAuth() async {
    try {
      User? user = await auth.currentUser;
      if (user != null) {
        String? token = await obtenerToken();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                tokenUsuario: token!,
              ),
            ));
      }
    } catch (e) {
      print("Error A " + e.toString());
    }
  }

  //Método para loguear
  login() {
    String email = mailController.text;
    String password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((result) async {
        //Registrar fcm key
        String? token = await obtenerToken();
        User? user = result.user;
        db
            .collection("users")
            .doc(user?.uid)
            .set({"email": user?.email, "fcmToken": token});

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                tokenUsuario: token!,
              ),
            ));
      }).catchError((error) {
        showToast("Error " + error.toString(), gravity: Toast.center);
      });
    } else {
      showToast("Provide email and password", gravity: Toast.center);
    }
  }

  void showToast(String msg, {int? duration, int? gravity}) {
    Toast.show(msg, duration: duration, gravity: gravity);
  }

  Future<String?> obtenerToken() async {
    return await firebaseMessaging.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: mailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),

                  labelText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                 
                    labelText: "Password"),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
              ),
            ),
            MaterialButton(
              color: Colors.green,
              child: Text("Login"),
              onPressed: () {
                login();
              },
            )
          ],
        ),
      ),
    );
  }
}
