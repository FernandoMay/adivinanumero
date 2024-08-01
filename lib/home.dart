import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _difficulty = 'Fácil';
  int _maxNumber = 10;
  int _attempts = 5;
  late int _secretNumber;
  late int _remainingAttempts;
  String _message = '';
  final List<String> _history = [];
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  bool _isButtonPressed = false;

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
        _message =
            'Por favor, introduce un número válido entre 1 y $_maxNumber';
        _isButtonPressed = true;
        Vibration.vibrate(duration: 500);
        return;
      }

      _remainingAttempts--;

      if (guess == _secretNumber) {
        _message = '¡Correcto! El número era $_secretNumber';
        _history.add('$_secretNumber - Correcto');
        _listKey.currentState?.insertItem(_history.length - 1);
        _resetGame();
      } else if (_remainingAttempts == 0) {
        _message = 'Lo siento, has perdido. El número era $_secretNumber';
        _history.add('$_secretNumber - Incorrecto');
        _listKey.currentState?.insertItem(_history.length - 1);
        _resetGame();
      } else if (guess > _secretNumber) {
        _message = 'Intenta con un número menor';
        _history.add('$guess - Mayor que el número secreto');
        _listKey.currentState?.insertItem(_history.length - 1);
      } else {
        _message = 'Intenta con un número mayor';
        _history.add('$guess - Menor que el número secreto');
        _listKey.currentState?.insertItem(_history.length - 1);
      }
      _controller.clear();
      _isButtonPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guess the Number'),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isButtonPressed ? 200.0 : 100.0,
              height: 50.0,
              color: _isButtonPressed ? Colors.blue : Colors.red,
              alignment: _isButtonPressed
                  ? Alignment.center
                  : AlignmentDirectional.topCenter,
              child: ElevatedButton(
                onPressed: _checkGuess,
                child: const Text('Adivina'),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                _message,
                key: ValueKey<String>(_message),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: _history.length,
                itemBuilder: (context, index, animation) {
                  return _buildItem(_history[index], animation);
                },
              ),
            ),
          ],
        ),
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
