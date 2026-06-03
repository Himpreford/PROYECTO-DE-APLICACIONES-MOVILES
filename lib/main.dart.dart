import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pbfbmazzyyclzavvbtkb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBiZmJtYXp6eXljbHphdnZidGtiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyMDYxNTgsImV4cCI6MjA5Mjc4MjE1OH0.1xZ34_rq_d4vYFBBlHPaXAdBrQaxmwjWmEnPYtpHnxM',
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    if (event == AuthChangeEvent.passwordRecovery) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
        (route) => false,
      );
    }
  });

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ================= APP =================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'GymApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00FF88),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0A),
          foregroundColor: Color(0xFF00FF88),
          elevation: 0,
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
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');
        if (uri.fragment.contains('access_token') ||
            uri.queryParameters.containsKey('access_token')) {
          return MaterialPageRoute(builder: (_) => const ResetPasswordPage());
        }
        return null;
      },
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
                            MaterialPageRoute(builder: (_) => const HomePage()),
                          );
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
                      MaterialPageRoute(
                        builder: (_) => RecuperarPasswordPage(),
                      ),
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
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Completa todos los campos"),
                      ),
                    );
                    return;
                  }
                  try {
                    final response = await Supabase.instance.client.auth.signUp(
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
                        const SnackBar(
                          content: Text("Cuenta creada exitosamente"),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
      appBar: AppBar(title: const Text("Recuperar Contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_reset, color: Color(0xFF00FF88), size: 60),
            const SizedBox(height: 20),
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
              "Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
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
                        content: Text(
                          "Correo enviado. Revisa tu bandeja de entrada.",
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ClientProfilePage()),
              );
            },
            icon: const Icon(Icons.person, color: Color(0xFF00FF88)),
          ),
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
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
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00FF88)),
            );
          }
          final data = snapshot.data as Map?;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF00FF88).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF00FF88),
                        child: Icon(
                          Icons.person,
                          color: Colors.black,
                          size: 30,
                        ),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FF88).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              data?['rol'] ?? 'cliente',
                              style: const TextStyle(
                                color: Color(0xFF00FF88),
                                fontSize: 12,
                              ),
                            ),
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
                const SizedBox(height: 15),
                Row(
                  children: [
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
                    const SizedBox(width: 15),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.person,
                        label: "Mi Perfil",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClientProfilePage(),
                          ),
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

// ================= ACTION CARD WIDGET =================

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
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
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
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminProfilePage()),
              );
            },
            icon: const Icon(
              Icons.admin_panel_settings,
              color: Color(0xFF00FF88),
            ),
          ),
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
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
                border: Border.all(
                  color: const Color(0xFF00FF88).withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF00FF88),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Panel de Admin",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          color: Color(0xFF00FF88),
                          fontSize: 12,
                        ),
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
                    icon: Icons.add_circle,
                    label: "Crear Clase",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CrearClasePage()),
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
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.person,
                    label: "Mi Perfil",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminProfilePage()),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(child: SizedBox()),
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

  Color _intensityColor(String? intensidad) {
    switch (intensidad) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Classes"),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: clases.isEmpty
          ? const Center(
              child: Text(
                "No hay clases disponibles",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: clases.length,
              itemBuilder: (context, index) {
                final clase = clases[index];
                final intensidad = clase['intensidad'] as String?;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClassDetailsPage(clase: clase),
                      ),
                    ).then((_) => obtenerClases());
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF00FF88).withOpacity(0.3),
                      ),
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
                        child: const Icon(
                          Icons.fitness_center,
                          color: Color(0xFF00FF88),
                        ),
                      ),
                      title: Text(
                        clase['nombre'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clase['descripcion'] ?? '',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.people,
                                color: Color(0xFF00FF88),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Cupo: ${clase['cupo']}",
                                style: const TextStyle(
                                  color: Color(0xFF00FF88),
                                  fontSize: 12,
                                ),
                              ),
                              if (intensidad != null) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _intensityColor(
                                      intensidad,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    intensidad.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _intensityColor(intensidad),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF00FF88),
                        size: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ================= CLASS DETAILS =================

class ClassDetailsPage extends StatefulWidget {
  final Map clase;
  const ClassDetailsPage({super.key, required this.clase});

  @override
  State<ClassDetailsPage> createState() => _ClassDetailsPageState();
}

class _ClassDetailsPageState extends State<ClassDetailsPage> {
  bool yaInscrito = false;
  int inscritos = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    verificarInscripcion();
  }

  Future<void> verificarInscripcion() async {
    final user = Supabase.instance.client.auth.currentUser;
    final existe = await Supabase.instance.client
        .from('inscripciones')
        .select()
        .eq('user_id', user?.id ?? '')
        .eq('clase_id', widget.clase['id']);

    final totalInscritos = await Supabase.instance.client
        .from('inscripciones')
        .select()
        .eq('clase_id', widget.clase['id']);

    setState(() {
      yaInscrito = existe.isNotEmpty;
      inscritos = totalInscritos.length;
      loading = false;
    });
  }

  Color _intensityColor(String? intensidad) {
    switch (intensidad) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _formatFecha(dynamic fecha) {
    if (fecha == null) return 'Sin fecha';
    try {
      final dt = DateTime.parse(fecha.toString());
      return "${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return fecha.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final clase = widget.clase;
    final intensidad = clase['intensidad'] as String?;
    final cupo = clase['cupo'] as int? ?? 0;
    final disponibles = cupo - inscritos;

    return Scaffold(
      appBar: AppBar(
        title: Text(clase['nombre'] ?? 'Clase'),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00FF88)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image placeholder
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF00FF88),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.fitness_center,
                        color: Color(0xFF00FF88),
                        size: 80,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nombre + intensidad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          clase['nombre'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (intensidad != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _intensityColor(intensidad).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _intensityColor(intensidad),
                            ),
                          ),
                          child: Text(
                            intensidad.toUpperCase(),
                            style: TextStyle(
                              color: _intensityColor(intensidad),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Descripción
                  Text(
                    clase['descripcion'] ?? 'Sin descripción',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Info cards
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today,
                          label: "Fecha",
                          value: _formatFecha(clase['fecha']),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.people,
                          label: "Cupo",
                          value: "$inscritos / $cupo",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.event_available,
                          label: "Disponibles",
                          value: "$disponibles",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Botón inscribirse
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: yaInscrito || disponibles <= 0
                          ? null
                          : () async {
                              final user =
                                  Supabase.instance.client.auth.currentUser;
                              try {
                                await Supabase.instance.client
                                    .from('inscripciones')
                                    .insert({
                                      'user_id': user?.id,
                                      'clase_id': clase['id'],
                                    });
                                setState(() {
                                  yaInscrito = true;
                                  inscritos++;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("¡Inscripción exitosa! 🎉"),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              }
                            },
                      icon: Icon(
                        yaInscrito ? Icons.check_circle : Icons.fitness_center,
                      ),
                      label: Text(
                        yaInscrito
                            ? "Ya estás inscrito"
                            : disponibles <= 0
                            ? "Clase llena"
                            : "Inscribirse",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yaInscrito || disponibles <= 0
                            ? Colors.grey
                            : const Color(0xFF00FF88),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),

                  if (yaInscrito) ...[
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final user =
                              Supabase.instance.client.auth.currentUser;
                          try {
                            await Supabase.instance.client
                                .from('inscripciones')
                                .delete()
                                .eq('user_id', user?.id ?? '')
                                .eq('clase_id', clase['id']);
                            setState(() {
                              yaInscrito = false;
                              inscritos--;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Inscripción cancelada"),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                        ),
                        label: const Text(
                          "Cancelar inscripción",
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00FF88), size: 20),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CREAR / EDITAR CLASE =================

class CrearClasePage extends StatefulWidget {
  final Map? claseExistente; // si no es null, estamos editando

  const CrearClasePage({super.key, this.claseExistente});

  @override
  State<CrearClasePage> createState() => _CrearClasePageState();
}

class _CrearClasePageState extends State<CrearClasePage> {
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final cupoController = TextEditingController();
  String intensidadSeleccionada = 'media';
  DateTime? fechaSeleccionada;

  bool get esEdicion => widget.claseExistente != null;

  @override
  void initState() {
    super.initState();
    if (esEdicion) {
      final c = widget.claseExistente!;
      nombreController.text = c['nombre'] ?? '';
      descripcionController.text = c['descripcion'] ?? '';
      cupoController.text = c['cupo']?.toString() ?? '';
      intensidadSeleccionada = c['intensidad'] ?? 'media';
      if (c['fecha'] != null) {
        try {
          fechaSeleccionada = DateTime.parse(c['fecha']);
        } catch (_) {}
      }
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00FF88),
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          fechaSeleccionada ?? DateTime.now(),
        ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00FF88),
                onPrimary: Colors.black,
                surface: Color(0xFF1A1A1A),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );
      if (time != null) {
        setState(() {
          fechaSeleccionada = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _formatFecha(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? "Editar Clase" : "Create Class"),
        actions: [
          TextButton(
            onPressed: () async {
              if (nombreController.text.isEmpty ||
                  cupoController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Completa los campos obligatorios"),
                  ),
                );
                return;
              }
              final data = {
                'nombre': nombreController.text,
                'descripcion': descripcionController.text,
                'fecha': (fechaSeleccionada ?? DateTime.now())
                    .toIso8601String(),
                'cupo': int.tryParse(cupoController.text) ?? 0,
                'intensidad': intensidadSeleccionada,
              };

              try {
                if (esEdicion) {
                  await Supabase.instance.client
                      .from('clases')
                      .update(data)
                      .eq('id', widget.claseExistente!['id']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Clase actualizada")),
                  );
                } else {
                  await Supabase.instance.client.from('clases').insert(data);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Clase creada exitosamente")),
                  );
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Color(0xFF00FF88), fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo placeholder
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
                    Text(
                      "Add Class Photo",
                      style: TextStyle(color: Color(0xFF00FF88)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              "BASIC INFORMATION",
              style: TextStyle(
                color: Color(0xFF00FF88),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
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
                      labelText: "Class Title *",
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
                      labelText: "Capacity *",
                      prefixIcon: Icon(Icons.people, color: Color(0xFF00FF88)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Fecha y hora
            const Text(
              "FECHA Y HORA",
              style: TextStyle(
                color: Color(0xFF00FF88),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: _seleccionarFecha,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF00FF88).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF00FF88)),
                    const SizedBox(width: 15),
                    Text(
                      fechaSeleccionada != null
                          ? _formatFecha(fechaSeleccionada!)
                          : "Seleccionar fecha y hora",
                      style: TextStyle(
                        color: fechaSeleccionada != null
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Intensidad
            const Text(
              "INTENSIDAD",
              style: TextStyle(
                color: Color(0xFF00FF88),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
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
                  Color color = nivel == 'alta'
                      ? Colors.red
                      : nivel == 'media'
                      ? Colors.orange
                      : Colors.green;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => intensidadSeleccionada = nivel),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : Colors.grey,
                          ),
                        ),
                        child: Text(
                          nivel.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? color : Colors.grey,
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

// ================= MIS CLASES / RESERVACIONES =================

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
        .select('*, clases(*)')
        .eq('user_id', user?.id ?? '');
    setState(() {
      clases = response;
    });
  }

  Color _intensityColor(String? intensidad) {
    switch (intensidad) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reservations"),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: clases.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    color: Color(0xFF00FF88),
                    size: 60,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "No tienes clases inscritas",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: clases.length,
              itemBuilder: (context, index) {
                final inscripcion = clases[index];
                final clase = inscripcion['clases'];
                if (clase == null) return const SizedBox();
                final intensidad = clase['intensidad'] as String?;
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF00FF88).withOpacity(0.3),
                    ),
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
                        child: const Icon(
                          Icons.fitness_center,
                          color: Color(0xFF00FF88),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clase['nombre'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              clase['descripcion'] ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            if (intensidad != null)
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _intensityColor(
                                    intensidad,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  intensidad.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _intensityColor(intensidad),
                                  ),
                                ),
                              ),
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

// ================= ESTUDIANTES (ADMIN) =================

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
      appBar: AppBar(
        title: Text("Students (${estudiantes.length})"),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: estudiantes.length,
        itemBuilder: (context, index) {
          final est = estudiantes[index];
          final isAdmin = est['rol'] == 'admin';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isAdmin
                      ? Colors.purple
                      : const Color(0xFF00FF88),
                  child: Icon(
                    isAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        est['email'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? Colors.purple.withOpacity(0.2)
                              : const Color(0xFF00FF88).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          est['rol'] ?? 'cliente',
                          style: TextStyle(
                            color: isAdmin
                                ? Colors.purple
                                : const Color(0xFF00FF88),
                            fontSize: 11,
                          ),
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

// ================= CALENDARIO (ADMIN) =================

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

  Color _intensityColor(String? intensidad) {
    switch (intensidad) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _formatFecha(dynamic fecha) {
    if (fecha == null) return 'Sin fecha';
    try {
      final dt = DateTime.parse(fecha.toString());
      return "${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return fecha.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule"),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00FF88),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CrearClasePage()),
        ).then((_) => cargarClases()),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: clases.isEmpty
          ? const Center(
              child: Text(
                "No hay clases programadas",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: clases.length,
              itemBuilder: (context, index) {
                final clase = clases[index];
                final intensidad = clase['intensidad'] as String?;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF00FF88).withOpacity(0.3),
                    ),
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
                        child: const Icon(
                          Icons.fitness_center,
                          color: Color(0xFF00FF88),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clase['nombre'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatFecha(clase['fecha']),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "Cupo: ${clase['cupo']}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          if (intensidad != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _intensityColor(
                                  intensidad,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                intensidad.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _intensityColor(intensidad),
                                ),
                              ),
                            ),
                          const SizedBox(height: 5),
                          // Botón editar (solo admin ve el calendario con FAB)
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CrearClasePage(claseExistente: clase),
                              ),
                            ).then((_) => cargarClases()),
                            child: const Icon(
                              Icons.edit,
                              color: Color(0xFF00FF88),
                              size: 18,
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

// ================= CLIENT PROFILE =================

class ClientProfilePage extends StatefulWidget {
  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  Map? perfil;
  int totalClases = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarPerfil();
  }

  Future<void> cargarPerfil() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final perfilData = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    final inscripciones = await Supabase.instance.client
        .from('inscripciones')
        .select()
        .eq('user_id', user.id);

    setState(() {
      perfil = perfilData;
      totalClases = inscripciones.length;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00FF88)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00FF88).withOpacity(0.2),
                      border: Border.all(
                        color: const Color(0xFF00FF88),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF00FF88),
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    user?.email?.split('@')[0] ?? 'Usuario',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF88).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "CLIENTE",
                      style: TextStyle(
                        color: Color(0xFF00FF88),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: totalClases.toString(),
                          label: "Clases\nInscritas",
                          icon: Icons.fitness_center,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _StatCard(
                          value: "Activo",
                          label: "Estado\nde cuenta",
                          icon: Icons.check_circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF00FF88).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "INFORMACIÓN DE CUENTA",
                          style: TextStyle(
                            color: Color(0xFF00FF88),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _ProfileRow(
                          icon: Icons.email,
                          label: "Email",
                          value: user?.email ?? '',
                        ),
                        const Divider(color: Colors.grey),
                        _ProfileRow(
                          icon: Icons.person,
                          label: "Rol",
                          value: perfil?['rol'] ?? 'cliente',
                        ),
                        const Divider(color: Colors.grey),
                        _ProfileRow(
                          icon: Icons.calendar_today,
                          label: "Miembro desde",
                          value: user?.createdAt != null
                              ? _formatDate(user!.createdAt)
                              : 'N/A',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Botones acción
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MisClasesPage()),
                      ),
                      icon: const Icon(Icons.bookmark),
                      label: const Text("Ver Mis Reservaciones"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        "Cerrar Sesión",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (_) {
      return dateStr;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00FF88), size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF00FF88),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00FF88), size: 20),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(value, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

// ================= ADMIN PROFILE =================

class AdminProfilePage extends StatefulWidget {
  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  int totalClases = 0;
  int totalEstudiantes = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarEstadisticas();
  }

  Future<void> cargarEstadisticas() async {
    final clases = await Supabase.instance.client.from('clases').select();
    final estudiantes = await Supabase.instance.client.from('users').select();

    setState(() {
      totalClases = clases.length;
      totalEstudiantes = estudiantes.length;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Profile"),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00FF88)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar admin
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple.withOpacity(0.2),
                      border: Border.all(color: Colors.purple, width: 3),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.purple,
                      size: 55,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    user?.email?.split('@')[0] ?? 'Admin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "ADMINISTRADOR",
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Stats del gimnasio
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ESTADÍSTICAS DEL GIMNASIO",
                      style: TextStyle(
                        color: Color(0xFF00FF88),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: totalClases.toString(),
                          label: "Clases\nCreadas",
                          icon: Icons.fitness_center,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _StatCard(
                          value: totalEstudiantes.toString(),
                          label: "Usuarios\nRegistrados",
                          icon: Icons.people,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "INFORMACIÓN DE CUENTA",
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _ProfileRow(
                          icon: Icons.email,
                          label: "Email",
                          value: user?.email ?? '',
                        ),
                        const Divider(color: Colors.grey),
                        _ProfileRow(
                          icon: Icons.admin_panel_settings,
                          label: "Rol",
                          value: "Administrador",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Acciones rápidas
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CrearClasePage(),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle),
                      label: const Text("Crear Nueva Clase"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EstudiantesPage()),
                      ),
                      icon: const Icon(Icons.people),
                      label: const Text("Ver Estudiantes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        "Cerrar Sesión",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});
  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final newPasswordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_reset, color: Color(0xFF00FF88), size: 60),
            const SizedBox(height: 20),
            const Text(
              "Nueva Contraseña",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00FF88),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nueva contraseña",
                prefixIcon: Icon(Icons.lock, color: Color(0xFF00FF88)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Confirmar contraseña",
                prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF00FF88)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (newPasswordController.text != confirmController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Las contraseñas no coinciden"),
                      ),
                    );
                    return;
                  }
                  if (newPasswordController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mínimo 6 caracteres")),
                    );
                    return;
                  }
                  try {
                    await Supabase.instance.client.auth.updateUser(
                      UserAttributes(password: newPasswordController.text),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("¡Contraseña actualizada! ✅"),
                      ),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                      (route) => false,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                child: const Text(
                  "GUARDAR CONTRASEÑA",
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
