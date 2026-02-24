import 'package:flutter/material.dart';

class HotReloadDemo extends StatefulWidget {
  const HotReloadDemo({super.key});

  @override
  State<HotReloadDemo> createState() => _HotReloadDemoState();
}

class _HotReloadDemoState extends State<HotReloadDemo> {
  int _counter = 0;
  Color _backgroundColor = Colors.blue;
  String _message = 'Hello, Flutter!';
  bool _showDebugInfo = false;

  @override
  Widget build(BuildContext context) {
    debugPrint('Building HotReloadDemo - Counter: $_counter, Message: $_message');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hot Reload Demo'),
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showDebugInfo ? Icons.bug_report : Icons.info),
            onPressed: () {
              setState(() {
                _showDebugInfo = !_showDebugInfo;
              });
              debugPrint('Debug info toggled: $_showDebugInfo');
            },
            tooltip: 'Toggle Debug Info',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_showDebugInfo) ...[
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Information:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Build Count: $_counter'),
                    Text('Background Color: ${_backgroundColor.toString()}'),
                    Text('Message: $_message'),
                    Text('Timestamp: ${DateTime.now()}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _message,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _backgroundColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Counter: $_counter',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _counter++;
                            debugPrint('Counter incremented to: $_counter');
                          });
                        },
                        child: const Text('Increment'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _counter = 0;
                            debugPrint('Counter reset to: $_counter');
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('Blue'),
                  selected: _backgroundColor == Colors.blue,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _backgroundColor = Colors.blue;
                        debugPrint('Background color changed to blue');
                      });
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Green'),
                  selected: _backgroundColor == Colors.green,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _backgroundColor = Colors.green;
                        debugPrint('Background color changed to green');
                      });
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Purple'),
                  selected: _backgroundColor == Colors.purple,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _backgroundColor = Colors.purple;
                        debugPrint('Background color changed to purple');
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final messages = [
                  'Hello, Flutter!',
                  'Welcome to Hot Reload!',
                  'Flutter is Awesome!',
                  'Hot Reload Working!',
                  'Debug Mode Active!',
                ];
                
                setState(() {
                  _message = messages[(_counter % messages.length)];
                  debugPrint('Message changed to: $_message');
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Change Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _counter++;
            debugPrint('FAB pressed - Counter: $_counter');
          });
        },
        backgroundColor: _backgroundColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
