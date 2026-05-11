import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pbfbmazzyyclzavvbtkb.supabase.co',
    anonKey: 'TU_ANON_KEY_AQUI',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym App',
      home: LoginPage(),
    );
  }
}

// 🔵 LOGIN
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("⚠️ Campos vacíos")),
                  );
                  return;
                }

                try {
                  final response = await Supabase.instance.client.auth
                      .signInWithPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  if (response.user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ Error: $e")),
                  );
                }
              },
              child: const Text("Iniciar sesión"),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterPage()),
                );
              },
              child: const Text("Crear cuenta"),
            ),
          ],
        ),
      ),
    );
  }
}

// 🟣 REGISTRO
class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                try {
                  final response =
                      await Supabase.instance.client.auth.signUp(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  if (response.user != null) {
                    final user = response.user!;

                    await Supabase.instance.client.from('users').insert({
                      'id': user.id,
                      'email': emailController.text.trim(),
                      'rol': 'cliente',
                    });

                    Navigator.pop(context);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ Error: $e")),
                  );
                }
              },
              child: const Text("Registrarse"),
            ),
          ],
        ),
      ),
    );
  }
}

// 🟢 HOME
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),

      body: FutureBuilder(
        future: Supabase.instance.client
            .from('users')
            .select()
            .eq('id', user?.id ?? '')
            .maybeSingle(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No se encontró usuario"));
          }

          final data = snapshot.data as Map;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Bienvenido a Gym App"),
                Text("Rol: ${data['rol']}"),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ClasesPage()),
                    );
                  },
                  child: const Text("Ver Clases"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// 🔵 LISTA DE CLASES
class ClasesPage extends StatefulWidget {
  @override
  _ClasesPageState createState() => _ClasesPageState();
}

class _ClasesPageState extends State<ClasesPage> {
  List clases = [];

  @override
  void initState() {
    super.initState();
    obtenerClases();
  }

  Future<void> obtenerClases() async {
    final response =
        await Supabase.instance.client.from('clases').select();

    setState(() {
      clases = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clases")),

      body: ListView.builder(
        itemCount: clases.length,
        itemBuilder: (context, index) {
          final clase = clases[index];

          return ListTile(
            title: Text(clase['nombre'] ?? ''),
            subtitle: Text(clase['descripcion'] ?? ''),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CrearClasePage()),
          ).then((_) => obtenerClases());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 🟠 CREAR CLASE
class CrearClasePage extends StatelessWidget {
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final cupoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Clase")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            TextField(
              controller: cupoController,
              decoration: const InputDecoration(labelText: "Cupo"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.from('clases').insert({
                  'nombre': nombreController.text,
                  'descripcion': descripcionController.text,
                  'fecha': DateTime.now().toString(),
                  'cupo': int.parse(cupoController.text)
                });

                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            )
          ],
        ),
      ),
    );
  }
}