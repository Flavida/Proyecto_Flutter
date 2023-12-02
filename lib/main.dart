// Importa los paquetes necesarios
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nuevo/services/logged_in.dart';
import 'services/login.dart'; // Importa la LoginPage desde su ubicación
import 'package:provider/provider.dart';

// Define la función main que es el punto de entrada de la aplicación
void main() async {
  // Asegura que se inicialicen los servicios de Flutter
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase
  await Firebase.initializeApp();
  // Ejecuta la aplicación
  runApp(
    // Proporciona una instancia de GoogleSignInProvider a los widgets que la necesiten
    ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: const MyApp(),
    ),
  );
}

// Define un widget sin estado para la aplicación
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTEM Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
