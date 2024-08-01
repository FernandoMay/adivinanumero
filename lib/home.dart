import 'dart:math';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _difficulty = 'Fácil';
  int _maxNumber = 10;
  int _attempts = 5;
  late int _secretNumber;
  late int _remainingAttempts;
  String _message = '';
  final List<String> _history = [];

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _secretNumber = _generateSecretNumber();
      _remainingAttempts = _attempts;
      _message = '';
      _history.clear();
      _controller.clear();
    });
  }

  int _generateSecretNumber() {
    return (1 + (Random().nextInt(_maxNumber)));
  }

  void _updateDifficulty(String newDifficulty) {
    setState(() {
      _difficulty = newDifficulty;
      switch (_difficulty) {
        case 'Fácil':
          _maxNumber = 10;
          _attempts = 5;
          break;
        case 'Medio':
          _maxNumber = 20;
          _attempts = 8;
          break;
        case 'Avanzado':
          _maxNumber = 100;
          _attempts = 15;
          break;
        case 'Extremo':
          _maxNumber = 1000;
          _attempts = 25;
          break;
      }
      _resetGame();
    });
  }

  void _checkGuess() {
    setState(() {
      int? guess = int.tryParse(_controller.text);
      if (guess == null || guess < 1 || guess > _maxNumber) {
        _message = 'Por favor, introduce un número válido entre 1 y $_maxNumber';
        return;
      }

      _remainingAttempts--;

      if (guess == _secretNumber) {
        _message = '¡Correcto! El número era $_secretNumber';
        _history.add('$_secretNumber - Correcto');
        _resetGame();
      } else if (_remainingAttempts == 0) {
        _message = 'Lo siento, has perdido. El número era $_secretNumber';
        _history.add('$_secretNumber - Incorrecto');
        _resetGame();
      } else if (guess > _secretNumber) {
        _message = 'Intenta con un número menor';
        _history.add('$guess - Mayor que el número secreto');
      } else {
        _message = 'Intenta con un número mayor';
        _history.add('$guess - Menor que el número secreto');
      }
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adivina el Número'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              value: _difficulty,
              onChanged: (String? newValue) {
                _updateDifficulty(newValue!);
              },
              items: <String>['Fácil', 'Medio', 'Avanzado', 'Extremo']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Text('Adivina el número entre 1 y $_maxNumber'),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tu conjetura',
              ),
            ),
            ElevatedButton(
              onPressed: _checkGuess,
              child: const Text('Adivina'),
            ),
            Text(_message),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_history[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
