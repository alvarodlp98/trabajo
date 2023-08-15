import 'package:flutter/material.dart';
import '../model/encuesta_model.dart';
import '../database/database_helper.dart'; // Importa tu clase DatabaseHelper

class ResponderEncuestaScreen extends StatefulWidget {
  final Encuesta encuesta;

  ResponderEncuestaScreen({required this.encuesta});

  @override
  _ResponderEncuestaScreenState createState() => _ResponderEncuestaScreenState();
}

class _ResponderEncuestaScreenState extends State<ResponderEncuestaScreen> {
  List<String?> _respuestas = [];
  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _respuestas = List.generate(widget.encuesta.preguntas!.length, (_) => null);
  }

  void _guardarRespuestas() async {
    // Guardar las respuestas en la base de datos
    await _databaseHelper.guardarRespuestas(widget.encuesta.nombre!, _respuestas);

    // Mostrar un mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Respuestas guardadas')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Responder Encuesta')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.encuesta.preguntas?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.encuesta.preguntas?[index].texto ?? ""),
                    subtitle: Text('Respuesta: ${_respuestas[index] ?? ""}'),
                    trailing: TextField(
                      onChanged: (value) {
                        setState(() {
                          _respuestas[index] = value;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Respuesta'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _guardarRespuestas,
        child: Icon(Icons.save),
      ),
    );
  }
}
