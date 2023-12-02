// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_nuevo/services/logged_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../storage.dart';

class LoginPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final String? idToken = googleAuth.idToken;

        // Verifica si el correo electrónico del usuario termina en @utem.cl
        if (googleUser.email.endsWith('@utem.cl')) {
          TokenStorage.setToken(idToken); // Almacena el token
          print('Token de sesión: $idToken');
          if (idToken != null) {
            // Mostrar la lista de salas en la pantalla Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoggedInWidget(),
              ),
            );
          }
        } else {
          await _googleSignIn.signOut(); // Cierra la sesión de la cuenta actual
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Inicio de sesión denegado'),
                content: Text(
                    'Solo los usuarios con un correo electrónico @utem.cl pueden iniciar sesión.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // cierra el cuadro de diálogo
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('Inicio de sesión cancelado.');
      }
    } catch (error) {
      print('Error al iniciar sesión: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proyecto Flutter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('image/descarga1.jpg'),
            SizedBox(height: 20), // Añade un espacio entre la imagen y el botón
            ElevatedButton(
              onPressed: () => _handleSignIn(context),
              child: Text(
                'Iniciar Sesión con Google',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
