// Ignora ciertas reglas de linting
// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously, prefer_const_constructors, sort_child_properties_last

// Importa los paquetes necesarios
import 'package:flutter/material.dart';
import '../services/delete.dart';
import '../storage.dart';
import 'package:dio/dio.dart';

// Define un widget con estado para la pantalla de historial
class HistoryScreen extends StatefulWidget {
  // Constructor
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  // Define la clase del estado para HistoryScreen
  ReservationHistoryScreen createState() => ReservationHistoryScreen();
}

// Define la clase del estado para HistoryScreen
class ReservationHistoryScreen extends State<HistoryScreen> {
  List<History> Historial = []; // Aquí almacenaremos las salas disponibles

  // Define los controladores para los campos de texto
  final roomCodeController = TextEditingController();
  final dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Retorna un widget Scaffold, que proporciona una estructura visual básica para la aplicación.
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Reservas'),
      ),
      body: Center(
        child: Column(
          // Alinea los widgets hijos en el centro
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Un espacio de altura 20
            SizedBox(height: 20),
            // Un widget Padding para agregar espacio alrededor del campo de texto
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                controller: roomCodeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Ingrese el codigo de sala',
                  filled: true,
                  // Color de fondo para el campo de texto
                  fillColor: Color.fromARGB(26, 167, 165, 165),
                ),
              ),
            ),
            // Un espacio de altura 40
            SizedBox(height: 40),
            // Un widget Padding para agregar espacio alrededor del campo de texto
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                controller: dateController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Ingrese la fecha de la reserva (YYYY-MM-DD)',
                  filled: true,
                  // Color de fondo para el campo de texto
                  fillColor: Color.fromARGB(26, 167, 165, 165),
                ),
              ),
            ),
            // Un espacio de altura 80
            SizedBox(height: 80),
            ElevatedButton(
              child: Text(
                'Obtener Reservas',
                style: TextStyle(fontSize: 15),
              ),
              // Acción al presionar el botón
              onPressed: () {
                // Obtiene el horario y luego actualiza el estado con el historial obtenido
                getSchedule(roomCodeController.text, dateController.text)
                    .then((history) {
                  setState(() {
                    Historial = history;
                  });
                }).catchError((error) {
                  // Maneja los errores
                  String errorMessage = error.toString();
                  if (errorMessage.contains('404')) {
                    errorMessage = 'No hay reservas';
                  } else if (errorMessage.contains('400')) {
                    errorMessage = 'No existe la sala';
                  } else {
                    errorMessage = errorMessage.replaceFirst('Exception: ', '');
                  }
                  // Muestra un cuadro de diálogo con el mensaje de error
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Reservas'),
                        content: Text(errorMessage),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // cierra el cuadro de diálogo
                              if (errorMessage ==
                                  'No se han encontrado reservas para esta sala') {
                                setState(() {
                                  Historial = []; // limpia la lista de reservas
                                });
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                });
              },
            ),
            // Un widget Expanded para llenar el espacio restante con una lista de reservas
            Expanded(
              child: ListView.builder(
                // Número de elementos en la lista
                itemCount: Historial.length,
                // Función para construir cada elemento de la lista
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Row(
                        children: <Widget>[
                          Text('Token: '),
                          // Texto dinámico basado en el elemento actual de la lista
                          Flexible(child: Text(Historial[index].token)),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text('Email: '),
                              // El widget Flexible evita desbordamientos si el texto es muy largo
                              Flexible(child: Text(Historial[index].userEmail)),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text('Room Code: '),
                              Flexible(child: Text(Historial[index].roomCode)),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text('Start Time: '),
                              Flexible(
                                  child:
                                      Text(Historial[index].start.toString())),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text('End Time: '),
                              Flexible(
                                  child: Text(Historial[index].end.toString())),
                            ],
                          ),
                        ],
                      ),
                      // Un botón en el extremo derecho del ListTile para eliminar la reserva
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          try {
                            // Intenta eliminar la reserva
                            await deleteReservation(Historial[index].token);
                          } catch (error) {
                            // Si hay un error, muestra un cuadro de diálogo con el mensaje de error
                            String errorMessage = error
                                .toString()
                                .replaceFirst('Exception: ', '');
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Eliminar Reserva'),
                                  content: Text(errorMessage),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // cierra el cuadro de diálogo
                                        getSchedule(roomCodeController.text,
                                                dateController.text)
                                            .then((history) {
                                          setState(() {
                                            Historial = history;
                                          });
                                        }).catchError((error) {
                                          // maneja cualquier error que pueda ocurrir
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Función asíncrona que obtiene el horario de una sala en una fecha específica
Future<List<History>> getSchedule(String roomCode, String date) async {
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer ${TokenStorage.idToken}'
  };
// Define la URL de la solicitud HTTP
  final url =
      'https://api.sebastian.cl/booking/v1/reserve/$roomCode/schedule/$date';

  Dio dio = Dio();
//  Realiza la solicitud HTTP
  try {
    final res = await dio.get(url, options: Options(headers: headers));
    final status = res.statusCode;

    if (status == 400) return Future.error('No existe la sala');
    if (status == 404)
      return Future.error('No se han encontrado reservas para esta sala');
    if (status != 200)
      return Future.error('http.get error: statusCode= $status');

    final List<History> history =
        (res.data as List).map((item) => History.fromJson(item)).toList();
    print('Response body: ${res.data}');
    return history;
  } catch (e) {
    final status = e;
    if (e == 400) return Future.error('No existe la sala');
    if (e == 404)
      return Future.error('No se han encontrado reservas para esta sala');
    if (e != 200) return Future.error('http.get error: statusCode= $status');
    return []; // Devuelve una lista vacía en caso de error
  }
}

// Clase para representar una reserva
class History {
  String token;
  String userEmail;
  String roomCode;
  DateTime start;
  DateTime end;

  // Constructor para la clase History
  History({
    required this.token,
    required this.userEmail,
    required this.roomCode,
    required this.start,
    required this.end,
  });

  // Función para crear una nueva instancia de History a partir de un mapa
  factory History.fromJson(Map<String, dynamic> json) => History(
        token: json["token"],
        userEmail: json["userEmail"],
        roomCode: json["roomCode"],
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
      );

  // Función para convertir una instancia de History en un mapa
  Map<String, dynamic> toJson() => {
        "token": token,
        "userEmail": userEmail,
        "roomCode": roomCode,
        "start": start.toIso8601String(),
        "end": end.toIso8601String(),
      };
}
