// Define una clase para almacenar el token de identificación
class TokenStorage {
  static String? _idToken;

  // Define un getter para obtener el token de identificación
  static String? get idToken => _idToken;
  static void setToken(String? token) {
    _idToken = token;
  }
}
