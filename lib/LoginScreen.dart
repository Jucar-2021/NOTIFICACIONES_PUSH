import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toast/toast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    checkUserAuth();
  }

  /// verificacion si el usuario esta autenticado
  checkUserAuth() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        String? token = await obtenerToken();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(tokenUsuario: token!),
          ),
        );
      }
    } catch (e) {
      print("Error inesperado: " + e.toString());
    }
  }

  /// metodo de inicio de sesion
  void login() {
    String email = mailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showToast("El email y la contraseña son obligatorios", duration: 3, gravity: Toast.bottom);
      return;
    }

    auth.signInWithEmailAndPassword(email: email, password: password).then(
          (result) async {
        String? token = await obtenerToken();
        User? user = result.user;
        db.collection("users").doc(user?.uid).set({"email": user?.email, "fcmToken": token});

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(tokenUsuario: token!),
          ),
        );
      },
    ).catchError((error) {
      showToast("Correo o contraseña incorrectos", duration: 2, gravity: Toast.center);
    });
  }

  /// muestra de un mensaje `Toast`
  void showToast(String msg, {int? duration, int? gravity}) {
    Toast.show(msg, duration: duration, gravity: gravity);
  }

  /// obtencion el token de Firebase Messaging
  Future<String?> obtenerToken() async {
    return await firebaseMessaging.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Color de fondo suave
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/logoApp.jpg", height: 100), // Logo de la app
                  SizedBox(height: 40),
                  TextField(
                    controller: mailController,
                    decoration: InputDecoration(
                      labelText: "Correo Electrónico",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: (){
                      if(mailController.text.isEmpty || passwordController.text.isEmpty){
                        showToast('Los campos Correo Electronico y Contraseña son requeridos',duration: 3,gravity: Toast.top);
                      }else{
                        loginGoogle();
                      }
                    },
                    child: Text("Iniciar Sesión", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// proceso del login se carga el splash
  void loginGoogle() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SplashPantalla(),
    );

    Future.delayed(Duration(seconds: 6), () {
      Navigator.pop(context);
      login();
    });
  }
}

/// carga de animaciones tiempo para validar credenciales
class SplashPantalla extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/logi.gif", height: 100),
            SizedBox(height: 15),
            CircularProgressIndicator(),
            SizedBox(height: 15),
            Text("Cargando...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
