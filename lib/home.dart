import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _difficulty = 'Fácil';
  double _difficultyValue = 0;
  int _maxNumber = 10;
  int _attempts = 5;
  late int _secretNumber;
  late int _remainingAttempts;
  int _correctGuesses = 0;
  String _message = '';
  final List<String> _history = [];
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

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
    return Random().nextInt(_maxNumber) + 1;
  }

  void _updateDifficulty(double value) {
    setState(() {
      _difficultyValue = value;
      if (value == 0) {
        _difficulty = 'Fácil';
        _maxNumber = 10;
        _attempts = 5;
      } else if (value == 1) {
        _difficulty = 'Medio';
        _maxNumber = 20;
        _attempts = 8;
      } else if (value == 2) {
        _difficulty = 'Avanzado';
        _maxNumber = 100;
        _attempts = 15;
      } else if (value == 3) {
        _difficulty = 'Extremo';
        _maxNumber = 1000;
        _attempts = 25;
      }
      _resetGame();
    });
  }

  void _checkGuess() {
    setState(() {
      int? guess = int.tryParse(_controller.text);
      if (guess == null || guess < 1 || guess > _maxNumber) {
        _message =
            'Por favor, introduce un número válido entre 1 y $_maxNumber';
        Vibration.vibrate(duration: 500);
        return;
      }

      _remainingAttempts--;

      if (guess == _secretNumber) {
        _message = '¡Correcto! El número era $_secretNumber';
        _history.insert(0, '$_secretNumber - Correcto');
        _listKey.currentState?.insertItem(0);
        _correctGuesses++;
        _showSnackBar('¡Felicidades! Adivinaste el número.');
        _resetGame();
      } else if (_remainingAttempts == 0) {
        _message = 'Lo siento, has perdido. El número era $_secretNumber';
        _history.insert(0, '$_secretNumber - Incorrecto');
        _listKey.currentState?.insertItem(0);
        _resetGame();
      } else if (guess > _secretNumber) {
        _message = 'Intenta con un número menor';
        _history.insert(0, '$guess - Mayor que el número secreto');
        _listKey.currentState?.insertItem(0);
      } else {
        _message = 'Intenta con un número mayor';
        _history.insert(0, '$guess - Menor que el número secreto');
        _listKey.currentState?.insertItem(0);
      }
      _controller.clear();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adivina el Número'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Correctos: $_correctGuesses',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Intentos: $_remainingAttempts',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text('Dificultad'),
            Slider(
              value: _difficultyValue,
              min: 0,
              max: 3,
              divisions: 3,
              label: _difficulty,
              onChanged: (double value) {
                _updateDifficulty(value);
              },
            ),
            Text('Adivina el número entre 1 y $_maxNumber'),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tu conjetura',
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Row(
                  key: ValueKey<String>(_message),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _message,
                      style: const TextStyle(fontSize: 20),
                    ),
                    if (_message.contains('menor'))
                      const Icon(Icons.arrow_downward, color: Color(0xFF45BEB7)),
                    if (_message.contains('mayor'))
                      const Icon(Icons.arrow_upward, color: Color(0xFF085F63)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                reverse: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _history[index],
                      style: TextStyle(
                        color: _history[index].contains('Correcto')
                            ? const Color(0xFF53D397)
                            : const Color(0xFF8F8787),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkGuess,
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget _buildItem(String item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        title: Text(
          item,
          style: TextStyle(
            color: item.contains('Correcto') ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
