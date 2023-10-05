import 'package:postgres/postgres.dart';
import '../model/encuesta_model.dart';

class DatabaseHelper {
  final PostgreSQLConnection _connection;

  DatabaseHelper({
    String host = 'silly.db.elephantsql.com (silly-01)',
    int port = 5432,
    String databaseName = 'rmzdvhza',
    String username = 'rmzdvhza',
    String password = 'Ncf1ECn1sgBPrg1Nx6eTbgcP8nQwEg5m',
  }) : _connection = PostgreSQLConnection(
    host,
    port,
    databaseName,
    username: username,
    password: password,
  );

  Future<void> openConnection() async {
    try {
      if (!_connection.isClosed) {
        print('La conexión ya está abierta.');
        return;
      }
      await _connection.open();
      print('Conexión abierta correctamente.');
    } catch (e) {
      print('Error al abrir la conexión: $e');
    }
  }

  Future<void> closeConnection() async {
    try {
      await _connection.close();
      print('Conexión cerrada correctamente.');
    } catch (e) {
      print('Error al cerrar la conexión: $e');
    }
  }

  Future<void> guardarEncuesta(String nombreEncuesta, List<Pregunta> preguntas) async {
    try {
      await openConnection();

      // Insertar la encuesta en la tabla 'encuestas'
      final encuestaIdResult = await _connection.query(
        'INSERT INTO encuestas (nombre) VALUES (@nombre) RETURNING id;',
        substitutionValues: {'nombre': nombreEncuesta},
      );

      if (encuestaIdResult.isNotEmpty) {
        final encuestaId = encuestaIdResult[0][0] as int;

        // Insertar las preguntas asociadas a la encuesta en la tabla 'preguntas'
        for (int i = 0; i < preguntas.length; i++) {
          await _connection.execute(
            'INSERT INTO preguntas (encuesta_id, texto, obligatoria) VALUES (@encuestaId, @texto, @obligatoria)',
            substitutionValues: {
              'encuestaId': encuestaId,
              'texto': preguntas[i].texto,
              'obligatoria': preguntas[i].obligatoria != null && preguntas[i].obligatoria! ? 1 : 0,
            },
          );
        }
      }
    } catch (e) {
      print('Error al guardar la encuesta: $e');
    } finally {
      await closeConnection();
    }
  }



  Future<void> guardarRespuestas(String nombreEncuesta, List<String?> respuestas) async {
    try {
      await openConnection();

      final encuestaIdResult = await _connection.query(
        'SELECT id FROM encuestas WHERE nombre = @nombre',
        substitutionValues: {'nombre': nombreEncuesta},
      );

      if (encuestaIdResult.isNotEmpty) {
        final encuestaId = encuestaIdResult[0][0] as int;

        for (int i = 0; i < respuestas.length; i++) {
          await _connection.query(
            'INSERT INTO respuestas (encuesta_id, pregunta_index, respuesta) VALUES (@encuestaId, @preguntaIndex, @respuesta)',
            substitutionValues: {
              'encuestaId': encuestaId,
              'preguntaIndex': i,
              'respuesta': respuestas[i]
            },
          );
        }
      }
    } catch (e) {
      print('Error al guardar las respuestas: $e');
    } finally {
      await closeConnection();
    }
  }

  Future<List<Encuesta>> obtenerEncuestas() async {
    try {
      await openConnection();
      final result = await _connection.query('SELECT nombre FROM encuestas');
      return result.map((row) => Encuesta(nombre: row[0] as String)).toList();
    } catch (e) {
      print('Error al obtener las encuestas: $e');
      return [];
    } finally {
      await closeConnection();
    }
  }

  void createDatabaseTables(PostgreSQLConnection connection) async {
    try {
      await connection.query('''
        CREATE TABLE IF NOT EXISTS encuestas (
          id SERIAL PRIMARY KEY,
          nombre TEXT
        )
      ''');

      await connection.query('''
        CREATE TABLE IF NOT EXISTS preguntas (
          id SERIAL PRIMARY KEY,
          encuesta_id INT,
          texto TEXT,
          obligatoria BOOLEAN,
          FOREIGN KEY (encuesta_id) REFERENCES encuestas (id)
        )
      ''');

      await connection.query('''
        CREATE TABLE IF NOT EXISTS respuestas (
          id SERIAL PRIMARY KEY,
          encuesta_id INT,
          pregunta_index INT,
          respuesta TEXT,
          FOREIGN KEY (encuesta_id) REFERENCES encuestas (id),
          FOREIGN KEY (pregunta_index, encuesta_id) REFERENCES preguntas (id, encuesta_id)
        )
      ''');
      print('Tablas creadas correctamente.');
    } catch (e) {
      print('Error al crear las tablas: $e');
    } finally {
      await closeConnection();
    }
  }
}
