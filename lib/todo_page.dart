import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TodoPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Map<String, dynamic>> _todoList = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('todos');
    if (jsonString != null) {
      List<dynamic> jsonData = jsonDecode(jsonString);
      setState(() {
        _todoList =
            jsonData.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(_todoList);
    await prefs.setString('todos', jsonString);
  }

  // Delete a task
  void _deleteTodoItem(int index) {
    setState(() {
      _todoList.removeAt(index);
      _saveTodoList();
    });
  }

  // Show the dialog to add or edit tasks
  void _showAddOrEditDialog({int? index}) {
    if (index != null) {
      _editingIndex = index;
      _titleController.text = _todoList[index]['title'];
      _descriptionController.text = _todoList[index]['description'];
    } else {
      _editingIndex = null;
      _titleController.clear();
      _descriptionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _editingIndex == null ? 'Add New Task' : 'Edit Task',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Task Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.isNotEmpty) {
                          setState(() {
                            if (_editingIndex == null) {
                              _todoList.add({
                                'title': _titleController.text,
                                'description': _descriptionController.text,
                                'completed': false,
                              });
                            } else {
                              _todoList[_editingIndex!] = {
                                'title': _titleController.text,
                                'description': _descriptionController.text,
                                'completed': _todoList[_editingIndex!]
                                    ['completed'],
                              };
                            }
                            _saveTodoList();
                          });
                          _titleController.clear();
                          _descriptionController.clear();
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Task title cannot be empty!"),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _titleController.clear();
                        _descriptionController.clear();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Toggle task completion status
  void _toggleTaskStatus(int index) {
    setState(() {
      _todoList[index]['completed'] = !_todoList[index]['completed'];
      _saveTodoList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ToDo List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue.shade50,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView.builder(
          itemCount: _todoList.length,
          itemBuilder: (context, index) {
            final item = _todoList[index];
            return GestureDetector(
              onTap: () => _toggleTaskStatus(index),
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: Icon(
                    item['completed']
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: item['completed'] ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: item['completed']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                    item['description'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      decoration: item['completed']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddOrEditDialog(index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTodoItem(index),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditDialog(),
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, size: 30, color: Colors.white),
        label: const Text(
          'Add Task',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
