import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final DocumentSnapshot doc;

  const MessageScreen({super.key, required this.doc});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  User? user;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  /// obtencion del usuario autenticado
  Future<void> _getUser() async {
    User? currentUser = auth.currentUser;
    if (mounted) {
      setState(() {
        user = currentUser;
      });
    }
  }

  /// metodo para envio de mensajes
  void _sendMessage(String message) {
    if (message.isEmpty) {
      _showSnackbar("No se pueden enviar mensajes en blanco.");
      return;
    }

    db.collection("users").doc(widget.doc.id).collection("notifications").add({
      "message": message,
      "title": user?.email ?? "Usuario desconocido",
      "date": FieldValue.serverTimestamp(),
    }).then((_) {
      controller.clear();
      _showSnackbar("Mensaje enviado con éxito.");
      _showSnackbar("Si el usuario no esta activo se retorna el mensaje");
    }).catchError((error) {
      _showSnackbar("Error al enviar mensaje: $error");
    });
  }

  /// manejo de mensajes
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blueAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = (widget.doc.data() as Map<String, dynamic>)["email"] ??
        "Usuario desconocido";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          email,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Escribe tu mensaje...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  maxLines: 4,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _sendMessage(controller.text),
        backgroundColor: Colors.blueAccent,
        elevation: 6,
        child: Icon(Icons.send, size: 30, color: Colors.white),
      ),
    );
  }
}
