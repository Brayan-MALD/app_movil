import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi App Flutter',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF1E1E2C),
          secondary: const Color(0xFFFFC857), // dorado elegante
          surface: const Color(0xFF2D2D44),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            backgroundColor: const Color(0xFFFFC857),
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2C),
          elevation: 5,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          hintStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

/// -------------------- WIDGET DE FONDO --------------------
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF3D2C8D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

/// -------------------- LOGIN --------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // Mapa local de usuarios (simula "base de datos" pequeña en memoria)
  final Map<String, String> _users = {
    "usuario1": "1234",
    "admin": "admin123",
  };

  String _message = "";

  void _login() {
    String user = _userController.text.trim();
    String pass = _passController.text.trim();

    if (_users.containsKey(user) && _users[user] == pass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(username: user, users: _users),
        ),
      );
    } else {
      setState(() {
        _message = "❌ Usuario o contraseña incorrectos";
      });
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(users: _users),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.lock_outline, size: 96, color: Color(0xFFFFC857)),
                const SizedBox(height: 18),
                const Text(
                  "Bienvenido",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 24),
                _buildLoginCard(),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: _goToRegister,
                  child: const Text("Crear cuenta",
                      style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 12),
                if (_message.isNotEmpty)
                  Text(_message, style: const TextStyle(fontSize: 16, color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _userController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Usuario",
              prefixIcon: Icon(Icons.person, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passController,
            style: const TextStyle(color: Colors.white),
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Contraseña",
              prefixIcon: Icon(Icons.lock, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _login,
            child: const SizedBox(
              width: double.infinity,
              child: Center(child: Text("Ingresar")),
            ),
          ),
        ],
      ),
    );
  }
}

/// -------------------- REGISTRO --------------------
class RegisterPage extends StatefulWidget {
  final Map<String, String> users;
  const RegisterPage({super.key, required this.users});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _newUserController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String _message = "";

  void _register() {
    String user = _newUserController.text.trim();
    String pass = _newPassController.text.trim();
    String confirm = _confirmController.text.trim();

    if (user.isEmpty || pass.isEmpty || confirm.isEmpty) {
      setState(() => _message = "⚠️ Los campos no pueden estar vacíos");
      return;
    }

    if (pass != confirm) {
      setState(() => _message = "⚠️ Las contraseñas no coinciden");
      return;
    }

    if (widget.users.containsKey(user)) {
      setState(() => _message = "⚠️ El usuario ya existe");
    } else {
      widget.users[user] = pass;
      setState(() => _message = "✅ Usuario registrado con éxito");
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Registro")),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.person_add, size: 84, color: Color(0xFFFFC857)),
                const SizedBox(height: 16),
                const Text("Crear cuenta",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 18),
                _buildRegisterCard(),
                const SizedBox(height: 12),
                if (_message.isNotEmpty)
                  Text(_message, style: const TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _newUserController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: "Usuario", prefixIcon: Icon(Icons.person, color: Colors.white70)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newPassController,
            style: const TextStyle(color: Colors.white),
            obscureText: true,
            decoration: const InputDecoration(hintText: "Contraseña", prefixIcon: Icon(Icons.lock, color: Colors.white70)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmController,
            style: const TextStyle(color: Colors.white),
            obscureText: true,
            decoration: const InputDecoration(hintText: "Confirmar contraseña", prefixIcon: Icon(Icons.lock_outline, color: Colors.white70)),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _register,
            child: const SizedBox(width: double.infinity, child: Center(child: Text("Registrarse"))),
          ),
        ],
      ),
    );
  }
}

/// -------------------- DASHBOARD --------------------
class DashboardPage extends StatefulWidget {
  final String username;
  final Map<String, String> users;
  const DashboardPage({super.key, required this.username, required this.users});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // No usar const aquí porque las páginas son stateful y manejan setState internamente
    _pages = [
      HomePage(username: widget.username),
      TasksPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Mi App - ${widget.username}"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF1E1E2C),
          selectedItemColor: const Color(0xFFFFC857),
          unselectedItemColor: Colors.white70,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "Tareas"),
          ],
        ),
      ),
    );
  }
}

/// -------------------- PERFIL / HOME --------------------
class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  final picker = ImagePicker();
  String nombre = "";
  String correo = "";
  String descripcion = "";

  @override
  void initState() {
    super.initState();
    // Inicializar con datos por defecto
    nombre = widget.username;
    correo = "${widget.username}@ejemplo.com";
    descripcion = "Aquí va una breve descripción del usuario.";
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _editField(String field, String value) async {
    final controller = TextEditingController(text: value);
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        title: Text("Editar $field", style: const TextStyle(color: Colors.white)),
        content: TextField(controller: controller, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text("Guardar")),
        ],
      ),
    );
    if (newValue != null) {
      setState(() {
        if (field == "Nombre") nombre = newValue;
        if (field == "Correo") correo = newValue;
        if (field == "Descripción") descripcion = newValue;
      });
    }
  }

  Widget _buildInfoCard(String label, String value, IconData icon, VoidCallback onEdit) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
          IconButton(icon: const Icon(Icons.edit, color: Colors.white70), onPressed: onEdit),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? const Icon(Icons.person, size: 60, color: Colors.white70) : null,
                  backgroundColor: Colors.white10,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFFFFC857),
                    onPressed: _pickImage,
                    child: const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(nombre, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(correo, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          _buildInfoCard("Nombre", nombre, Icons.person, () => _editField("Nombre", nombre)),
          _buildInfoCard("Correo", correo, Icons.email, () => _editField("Correo", correo)),
          _buildInfoCard("Descripción", descripcion, Icons.info, () => _editField("Descripción", descripcion)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// -------------------- TAREAS --------------------
class Task {
  String title;
  String deadline;
  String priority;
  bool completed;

  Task({required this.title, required this.deadline, required this.priority, this.completed = false});

  static String encode(List<Task> tasks) => json.encode(tasks.map((t) => {
        "title": t.title,
        "deadline": t.deadline,
        "priority": t.priority,
        "completed": t.completed,
      }).toList());

  static List<Task> decode(String tasksData) {
    return (json.decode(tasksData) as List<dynamic>).map((e) => Task(
          title: e["title"],
          deadline: e["deadline"],
          priority: e["priority"],
          completed: e["completed"],
        )).toList();
  }
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("tasks");
    if (data != null) setState(() => tasks = Task.decode(data));
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("tasks", Task.encode(tasks));
  }

  void _addTask(Task task) {
    setState(() => tasks.add(task));
    _saveTasks();
  }

  void _removeTask(int index) {
    setState(() => tasks.removeAt(index));
    _saveTasks();
  }

  void _toggleCompleted(int index, bool? value) {
    setState(() => tasks[index].completed = value ?? false);
    _saveTasks();
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    String priority = "Media";
    String deadline = DateTime.now().toString().split(" ")[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2D2D44),
            title: const Text("Nueva tarea", style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Título")),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Fecha límite: ", style: TextStyle(color: Colors.white70)),
                    Text(deadline, style: const TextStyle(color: Colors.white70)),
                    IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.white70),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          builder: (context, child) => Theme(data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFF3D2C8D),
                                onPrimary: Colors.white,
                                surface: Color(0xFF2D2D44),
                                onSurface: Colors.white,
                              )), child: child!),
                        );
                        if (picked != null) {
                          setDialogState(() => deadline = picked.toString().split(" ")[0]);
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  dropdownColor: const Color(0xFF2D2D44),
                  value: priority,
                  isExpanded: true,
                  items: ["Alta", "Media", "Baja"].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setDialogState(() => priority = v!),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    _addTask(Task(title: titleController.text, deadline: deadline, priority: priority));
                    Navigator.pop(context);
                  }
                },
                child: const Text("Guardar"),
              )
            ],
          );
        });
      },
    );
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case "Alta":
        return Colors.redAccent;
      case "Media":
        return Colors.orangeAccent;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            itemCount: tasks.length,
            itemBuilder: (context, i) {
              final task = tasks[i];
              return Dismissible(
                key: Key(task.title + i.toString()),
                onDismissed: (dir) => _removeTask(i),
                background: Container(color: Colors.redAccent),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getPriorityColor(task.priority),
                      child: Icon(task.completed ? Icons.check : Icons.pending, color: Colors.white),
                    ),
                    title: Text(task.title, style: TextStyle(color: Colors.white, decoration: task.completed ? TextDecoration.lineThrough : null)),
                    subtitle: Text("📅 ${task.deadline}  •  🔥 ${task.priority}", style: const TextStyle(color: Colors.white70)),
                    trailing: Checkbox(value: task.completed, onChanged: (v) => _toggleCompleted(i, v)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailPage(
                            task: task,
                            onDelete: () {
                              _removeTask(i);
                              Navigator.pop(context);
                            },
                            onUpdate: (updatedTask) {
                              setState(() => tasks[i] = updatedTask);
                              _saveTasks();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFFFFC857),
              onPressed: _showAddTaskDialog,
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

/// -------------------- DETALLE DE TAREA --------------------
class TaskDetailPage extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final Function(Task) onUpdate;

  const TaskDetailPage({super.key, required this.task, required this.onDelete, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        appBar: AppBar(title: const Text("Detalle de tarea")),
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              Text("📅 Fecha límite: ${task.deadline}", style: const TextStyle(fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 10),
              Text("🔥 Prioridad: ${task.priority}", style: const TextStyle(fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 30),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Marcar completada"),
                    onPressed: () {
                      onUpdate(Task(title: task.title, deadline: task.deadline, priority: task.priority, completed: true));
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("Eliminar"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: onDelete,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
