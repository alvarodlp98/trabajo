import 'package:postgres/postgres.dart';
import '../model/encuesta_model.dart';

class DatabaseHelper {
  final PostgreSQLConnection _connection;

  DatabaseHelper({
    String host = '	silly.db.elephantsql.com (silly-01)',
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
    await _connection.open();
  }

  Future<void> closeConnection() async {
    await _connection.close();
  }

  Future<void> guardarEncuesta(String nombreEncuesta,
      List<Pregunta> preguntas) async {
     openConnection();

    // Insertar la encuesta en la tabla 'encuestas'
    await _connection.query(
      'INSERT INTO encuestas (nombre) VALUES (@nombre)',
      substitutionValues: {'nombre': nombreEncuesta},
    );

    // Obtener el ID de la encuesta recién insertada
    final encuestaIdResult = await _connection.query(
      'SELECT id FROM encuestas WHERE nombre = @nombre',
      substitutionValues: {'nombre': nombreEncuesta},
    );

    if (encuestaIdResult.isNotEmpty) {
      final encuestaId = encuestaIdResult[0][0] as int;

      // Insertar las preguntas asociadas a la encuesta en la tabla 'preguntas'
      for (int i = 0; i < preguntas.length; i++) {
        await _connection.query(
          'INSERT INTO preguntas (encuesta_id, texto, obligatoria) VALUES (@encuestaId, @texto, @obligatoria)',
          substitutionValues: {
            'encuestaId': encuestaId,
            'texto': preguntas[i].texto,
            'obligatoria': preguntas[i].obligatoria != null &&
                preguntas[i].obligatoria! ? 1 : 0,
          },
        );
      }
    }

    await closeConnection();
  }

  Future<void> guardarRespuestas(String nombreEncuesta,
      List<String?> respuestas) async {
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

    await closeConnection();
  }

  Future<List<Encuesta>> obtenerEncuestas() async {
    await openConnection();
    final result = await _connection.query('SELECT nombre FROM encuestas');
    await closeConnection();

    final encuestas = result.map((row) => Encuesta(nombre: row[0] as String))
        .toList();
    return encuestas;
  }

  void createDatabaseTables(PostgreSQLConnection connection) async {
    await connection.query(
      '''
    CREATE TABLE IF NOT EXISTS encuestas (
      id SERIAL PRIMARY KEY,
      nombre TEXT
    )
    ''',
    );


    await connection.query(
      '''
    CREATE TABLE IF NOT EXISTS preguntas (
      id SERIAL PRIMARY KEY,
      encuesta_id INT,
      texto TEXT,
      obligatoria BOOLEAN,
      FOREIGN KEY (encuesta_id) REFERENCES encuestas (id)
    )
    ''',
    );


    await connection.query(
      '''
    CREATE TABLE IF NOT EXISTS respuestas (
      id SERIAL PRIMARY KEY,
      encuesta_id INT,
      pregunta_index INT,
      respuesta TEXT,
      FOREIGN KEY (encuesta_id) REFERENCES encuestas (id),
      FOREIGN KEY (pregunta_index, encuesta_id) REFERENCES preguntas (id, encuesta_id)
    )
    ''',
    );
  }
}
