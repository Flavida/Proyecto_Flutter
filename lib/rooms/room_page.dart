import 'package:flutter/material.dart';
import 'package:flutter_nuevo/rooms/reserve_page.dart';
import 'package:dio/dio.dart';
import '../storage.dart';

// Define una clase StatefulWidget para la pantalla de salas
class RoomsScreen extends StatefulWidget {
  const RoomsScreen({Key? key}) : super(key: key);

  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

// Define la clase State correspondiente a RoomsScreen
class _RoomsScreenState extends State<RoomsScreen> {
  // Declara una lista de objetos Room para almacenar las salas disponibles
  List<Room> _rooms = [];

  @override
  void initState() {
    super.initState();
    // Llama a fetchRooms cuando se inicializa el estado
    fetchRooms();
  }

  // Define una función asíncrona para obtener las salas disponibles
  Future<void> fetchRooms() async {
    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer ${TokenStorage.idToken}',
    };
// Define la URL de la API para obtener las salas
    final url = 'https://api.sebastian.cl/booking/v1/rooms/';

    Dio dio = Dio();
// Realiza la solicitud HTTP GET
    try {
      final res = await dio.get(url, options: Options(headers: headers));
      final status = res.statusCode;
      if (200 != status) throw Exception('http.get error: statusCode= $status');
// Convierte la respuesta JSON a una lista de objetos Room
      List<dynamic> roomsJson = res.data;

      setState(() {
        _rooms = roomsJson.map((json) => Room.fromJson(json)).toList();
      });
    } catch (e) {
      if (e is DioError && e.response?.statusCode == 503) {
      } else {
        rethrow;
      }
    }
  }

  @override
  // Define el widget de la pantalla de salas
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exploración de Salas'),
      ),
      body: Column(
        children: [
          // Utiliza un Expanded para que el ListView ocupe todo el espacio restante
          Expanded(
            // Utiliza un ListView.builder para mostrar la lista de salas
            child: ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return Card(
                  child: Stack(
                    children: [
                      ListTile(
                        title: Text(room.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Muestra los campos de la sala
                            Text('Código: ${room.code}'),
                            Text('Ubicación: ${room.location}'),
                            Text('Nombre: ${room.name}'),
                            Text('Capacidad: ${room.capacity}'),
                            Text('Descripción: ${room.description}'),
                          ],
                        ),
                      ),
                      Align(
                        // Utiliza un botón elevado para reservar la sala
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          child: Text('Reservar'),
                          onPressed: () {
                            // Navega a la pantalla de reserva de salas
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    // Pasa el código de la sala a la pantalla de reserva
                                    builder: (context) =>
                                        ReservePage(roomCode: room.code)));
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Define una clase Room para almacenar los datos de una sala
class Room {
  final String code;
  final String location;
  final String name;
  final int capacity;
  final String description;

// Define un constructor para la clase Room
  Room(this.name, this.capacity, this.description, this.code, this.location);
// Define una función para crear una instancia de Room a partir de un mapa JSON
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      json['name'] ?? '',
      json['capacity'] ?? 0,
      json['description'] ?? '',
      json['code'] ?? '',
      json['location'] ?? '',
    );
  }
}
