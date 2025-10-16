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
        // Paleta suave y femenina
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE091E5)),
        scaffoldBackgroundColor: const Color(0xFFFFFBFE),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0x00FFFFFF),
          foregroundColor: Color(0xFF6B2A67),
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Color(0xFF6B2A67)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF6B2A67)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE091E5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          hintStyle: const TextStyle(color: Color(0xFF9E6E9E)),
        ),
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
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCEFF6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0,4)),
                    ],
                  ),
                  child: const Icon(Icons.person, size: 72, color: Color(0xFFE091E5)),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(hintText: 'Correo electrónico'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(hintText: 'Contraseña'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Registrar', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text('¡Bienvenido, ${widget.email}!', style: Theme.of(context).textTheme.headlineSmall),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.favorite, color: Color(0xFFE091E5), size: 28),
                          const SizedBox(height: 8),
                          Text('Cantidad de Likes', style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                      Text('$likes', style: const TextStyle(fontSize: 28, color: Color(0xFFE091E5))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.sentiment_very_satisfied, color: Color(0xFFE091E5)),
                          SizedBox(width: 8),
                          Text('Chiste del día:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      loadingJoke
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE091E5)))
                          : Text(joke.isNotEmpty ? joke : 'No se cargó chiste'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _savePreference,
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar Preferencia'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar Sesión'),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE091E5))),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementLikes,
        backgroundColor: const Color(0xFFE091E5),
        child: const Icon(Icons.favorite, color: Colors.white),
      ),
    );
  }
}
