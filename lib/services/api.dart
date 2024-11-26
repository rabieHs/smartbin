import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bin/models/user.dart';
import 'package:smart_bin/utils/init.dart';
import 'package:smart_bin/models/container.dart';

class Api {
  // Get nearby containers
  Future<List<Trash>> getNearbyContainers(
      double longitude, double latitude) async {
    MySqlConnection connection = await Initializer.createConnection();

    List<Trash> containers = [];

    // Define the radius for nearby containers (e.g., 10km)
    double radius = 0.1;

    // MySQL query to find nearby containers using Haversine formula
    String query = """
      SELECT id, longitude, latitude, volume,
        (6371 * acos(cos(radians(?)) * cos(radians($latitude)) 
        * cos(radians($longitude) - radians(?)) 
        + sin(radians(?)) * sin(radians(latitude)))) AS distance 
      FROM containers 
      HAVING distance < ? 
      ORDER BY distance;
    """;

    // Execute the query using positional parameters
    var results =
        await connection.query(query, [latitude, longitude, latitude, radius]);

    // Parse the result into a list of Container objects
    for (var row in results) {
      print(row);
      containers.add(Trash(
        id: row['id'].toString(),
        longitude: row['longitude'],
        latitude: row['latitude'],
        volume: row['volume'],
      ));
    }
    print(containers);
    return containers;
  }

  // Fetch all containers
  Future<List<Trash>> getAllContainers() async {
    MySqlConnection connection = await Initializer.createConnection();
    List<Trash> containers = [];
    var settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',
      db: 'smartbin',
    );

    final conn = await MySqlConnection.connect(settings);
    var results = await conn.query('SELECT * FROM containers');
    print("results: $results");
    for (var row in results) {
      print(
          'Id: ${row['id']}, long: ${row['longitude']}, lat: ${row['latitude']}');
      containers.add(Trash(
        id: row['id'].toString(),
        longitude: row['longitude'],
        latitude: row['latitude'],
        volume: row['volume'],
      ));
    }
    return containers;
  }

  Future<void> signUserOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('id');

      await prefs.remove('id');
    } catch (e) {
      throw Exception("Error Logout");
    }
  }

  Future<String> _hashPassword(String password) async {
    // Use SHA-256 to hash the password
    final bytes = utf8.encode(password);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  Future<void> registerUser(User user) async {
    print("registering user");
    try {
      MySqlConnection connection = await Initializer.createConnection();

      // Check for existing username
      String usernameCheck =
          "SELECT COUNT(*) as count FROM users WHERE username = ?";
      var usernameResults = await connection.query(usernameCheck, [user.name]);
      if (usernameResults.first['count'] > 0) {
        throw Exception("Username already exists");
      }

      // Check for existing email
      String emailCheck = "SELECT COUNT(*) as count FROM users WHERE email = ?";
      var emailResults = await connection.query(emailCheck, [user.email]);
      if (emailResults.first['count'] > 0) {
        throw Exception("Email already exists");
      }

      // If no duplicates found, proceed with registration
      String hashedPassword = await _hashPassword(user.password);

      // MySQL query to insert a new user with hashed password
      String query = """
    INSERT INTO users (username, email, password)
    VALUES (?, ?, ?);
    """;

      final prefs = await SharedPreferences.getInstance();
      await connection.query(query, [user.name, user.email, hashedPassword]);

      // get the id of the user
      var results = await connection.query("SELECT LAST_INSERT_ID() as id;");
      final id = results.first['id'];
      print("saved id register : $id");

      await prefs.setInt('id', id).then((value) {
        print("value");
      });
    } catch (e) {
      print(e);
      // Throw more specific exceptions for better error handling
      if (e.toString().contains("Username already exists")) {
        throw Exception("Username already exists");
      } else if (e.toString().contains("Email already exists")) {
        throw Exception("Email already exists");
      }
      throw Exception("Error registering user");
    }
  }

  Future<User> loginUser(String email, String password) async {
    try {
      MySqlConnection connection = await Initializer.createConnection();

      // Hash the provided password for comparison
      String hashedPassword = await _hashPassword(password);

      // MySQL query to find a user by email and hashed password
      String query = """
    SELECT * FROM users WHERE email = ? AND password = ?;
    """;

      var results = await connection.query(query, [email, hashedPassword]);

      // Check if the user exists
      if (results.isNotEmpty) {
        // register user id on local
        final id = results.first['id'];
        final prefs = await SharedPreferences.getInstance();
// return te user model
        final user = User(
          id: id,
          name: results.first['username'].toString(),
          email: results.first['email'].toString(),
          password: results.first['password'].toString(),
        );
        await prefs.setInt('id', id);
        return user;
      } else {
        throw Exception("Invalid email or password");
      }
    } catch (e) {
      throw Exception("Error logging in");
    }
  }

  Future<User?> getUserById() async {
    print("getting user by id");
    MySqlConnection connection = await Initializer.createConnection();
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');

    if (id == null) {
      print("id is null");
      return null;
    }
    print("getted id : $id");
    // MySQL query to find a user by id
    String query = """
      SELECT * FROM users WHERE id = ?;
    """;
    var results = await connection.query(query, [id]);

    // Check if the user exists
    if (results.isNotEmpty) {
      var row = results.first;
      //  print("getted user email : ${row['email']}");
      return User(
        id: row['id'],
        name: row['username'].toString(),
        email: row['email'].toString(),
        password: row['password'].toString(),
      );
    } else {
      return null;
    }
  }

  Future<void> initializeFavoritesTable() async {
    try {
      MySqlConnection connection = await Initializer.createConnection();

      String createTableQuery = """
      CREATE TABLE IF NOT EXISTS favorites (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        container_id VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_favorite (user_id, container_id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      );
      """;

      await connection.query(createTableQuery);
    } catch (e) {
      print(e);
      throw Exception("Error initializing favorites table");
    }
  }

  Future<void> addToFavorites(String containerId) async {
    try {
      MySqlConnection connection = await Initializer.createConnection();

      // Get current user id
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');

      if (userId == null) {
        throw Exception("User not logged in");
      }

      // Ensure the table exists
      await initializeFavoritesTable();

      // Check if already in favorites
      String checkQuery =
          "SELECT COUNT(*) as count FROM favorites WHERE user_id = ? AND container_id = ?";
      var results = await connection.query(checkQuery, [userId, containerId]);

      if (results.first['count'] > 0) {
        throw Exception("Container already in favorites");
      }

      // Add to favorites
      String insertQuery = """
      INSERT INTO favorites (user_id, container_id)
      VALUES (?, ?);
      """;

      await connection.query(insertQuery, [userId, containerId]);
    } catch (e) {
      print(e);
      if (e.toString().contains("already in favorites")) {
        throw Exception("Container already in favorites");
      }
      throw Exception("Error adding container to favorites");
    }
  }

  Future<List<Trash>> getFavoriteContainers() async {
    try {
      MySqlConnection connection = await Initializer.createConnection();

      // Get current user id
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');

      if (userId == null) {
        throw Exception("User not logged in");
      }

      // Ensure the table exists
      await initializeFavoritesTable();

      // Get favorite containers with join to get container details
      String query = """
      SELECT c.* 
      FROM containers c
      INNER JOIN favorites f ON f.container_id = c.id
      WHERE f.user_id = ?
      ORDER BY f.created_at DESC;
      """;

      var results = await connection.query(query, [userId]);

      List<Trash> favoriteContainers = [];

      for (var row in results) {
        favoriteContainers.add(Trash(
          id: row['id'].toString(),
          longitude: row['longitude'],
          latitude: row['latitude'],
          volume: row['volume'],
        ));
      }

      return favoriteContainers;
    } catch (e) {
      print(e);
      throw Exception("Error retrieving favorite containers");
    }
  }

  Future<void> removeFromFavorites(String containerId) async {
    try {
      MySqlConnection connection = await Initializer.createConnection();

      // Get current user id
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');

      if (userId == null) {
        throw Exception("User not logged in");
      }

      String query = """
      DELETE FROM favorites 
      WHERE user_id = ? AND container_id = ?;
      """;

      var result = await connection.query(query, [userId, containerId]);

      if (result.affectedRows == 0) {
        throw Exception("Container not found in favorites");
      }
    } catch (e) {
      print(e);
      throw Exception("Error removing container from favorites");
    }
  }

  // Optional: Check if a container is in favorites
  Future<bool> isContainerInFavorites(String containerId) async {
    try {
      MySqlConnection connection = await Initializer.createConnection();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');

      if (userId == null) {
        return false;
      }

      String query =
          "SELECT COUNT(*) as count FROM favorites WHERE user_id = ? AND container_id = ?";
      var results = await connection.query(query, [userId, containerId]);

      return results.first['count'] > 0;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
