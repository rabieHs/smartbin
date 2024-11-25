import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:mysql1/mysql1.dart';

final sl = GetIt.instance;

class Initializer {
  static Future<MySqlConnection> createConnection() async {
    var settings = ConnectionSettings(
        host: 'localhost', port: 3306, user: 'root', db: 'smartbin');
    return await MySqlConnection.connect(settings);
  }
}

class ConnectionPool {
  final List<MySqlConnection> _connections = [];
  final int _maxConnections = 5; // Limit number of connections

  Future<MySqlConnection> getConnection() async {
    if (_connections.isEmpty) {
      return await Initializer.createConnection();
    } else {
      // Return an available connection
      return _connections.removeLast();
    }
  }

  void releaseConnection(MySqlConnection connection) {
    if (_connections.length < _maxConnections) {
      _connections.add(connection);
    } else {
      connection.close(); // Close if we have too many connections
    }
  }
}
