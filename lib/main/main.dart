import 'package:flutter/material.dart';
import '../model/encuesta_model.dart'; // Importa la clase Encuesta y Pregunta
import '../screen/GenerarEncuestaScreen.dart';
import '../screen/ResponderEncuestaScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Crear una instancia de Encuesta
    Encuesta miEncuesta = Encuesta(
      nombre: 'Encuesta de ejemplo',
      preguntas: [
        Pregunta(texto: '¿Cuál es tu color favorito?', obligatoria: true),
        Pregunta(texto: '¿Qué idiomas hablas?', obligatoria: false),
        // Agrega más preguntas aquí
      ],
    );

    return  MaterialApp(
      title: 'Mi Encuesta App',
      initialRoute: GenerarEncuestaScreen.ruta,
      routes: {
    GenerarEncuestaScreen.ruta:(context) => GenerarEncuestaScreen(),
        '/responder': (context) => ResponderEncuestaScreen(encuesta: miEncuesta),
      },
    );
  }
}
