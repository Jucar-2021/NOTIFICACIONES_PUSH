import 'package:ag4_notificaciones/LoginScreen.dart';
import 'package:ag4_notificaciones/MessageScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String tokenUsuario;

  const HomeScreen({super.key, required this.tokenUsuario});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<DocumentSnapshot> users = [];

  ///esta variable la hacemos para manejar de forma local tokenUsusario y manejar de mejor forma los usuarios del grupo disponible
  String? currentUSEmail;

  @override
  void initState() {
    _getUsers();
    super.initState();

    ///escuchar notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotificationDialog(
          title: message.notification?.title ?? "Nueva Notificación",
          message: message.notification?.body ?? "Sin contenido");
    });

    /// manejo para que la app se abra desde una notificxacion
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _showNotificationDialog(
          title: message.notification?.title ?? "Notificación Recibida",
          message: message.notification?.body ?? "Sin contenido");
    });
  }

  /// se aplica diseño al dialoogo de notificacion
  void _showNotificationDialog(
      {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Row(
            children: [
              Icon(Icons.notifications, color: Colors.blue, size: 28),
              SizedBox(width: 10),
              Text(title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message, style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cerrar",
                  style: TextStyle(fontSize: 16, color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  /// se optienen los usuarios de s de firebase
  Future<void> _getUsers() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    currentUSEmail = currentUser?.email;

    /// aqui optenemos el usuario con el que se inicio sesion

    QuerySnapshot snapshot = await db.collection("users").get();
    print("Usuarios encontrados: ${snapshot.docs.length}");
    setState(() {
      users = snapshot.docs;
    });
  }

  /// cerrar sesion y regresa a pantalla de login
  void _logout() {
    FirebaseAuth.instance.signOut().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Correos del Grupo", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: users.isEmpty
          ? Center(
              child: Text(
                "No hay usuarios disponibles",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: users.length,
              itemBuilder: (ctx, index) {
                final user = users[index].data() as Map<String, dynamic>;
                final email = user["email"] ?? "No email";

                /// se usa la variable locar para verificar con cual usuario se inicio sesion y no mostrarlo
                /// es mas practico hacienlo las variables que se pasan de otras clases locales
                final isCurrentUser = email == currentUSEmail;
                if (isCurrentUser) return SizedBox.shrink();

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        email.substring(6,7).toUpperCase(),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(email,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.chat, color: Colors.blue),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MessageScreen(doc: users[index])),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
