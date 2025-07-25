import 'dart:io';  // For Socket
import 'dart:convert';  // For UTF-8 encoding/decoding
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Running Total Counter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isLoading = false;

  // Send increment to server via raw socket and get running total
  Future<void> _incrementCounter() async {
    setState(() {
      _isLoading = true;
    });

    Socket? socket;
    try {
      // Connect to the socket server
      socket = await Socket.connect('192.168.1.126', 5072);
      
      // Send data in the expected format
      socket.write('number:1\n');  // Add newline for proper termination
      
      // Listen for response
      final response = await socket.first.timeout(const Duration(seconds: 5));
      final responseString = utf8.decode(response).trim();
      
      if (responseString.startsWith('total:')) {
        final newTotal = int.parse(responseString.split(':')[1]);
        setState(() {
          _counter = newTotal;
        });
      } else {
        print('Error from server: $responseString');
      }
    } catch (e) {
      print('Socket error: $e');
      // Optionally show a snackbar or dialog for user feedback
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      socket?.destroy();  // Close the socket
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Reset local counter
  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  Future<void> _checkTotal() async {
    setState(() {
      _isLoading = true;
    });

    Socket? socket;
    try {
      // Connect to the socket server
      socket = await Socket.connect('192.168.1.126', 5072);
      
      // Send data in the expected format
      socket.write('request:1\n');  // Add newline for proper termination
      
      // Listen for response
      final response = await socket.first.timeout(const Duration(seconds: 5));
      final responseString = utf8.decode(response).trim();
      
      if (responseString.startsWith('total:')) {
        final newTotal = int.parse(responseString.split(':')[1]);
        setState(() {
          _counter = newTotal;
        });
      } else {
        print('Error from server: $responseString');
      }
    } catch (e) {
      print('Socket error: $e');
      // Optionally show a snackbar or dialog for user feedback
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      socket?.destroy();  // Close the socket
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Server Running Total:'),
            _isLoading
                ? const CircularProgressIndicator()
                : Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _isLoading ? null : _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _resetCounter,
            tooltip: 'Reset Local',
            backgroundColor: Colors.red,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _checkTotal,
            tooltip: 'Check Running Total',
            backgroundColor: Colors.pink,
            child: const Icon(Icons.rowing),
          ),
        ],
      ),
    );
  }
}