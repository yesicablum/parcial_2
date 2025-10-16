import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parcial - Aplicaciones Móviles',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

  // Print to console (required)
  debugPrint('Registro: correo=$email, password=$password');

    // Optional: show SnackBar indicating registration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario Registrado')),
    );

    // Simple validation: require non-empty values
    if (email.isEmpty || password.isEmpty) return;

    // Navigate to HomePage and pass email as argument
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => HomePage(email: email)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String email;
  const HomePage({super.key, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int likes = 0;
  String joke = '';
  bool loadingJoke = false;

  @override
  void initState() {
    super.initState();
    _fetchJoke();
  }

  Future<void> _fetchJoke() async {
    setState(() {
      loadingJoke = true;
    });
    try {
      final uri = Uri.parse('https://api.chucknorris.io/jokes/random');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        setState(() {
          joke = data['value'] as String? ?? 'No hay chiste';
        });
      } else {
        setState(() {
          joke = 'Error al obtener chiste: ${res.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        joke = 'Error: $e';
      });
    } finally {
      setState(() {
        loadingJoke = false;
      });
    }
  }

  void _incrementLikes() {
    // We use setState to notify the framework that the UI should be rebuilt
    // because the value of 'likes' changed. Without calling setState, the
    // displayed number would not update even though the variable changed.
    // This is necessary because Flutter's rendering is declarative: UI is
    // rebuilt from state in build().
    setState(() {
      likes++;
    });
  }

  Future<void> _savePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tema', 'dark_mode');
    // Confirmación: ensure widget is still mounted before using context
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferencia guardada: tema=dark_mode')),
    );
    debugPrint('Preferencia guardada: tema=dark_mode');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${widget.email}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¡Bienvenido, ${widget.email}!', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              Text('Cantidad de Likes: $likes', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar Sesión'),
              ),
              const SizedBox(height: 24),
              const Text('Chiste del día:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              loadingJoke
                  ? const Text('Cargando chiste...')
                  : Text(joke.isNotEmpty ? joke : 'No se cargó chiste'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePreference,
                child: const Text('Guardar Preferencia'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementLikes,
        child: const Icon(Icons.favorite),
      ),
    );
  }
}
