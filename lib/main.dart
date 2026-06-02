import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pbfbmazzyyclzavvbtkb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBiZmJtYXp6eXljbHphdnZidGtiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyMDYxNTgsImV4cCI6MjA5Mjc4MjE1OH0.1xZ34_rq_d4vYFBBlHPaXAdBrQaxmwjWmEnPYtpHnxM',
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00FF88),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0A),
          foregroundColor: Color(0xFF00FF88),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF88),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFF00FF88)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00FF88)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00FF88), width: 2),
          ),
        ),
      ),
      home: LoginPage(),
    );
  }
}

// ================= LOGIN =================

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Push Your\nLimits",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00FF88),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Sign in to access your workouts",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: Icon(Icons.email, color: Color(0xFF00FF88)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF00FF88)),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (emailController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Campos vacios")),
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
                        final user = response.user!;
                        final perfil = await Supabase.instance.client
                            .from('users')
                            .select()
                            .eq('id', user.id)
                            .maybeSingle();

                        final rol = perfil?['rol'] ?? 'cliente';

                        if (rol == 'admin') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminDashboardPage(),
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomePage(),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterPage()),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Color(0xFF00FF88)),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RecuperarPasswordPage()),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= REGISTRO =================

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Join Us",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00FF88),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Email Address",
                prefixIcon: Icon(Icons.email, color: Color(0xFF00FF88)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock, color: Color(0xFF00FF88)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
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

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cuenta creada exitosamente")),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                child: const Text(
                  "SIGN UP",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= RECUPERAR CONTRASEÑA =================

class RecuperarPasswordPage extends StatelessWidget {
  RecuperarPasswordPage({super.key});

  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar Contrasena")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reset Password",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00FF88),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Ingresa tu correo y te enviaremos un enlace para restablecer tu contrasena.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Email Address",
                prefixIcon: Icon(Icons.email, color: Color(0xFF00FF88)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ingresa tu email")),
                    );
                    return;
                  }
                  try {
                    await Supabase.instance.client.auth.resetPasswordForEmail(
                      emailController.text.trim(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Correo enviado, revisa tu bandeja"),
                      ),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                child: const Text(
                  "ENVIAR CORREO",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= HOME CLIENTE =================

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
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
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
            return const Center(child: Text("No se encontro usuario"));
          }
          final data = snapshot.data as Map;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF00FF88),
                        child: Icon(Icons.person, color: Colors.black, size: 30),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, ${user?.email?.split('@')[0]}!",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Rol: ${data['rol']}",
                            style: const TextStyle(color: Color(0xFF00FF88)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.fitness_center,
                        label: "Ver Clases",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ClasesPage()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.bookmark,
                        label: "Mis Clases",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MisClasesPage()),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF00FF88), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00FF88), size: 30),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ================= ADMIN DASHBOARD =================

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF00FF88),
                    child: Icon(Icons.admin_panel_settings, color: Colors.black, size: 30),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Panel de Admin",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Gestiona tu gimnasio",
                        style: TextStyle(color: Color(0xFF00FF88)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.add_circle,
                    label: "Crear Clase",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CrearClasePage()),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.list,
                    label: "Ver Clases",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ClasesPage()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.people,
                    label: "Estudiantes",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EstudiantesPage()),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.calendar_month,
                    label: "Calendario",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CalendarioPage()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================= LISTA CLASES =================

class ClasesPage extends StatefulWidget {
  @override
  State<ClasesPage> createState() => _ClasesPageState();
}

class _ClasesPageState extends State<ClasesPage> {
  List clases = [];

  @override
  void initState() {
    super.initState();
    obtenerClases();
  }

  Future<void> obtenerClases() async {
    final response = await Supabase.instance.client
        .from('clases')
        .select()
        .order('fecha', ascending: true);
    setState(() {
      clases = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Classes")),
      body: clases.isEmpty
          ? const Center(child: Text("No hay clases disponibles", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: clases.length,
              itemBuilder: (context, index) {
                final clase = clases[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF88).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.fitness_center, color: Color(0xFF00FF88)),
                    ),
                    title: Text(
                      clase['nombre'] ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(clase['descripcion'] ?? '', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.people, color: Color(0xFF00FF88), size: 14),
                            const SizedBox(width: 4),
                            Text("Cupo: ${clase['cupo']}", style: const TextStyle(color: Color(0xFF00FF88), fontSize: 12)),
                            if (clase['intensidad'] != null) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: clase['intensidad'] == 'alta'
                                      ? Colors.red.withOpacity(0.3)
                                      : clase['intensidad'] == 'media'
                                          ? Colors.orange.withOpacity(0.3)
                                          : Colors.green.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  clase['intensidad'].toString().toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: clase['intensidad'] == 'alta'
                                        ? Colors.red
                                        : clase['intensidad'] == 'media'
                                            ? Colors.orange
                                            : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final user = Supabase.instance.client.auth.currentUser;
                        final existe = await Supabase.instance.client
                            .from('inscripciones')
                            .select()
                            .eq('user_id', user?.id ?? '')
                            .eq('clase_id', clase['id']);

                        if (existe.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Ya estas inscrito")),
                          );
                          return;
                        }
                        final inscritos = await Supabase.instance.client
                            .from('inscripciones')
                            .select()
                            .eq('clase_id', clase['id']);

                        if (inscritos.length >= clase['cupo']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Clase llena")),
                          );
                          return;
                        }
                        await Supabase.instance.client.from('inscripciones').insert({
                          'user_id': user?.id,
                          'clase_id': clase['id'],
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Inscripcion exitosa")),
                        );
                      },
                      child: const Text("Book"),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00FF88),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CrearClasePage()),
          ).then((_) => obtenerClases());
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

// ================= CREAR CLASE =================

class CrearClasePage extends StatefulWidget {
  const CrearClasePage({super.key});

  @override
  State<CrearClasePage> createState() => _CrearClasePageState();
}

class _CrearClasePageState extends State<CrearClasePage> {
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final cupoController = TextEditingController();
  String intensidadSeleccionada = 'media';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Class"),
        actions: [
          TextButton(
            onPressed: () async {
              if (nombreController.text.isEmpty || cupoController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Completa los campos")),
                );
                return;
              }
              await Supabase.instance.client.from('clases').insert({
                'nombre': nombreController.text,
                'descripcion': descripcionController.text,
                'fecha': DateTime.now().toIso8601String(),
                'cupo': int.parse(cupoController.text),
                'intensidad': intensidadSeleccionada,
              });
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Color(0xFF00FF88), fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF00FF88)),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, color: Color(0xFF00FF88), size: 40),
                    SizedBox(height: 8),
                    Text("Add Class Photo", style: TextStyle(color: Color(0xFF00FF88))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text("BASIC INFORMATION",
                style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: nombreController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Class Title",
                      hintText: "e.g. Morning Yoga Flow",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: descripcionController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: cupoController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Capacity",
                      prefixIcon: Icon(Icons.people, color: Color(0xFF00FF88)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text("INTENSIDAD",
                style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: ['baja', 'media', 'alta'].map((nivel) {
                  final isSelected = intensidadSeleccionada == nivel;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => intensidadSeleccionada = nivel),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00FF88) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF00FF88) : Colors.grey,
                          ),
                        ),
                        child: Text(
                          nivel.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= MIS CLASES =================

class MisClasesPage extends StatefulWidget {
  @override
  State<MisClasesPage> createState() => _MisClasesPageState();
}

class _MisClasesPageState extends State<MisClasesPage> {
  List clases = [];

  @override
  void initState() {
    super.initState();
    cargarClases();
  }

  Future<void> cargarClases() async {
    final user = Supabase.instance.client.auth.currentUser;
    final response = await Supabase.instance.client
        .from('inscripciones')
        .select('clases(*)')
        .eq('user_id', user?.id ?? '');
    setState(() {
      clases = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Reservations")),
      body: clases.isEmpty
          ? const Center(child: Text("No tienes clases inscritas", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: clases.length,
              itemBuilder: (context, index) {
                final clase = clases[index]['clases'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF88).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.fitness_center, color: Color(0xFF00FF88)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(clase['nombre'] ?? '',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text(clase['descripcion'] ?? '',
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: Color(0xFF00FF88)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ================= ESTUDIANTES =================

class EstudiantesPage extends StatefulWidget {
  @override
  State<EstudiantesPage> createState() => _EstudiantesPageState();
}

class _EstudiantesPageState extends State<EstudiantesPage> {
  List estudiantes = [];

  @override
  void initState() {
    super.initState();
    cargarEstudiantes();
  }

  Future<void> cargarEstudiantes() async {
    final response = await Supabase.instance.client.from('users').select();
    setState(() {
      estudiantes = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Students")),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: estudiantes.length,
        itemBuilder: (context, index) {
          final est = estudiantes[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF00FF88),
                  child: Icon(Icons.person, color: Colors.black),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(est['email'] ?? '', style: const TextStyle(color: Colors.white)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF88).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          est['rol'] ?? 'cliente',
                          style: const TextStyle(color: Color(0xFF00FF88), fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ================= CALENDARIO =================

class CalendarioPage extends StatefulWidget {
  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  List clases = [];

  @override
  void initState() {
    super.initState();
    cargarClases();
  }

  Future<void> cargarClases() async {
    final response = await Supabase.instance.client
        .from('clases')
        .select()
        .order('fecha', ascending: true);
    setState(() {
      clases = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule")),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: clases.length,
        itemBuilder: (context, index) {
          final clase = clases[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF88).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center, color: Color(0xFF00FF88)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(clase['nombre'] ?? '',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("Cupo: ${clase['cupo']}",
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                if (clase['intensidad'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: clase['intensidad'] == 'alta'
                          ? Colors.red.withOpacity(0.3)
                          : clase['intensidad'] == 'media'
                              ? Colors.orange.withOpacity(0.3)
                              : Colors.green.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      clase['intensidad'].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: clase['intensidad'] == 'alta'
                            ? Colors.red
                            : clase['intensidad'] == 'media'
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
