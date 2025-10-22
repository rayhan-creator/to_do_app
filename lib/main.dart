import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dgbqdmgucaoflzpwddbh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRnYnFkbWd1Y2FvZmx6cHdkZGJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwNTQzODYsImV4cCI6MjA3NjYzMDM4Nn0.IOPIMsCchRWOPNZENeu23j_Q_phPvCF-Da8qGDlfWBI',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _futureTasks;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _futureTasks = supabase.from('tasks').select();
    });
  }

  Future<void> _showAddTaskDialog() async {
    final textController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tugas Baru'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Misal: Beli Kopi...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final content = textController.text;

                await supabase.from('tasks').insert({'content': content});

                _fetchTasks();

                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateTask(int taskId, bool newStatus) async {
    await supabase
        .from('tasks')
        .update({'is_done': newStatus})
        .eq('id', taskId);

    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beres.in')),
      body: FutureBuilder(
        future: _futureTasks,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                child: CheckboxListTile(
                  value: task['is_done'],

                  title: Text(
                    task['content'],
                    style: TextStyle(
                      decoration: task['is_done']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),

                  onChanged: (bool? newStatus) {
                    if (newStatus != null) {
                      _updateTask(task['id'], newStatus);
                    }
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
