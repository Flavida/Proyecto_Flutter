// Ignora las reglas de linting para constructores constantes y orden de propiedades de los hijos
// ignore_for_file: prefer_const_constructors, sort_child_properties_last
import 'package:flutter/material.dart';
import 'package:flutter_nuevo/rooms/historial.dart';
import 'package:flutter_nuevo/main.dart';
import 'package:flutter_nuevo/rooms/room_page.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Define una clase que extiende ChangeNotifier para proporcionar notificaciones a los widgets que la escuchan
class GoogleSignInProvider extends ChangeNotifier {
  // Crea una instancia de GoogleSignIn con el scope 'email'
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Método para iniciar sesión con Google
  Future<void> login() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      // Imprime el error si el inicio de sesión falla
      print('Error al iniciar sesión: $error');
    }
  }

  // Método para cerrar sesión en Google
  Future<void> logout() async {
    await _googleSignIn.signOut();
  }
}

// Define un widget sin estado para la pantalla de usuario logueado
class LoggedInWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sesión Iniciada'),
        centerTitle: false,
        actions: [
          // Un botón de texto para cerrar la sesión
          TextButton(
            child: Text('Cerrar Sesión'),
            style: TextButton.styleFrom(
              side: BorderSide(color: Colors.black12, width: 2),
            ),
            // Acción que se realiza al presionar el botón
            onPressed: () async {
              // Obtiene el proveedor de inicio de sesión de Google
              final provider =
                  Provider.of<GoogleSignInProvider>(context, listen: false);
              // Cierra la sesión
              await provider.logout();
              // Navega a la pantalla principal
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MyApp(),
                ),
              );
            },
          )
        ],
      ),
      // Cuerpo de la pantalla
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Un botón para explorar las salas
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Container(
                width: double.infinity, // Hace que el botón se alargue
                child: TextButton(
                  child: Text(
                    'Exploracion de Salas',
                    style: TextStyle(fontSize: 15),
                  ),
                  style: TextButton.styleFrom(
                    side: BorderSide(color: Colors.black12, width: 2),
                  ),
                  onPressed: () {
                    // Navega a la pantalla de salas
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RoomsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            // Un botón para ver el historial de reservas
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Container(
                width: double.infinity, // Hace que el botón se alargue
                child: TextButton(
                  child: Text(
                    'Historial de Reservas',
                    style: TextStyle(fontSize: 15),
                  ),
                  style: TextButton.styleFrom(
                    side: BorderSide(color: Colors.black12, width: 2),
                  ),
                  onPressed: () {
                    // Navega a la pantalla de historial
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HistoryScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
