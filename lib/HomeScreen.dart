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

  @override
  void initState() {
    // TODO: implement initState

    _getUsers();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 onMessage: ${message.notification?.title}");
      _showMessage("Notificación: ", "${message.notification?.body}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 onMessageOpenedApp: ${message.notification?.title}");
      _showMessage("Notificación: ", "${message.notification?.body}");
    });

    /* if(Platform.isIOS){
        _firebaseMessaging.requestNotificationPermissions();
        const IosNotificationSettings(sound: true, badge: true, alert:  true, provisional: true);
    }*/
    super.initState();
  }

  _showMessage(title, message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: Text("Dismiss"),
            )
          ],
        );
      },
    );
  }

  _getUsers() async {
    QuerySnapshot snapshot = await db.collection("users").get();
    setState(() {
      users = snapshot.docs;
      print(users);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Colors.black,
            onPressed: () {
              FirebaseAuth.instance.signOut().then((val) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ));
              });
            },
          )
        ],
      ),
      body: Container(
        child: users != null
            ? ListView.builder(
                itemCount: users.length,
                itemBuilder: (ctx, index) {
                  return Container(
                    child: (users[index].data()
                                as Map<String, dynamic>)["fcmToken"] ==
                            widget.tokenUsuario
                        ? Container()
                        : ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                (users[index].data()
                                            as Map<String, dynamic>)["email"]
                                        ?.toString()
                                        .substring(0, 1) ??
                                    "?",
                              ),
                            ),
                            title: Text(
                              (users[index].data()
                                      as Map<String, dynamic>)["email"] ??
                                  "No email",
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessageScreen(
                                    doc: users[index],
                                  ),
                                ),
                              );
                            },
                          ),
                  );
                })
            : CircularProgressIndicator(),
      ),
    );
  }
}
