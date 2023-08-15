import 'package:flutter/material.dart';
import '../model/encuesta_model.dart';
import '../database/database_helper.dart';


class GenerarEncuestaScreen extends StatefulWidget {
  static const ruta = "generar";
  @override
  _GenerarEncuestaScreenState createState() => _GenerarEncuestaScreenState();
}

class _GenerarEncuestaScreenState extends State<GenerarEncuestaScreen> {

  TextEditingController _nombreEncuestaController = TextEditingController();
  List<Pregunta> _preguntas = [];

  DatabaseHelper _databaseHelper = DatabaseHelper();

  void _agregarPregunta() {
    setState(() {
      _preguntas.add(Pregunta(texto: '', obligatoria: false));
    });
  }

  void _guardarEncuesta() async {
    String nombreEncuesta = _nombreEncuestaController.text;

    await _databaseHelper.guardarEncuesta(nombreEncuesta, _preguntas);

    _nombreEncuestaController.clear();
    _preguntas.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Encuesta guardada')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generar Encuesta')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nombreEncuestaController,
              decoration: InputDecoration(labelText: 'Nombre de la encuesta'),
            ),
            ElevatedButton(
              onPressed: _agregarPregunta,
              child: Text('Agregar pregunta'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _preguntas.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: TextField(
                      onChanged: (value) => _preguntas[index].texto = value,
                      decoration: InputDecoration(labelText: 'Pregunta ${index + 1}'),
                    ),
                    trailing: Checkbox(
                      value: _preguntas[index].obligatoria,
                      onChanged: (value) => setState(() => _preguntas[index].obligatoria = value),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _guardarEncuesta,
              child: Text('Guardar encuesta'),
            ),
          ],
        ),
      ),
    );
  }
}
