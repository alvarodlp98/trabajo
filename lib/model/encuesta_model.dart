// encuesta_model.dart

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
