import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final DocumentSnapshot doc;

  const MessageScreen({
    super.key,
    required this.doc,
  });

  // const MessageScreen({Key key, this.doc}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late User user;
  TextEditingController controller = TextEditingController();

  _getUser() async {
    User? u = FirebaseAuth.instance.currentUser;
    setState(() {
      user = u!;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _getUser();
    super.initState();
  }

  _messagehandler(String entrada) {
    print(entrada);
    db.collection("users").doc(widget.doc.id).collection("notifications").add({
      "message": entrada,
      "title": user.email,
      "date": FieldValue.serverTimestamp()
    }).then((document) {
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (widget.doc.data() as Map<String, dynamic>)["email"],
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    // 90% del ancho de la pantalla para evitar desvordamiento independiente del
                    //tamaño del dispositivo
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: "¿Cuál es el mensaje?",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                  padding: EdgeInsets.all(30),
                  child: SizedBox(
                    width: 125,
                    height: 125,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (controller.text.isNotEmpty) {
                            _messagehandler(controller.text);
                          }
                          print("GIF presionado");
                        },
                        child: Image.asset("assets/send.gif"),
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
