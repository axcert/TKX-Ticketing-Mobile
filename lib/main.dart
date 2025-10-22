import 'package:flutter/material.dart';
import 'screens/loading/splash_screen.dart';
import 'screens/login/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TKX Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const SplashToLoginWrapper(),
    );
  }
}

class SplashToLoginWrapper extends StatefulWidget {
  const SplashToLoginWrapper({super.key});

  @override
  State<SplashToLoginWrapper> createState() => _SplashToLoginWrapperState();
}

class _SplashToLoginWrapperState extends State<SplashToLoginWrapper> {
  bool _showLogin = false;

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return const LoginScreen();
    }

    return SplashScreen(
      duration: const Duration(seconds: 2),
      onFinished: () {
        setState(() {
          _showLogin = true;
        });
      },
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
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
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
