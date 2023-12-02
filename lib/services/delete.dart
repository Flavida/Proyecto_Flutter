import 'package:dio/dio.dart';
import '../storage.dart';

// Define una función asíncrona para eliminar una reserva
Future<void> deleteReservation(String token) async {
// Define los encabezados de la solicitud
  final headers = {
    'accept': '*/*',
    'Authorization':
        'Bearer ${TokenStorage.idToken}', // Aquí se agrega el token de sesión
  };
// Define la URL de la API para eliminar una reserva
  final url = 'https://api.sebastian.cl/booking/v1/reserve/$token/cancel';

  Dio dio = Dio();
// Realiza la solicitud HTTP DELETE
  final res = await dio.delete(url, options: Options(headers: headers));
  final status = res.statusCode;
  print(status);
  if (status == 422) {
    throw Exception(res.data['message']);
  } else if (status != 200) {
    throw Exception('Reserva eliminada exitosamente');
  }
}
