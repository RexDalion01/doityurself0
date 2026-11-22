
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color green = Color(0xFF20A879);
  static const Color dark = Color(0xFF252525);
  static const Color gray = Color(0xFF888888);

  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // Load tasks from SQLite
  Future<void> loadTasks() async {
    try {
      final loadedTasks = await DatabaseService.instance.getTasks();

      if (!mounted) return;

      setState(() {
        tasks = loadedTasks;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('Unable to load tasks: $e');
    }
  }

  int get completedTasks {
    return tasks.where((task) => task.isComplete).length;
  }

  double get progress {
    if (tasks.isEmpty) {
      return 0;
    }

    return completedTasks / tasks.length;
  }

  // Show a message
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello There!',
                        style: TextStyle(
                          fontSize: 15,
                          color: gray,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'My Tasks',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: dark,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      color: green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Productivity card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your productivity',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Keep it up!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white30,
                      color: Colors.white,
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(progress * 100).round()}% of your tasks completed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Task list header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: dark,
                    ),
                  ),
                  Text(
                    '${tasks.length} Tasks',
                    style: const TextStyle(
                      fontSize: 13,
                      color: gray,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Task list
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: green,
                        ),
                      )
                    : tasks.isEmpty
                        ? const Center(
                            child: Text(
                              'No tasks yet. Add your first task!',
                              style: TextStyle(
                                color: gray,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              return taskCard(tasks[index], index);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),

      // Add task button
      floatingActionButton: FloatingActionButton(
        backgroundColor: green,
        onPressed: showAddTaskDialog,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  // Add task dialog
  Future<void> showAddTaskDialog() async {
    final titleController = TextEditingController();
    String selectedCategory = 'Personal';
    DateTime? selectedDueDate;

    try {
      final newTask = await showDialog<Task>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Add New Task'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'Personal',
                        'School',
                        'Chore',
                        'Shopping',
                      ].map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDueDate == null
                                ? 'No due date selected'
                                : 'Due: ${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}',
                            style: const TextStyle(
                              color: gray,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: selectedDueDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedDueDate = pickedDate;
                              });
                            }
                          },
                          child: const Text('Choose Date'),
                        ),
                      ],
                    ),
                    if (selectedDueDate != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setDialogState(() {
                              selectedDueDate = null;
                            });
                          },
                          child: const Text('Remove Date'),
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) {
                        return;
                      }

                      final task = Task(
                        title: titleController.text.trim(),
                        category: selectedCategory,
                        dueDate: selectedDueDate,
                      );

                      Navigator.pop(dialogContext, task);
                    },
                    child: const Text('Add Task'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (newTask != null) {
        await DatabaseService.instance.insertTask(newTask);
        await loadTasks();

        if (!mounted) return;
        showMessage('Task added successfully!');
      }
    } catch (e) {
      if (!mounted) return;
      showMessage('Unable to add task: $e');
    } finally {
      titleController.dispose();
    }
  }

  // Edit task dialog
  Future<void> showEditTaskDialog(int index) async {
    final task = tasks[index];
    final titleController = TextEditingController(text: task.title);
    String selectedCategory = task.category;
    DateTime? selectedDueDate = task.dueDate;

    try {
      final updatedTask = await showDialog<Task>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Edit Task'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'Personal',
                        'School',
                        'Chore',
                        'Shopping',
                      ].map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDueDate == null
                                ? 'No due date selected'
                                : 'Due: ${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}',
                            style: const TextStyle(
                              color: gray,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: selectedDueDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedDueDate = pickedDate;
                              });
                            }
                          },
                          child: const Text('Choose Date'),
                        ),
                      ],
                    ),
                    if (selectedDueDate != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setDialogState(() {
                              selectedDueDate = null;
                            });
                          },
                          child: const Text('Remove Date'),
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) {
                        return;
                      }

                      final updatedTask = Task(
                        id: task.id,
                        title: titleController.text.trim(),
                        category: selectedCategory,
                        isComplete: task.isComplete,
                        dueDate: selectedDueDate,
                      );

                      Navigator.pop(dialogContext, updatedTask);
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (updatedTask != null) {
        await DatabaseService.instance.updateTask(updatedTask);
        await loadTasks();

        if (!mounted) return;
        showMessage('Task updated successfully!');
      }
    } catch (e) {
      if (!mounted) return;
      showMessage('Unable to update task: $e');
    } finally {
      titleController.dispose();
    }
  }

  // Task card
  Widget taskCard(Task task, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              toggleTask(index);
            },
            child: Icon(
              task.isComplete
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: task.isComplete ? green : gray,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: dark,
                    decoration: task.isComplete
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  task.category,
                  style: const TextStyle(
                    fontSize: 13,
                    color: gray,
                  ),
                ),
                if(task.dueDate != null) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: gray,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Due: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: gray,
                        ),
                      ),
                    ],
                  ),
                ],

              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz,
              color: gray,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                showEditTaskDialog(index);
              } else if (value == 'delete') {
                deleteTask(index);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Task'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Task'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Toggle task completion
  Future<void> toggleTask(int index) async {
    final task = tasks[index];

    final updatedTask = Task(
      id: task.id,
      title: task.title,
      category: task.category,
      isComplete: !task.isComplete,
      dueDate: task.dueDate,
    );

    try {
      await DatabaseService.instance.updateTask(updatedTask);
      await loadTasks();
    } catch (e) {
      if (!mounted) return;
      showMessage('Unable to update task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(int index) async {
    final task = tasks[index];

    try {
      await DatabaseService.instance.deleteTask(task.id!);
      await loadTasks();

      if (!mounted) return;
      showMessage('Task deleted successfully!');
    } catch (e) {
      if (!mounted) return;
      showMessage('Unable to delete task: $e');
    }
  }
}
