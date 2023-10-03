class Respuesta {
  int? id;
  int preguntaId;
  String? respuesta;

  Respuesta({this.id, required this.preguntaId, this.respuesta});
}

class Encuesta {
  int? id;
  String? nombre;
  List<Pregunta>? preguntas;

  Encuesta({this.id, this.nombre, this.preguntas});
}

class Pregunta {
  int? id;
  String? texto;
  bool? obligatoria;

  Pregunta({this.id, this.texto, this.obligatoria});
}
