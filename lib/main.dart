//Main.dart
import 'package:ag4_notificaciones/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:lottie/lottie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: SplashPantalla(),
    );
  }
}

class SplashPantalla extends StatelessWidget {
  const SplashPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    // ajuste del tiempo de pantalla de presentacion
    Future.delayed(
      const Duration(seconds: 5),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
    );

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned.fill(
              child: Lottie.asset("assets/noti.json"),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Iniciando Aplicación',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey),
                ),
                centerTitle: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
