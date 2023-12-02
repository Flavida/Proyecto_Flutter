// Importa los paquetes necesarios
// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../storage.dart';

// Define una clase para la página de reservas que es un StatefulWidget
class ReservePage extends StatefulWidget {
  final String roomCode;

  // Constructor para la clase ReservePage
  ReservePage({required this.roomCode});

  @override
  _ReservePageState createState() => _ReservePageState();
}

// Define la clase _ReservePageState que es el estado de ReservePage
class _ReservePageState extends State<ReservePage> {
  // Controladores para los campos de texto
  final roomCodeController = TextEditingController();
  final dateController = TextEditingController();
  final startController = TextEditingController();
  final quantityController = TextEditingController();

  Future<Welcome>? reservationFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            // Muestra el código de la sala
            Text(
              'Codigo de sala: ${widget.roomCode}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 15),
            // Campo de texto para la fecha de la reserva
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Fecha de la Reserva (YYYY-MM-DD))',
                filled: true,
                fillColor: Color.fromARGB(26, 167, 165, 165),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // Campo de texto para la hora de inicio
            TextField(
              controller: startController,
              decoration: InputDecoration(
                labelText: 'Hora de inicio',
                filled: true,
                fillColor: Color.fromARGB(26, 167, 165, 165),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // Campo de texto para la cantidad de horas
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Cantidad de horas',
                filled: true,
                fillColor: Color.fromARGB(26, 167, 165, 165),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 80),
            // Botón para realizar la reserva
            ElevatedButton(
              child: Text('Reservar Sala'),
              onPressed: () async {
                // Verifica que todos los campos estén llenos
                if (dateController.text.isEmpty ||
                    startController.text.isEmpty ||
                    quantityController.text.isEmpty) {
                  // Muestra un SnackBar si algún campo está vacío
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Por favor, ingrese toda la información para continuar.'),
                    ),
                  );
                } else {
                  try {
                    // Intenta hacer la reserva
                    await makeReservation(
                      widget.roomCode,
                      dateController.text,
                      startController.text,
                      int.parse(quantityController.text),
                    );
                    // Muestra un cuadro de diálogo si la reserva se realizó con éxito
                    showDialog(
                      // Cuando el botón de reserva es presionado, se muestra un cuadro de diálogo
                      // Si la reserva se realiza con éxito, se muestra un cuadro de diálogo con el mensaje "Reserva realizada"
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Reserva realizada'),
                          content: Text('La reserva se realizó con éxito.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Cierra el cuadro de diálogo
                                Navigator.pop(
                                    context); // Navega a la página anterior
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } catch (e) {
                    // Si ocurre un error durante la reserva, se muestra un cuadro de diálogo con el mensaje de error
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('Error al realizar la reserva: $e'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Cierra el cuadro de diálogo
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
            ),
            // FutureBuilder se utiliza para realizar una operación asíncrona y actualizar la interfaz de usuario en función del resultado
            FutureBuilder<Welcome>(
              future: reservationFuture,
              builder: (context, snapshot) {
                // Muestra un indicador de progreso mientras la operación está en curso
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Muestra un mensaje de error si la operación falla
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  // Muestra los detalles de la reserva si la operación tiene éxito
                  return Text('Reservation: \n'
                      'Token: ${snapshot.data!.token}\n'
                      'User Email: ${snapshot.data!.userEmail}\n'
                      'Room Code: ${snapshot.data!.roomCode}\n'
                      'Start: ${snapshot.data!.start}\n'
                      'End: ${snapshot.data!.end}');
                } else {
                  return Text('');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

// Función para realizar una reserva
  Future<List<Welcome>> makeReservation(
      String roomCode, String date, String start, int quantity) async {
    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer ${TokenStorage.idToken}',
      'Content-Type': 'application/json',
    };
// Define el cuerpo de la solicitud
    final data = {
      'roomCode': roomCode,
      'date': date,
      'start': start,
      'quantity': quantity,
    };
// Define la URL de la solicitud
    final url = 'https://api.sebastian.cl/booking/v1/reserve/request';

    Dio dio = Dio();
    final res =
        await dio.post(url, options: Options(headers: headers), data: data);
    final status = res.statusCode;
    print(status);
    if (status != 201) throw Exception('La fecha ingresada ya paso');
    print('http.post error: statusCode= $status');
    print('Response body: ${res.data}');
//  Crea una lista de reservas a partir de la respuesta
    List<Welcome> welcomes;
    if (res.data is List) {
      welcomes = (res.data as List)
          .map((item) => Welcome.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (res.data is Map<String, dynamic>) {
      welcomes = [Welcome.fromJson(res.data)];
    } else {
      throw Exception('Unexpected body: ${res.data}');
    }
    return welcomes;
  }
}

// Define la clase Welcome
class Welcome {
  // Declara las propiedades de la clase
  String token;
  String userEmail;
  String roomCode;
  DateTime start;
  DateTime end;

  // Define el constructor de la clase
  Welcome({
    required this.token,
    required this.userEmail,
    required this.roomCode,
    required this.start,
    required this.end,
  });

  // Define una fábrica para crear una instancia de Welcome a partir de un mapa
  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        token: json["token"],
        userEmail: json["userEmail"],
        roomCode: json["roomCode"],
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
      );

  // Define un método para convertir una instancia de Welcome a un mapa
  Map<String, dynamic> toJson() => {
        "token": token,
        "userEmail": userEmail,
        "roomCode": roomCode,
        "start": start.toIso8601String(),
        "end": end.toIso8601String(),
      };
}
