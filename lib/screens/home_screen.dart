
import 'package:doityurself0/screens/calendar_screen.dart';
import 'package:doityurself0/screens/daily_agenda_screen.dart';
import 'package:doityurself0/screens/statistics_screen.dart';
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
  String selectedSort = 'High to Low';
  String searchQuery = '';
  String selectedCategory = 'All';
  bool isLoading = true;

  int priorityRank(String priority) {
    if(priority == 'High') {
      return 1;
    } else if (priority == 'Medium') {
      return 2;
    } else {
      return 3;
    }
  }

List<int> get sortedTaskIndexes {
  final indexes = List.generate(tasks.length, (index) => index);

  indexes.removeWhere((index) {
    final task = tasks[index];
    final query = searchQuery.toLowerCase().trim();

    final matchesSearch = 
        task.title.toLowerCase().contains(query) || 
        task.description.toLowerCase().contains(query);
    
    final matchesCategory = 
        selectedCategory == 'All' ||
        task.category == selectedCategory;
    
    return !matchesSearch || !matchesCategory;
  });

  indexes.sort((a, b) {
    if (selectedSort == 'Default') {
      return a.compareTo(b);
    }

    final comparison = priorityRank(
      tasks[a].priority,
    ).compareTo(
      priorityRank(tasks[b].priority),
    );

    if (selectedSort == 'Low to High') {
      return -comparison;
    } else {
      return comparison;
    }
  });

  return indexes;
}

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
                  Column(
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dark,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DailyAgendaScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.today_outlined,
                            color: green,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CalendarScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.calendar_month_outlined,
                            color: green,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StatisticsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.bar_chart,
                            color: green,
                          ),
                        ),
                      ),
                    ],
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${sortedTaskIndexes.length} Tasks',
                        style: const TextStyle(
                          fontSize: 13,
                          color: gray,
                        ),
                      ),

                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: gray,
                          size: 22,
                        ),
                        tooltip: 'Sort tasks',
                        onSelected: (value) {
                          setState(() {
                            selectedSort = value;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'High to Low',
                            child: Text('High to Low'),
                          ),
                          const PopupMenuItem(
                            value: 'Low to High',
                            child: Text('Low to High'),
                          ),
                          const PopupMenuItem(
                            value: 'Default',
                            child: Text('Default'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Search bar
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: gray,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),

              //Category filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'All',
                    'Personal',
                    'School',
                    'Chore',
                    'Shopping',
                  ].map((category) {
                    final isSelected = selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: green,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : dark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (selected){
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 15),
              
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
                            itemCount: sortedTaskIndexes.length,
                            itemBuilder: (context, index) {
                              final taskIndex = sortedTaskIndexes[index];

                              return taskCard(tasks[taskIndex], taskIndex);
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
  String taskTitle = '';
  String taskDescription = '';
  String selectedCategory = 'Personal';
  String selectedPriority = 'Medium';
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
                    decoration: const InputDecoration(
                      labelText: 'Task title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      taskTitle = value;
                    },
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

                  TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Enter task details...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    onChanged: (value) {
                      taskDescription = value;
                    },
                  ),

                  const SizedBox(height: 15),
                                      DropdownButtonFormField<String>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'High',
                        'Medium',
                        'Low',
                      ].map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedPriority = value;
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
                    if (taskTitle.trim().isEmpty) {
                      return;
                    }

                    final task = Task(
                      title: taskTitle.trim(),
                      description: taskDescription.trim(),
                      category: selectedCategory,
                      dueDate: selectedDueDate,
                      priority: selectedPriority,
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
  }
}

  // Edit task dialog
  Future<void> showEditTaskDialog(int index) async {
    final task = tasks[index];
    String editedTitle = task.title;
    String editedDescription = task.description;

    String selectedCategory = task.category;
    String selectedPriority = task.priority;
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
                    TextFormField(
                      initialValue: editedTitle,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        editedTitle = value;
                      },
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
                    TextFormField(
                      initialValue: editedDescription,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Enter task details...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      onChanged: (value) {
                        editedDescription = value;
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'High',
                        'Medium',
                        'Low',
                      ].map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if(value != null) {
                          setDialogState(() {
                            selectedPriority = value;
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
                      if (editedTitle.trim().isEmpty) {
                        return;
                      }

                      final updatedTask = Task(
                        id: task.id,
                        title: editedTitle.trim(),
                        description: editedDescription.trim(),
                        category: selectedCategory,
                        isComplete: task.isComplete,
                        dueDate: selectedDueDate,
                        priority: selectedPriority,
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

                if(task.description.isNotEmpty) ... [
                  const SizedBox(height: 5),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: gray,
                    ),
                  ),
                ],

                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: task.priority == 'High'
                    ? Colors.red.shade50
                    : task.priority == 'Medium'
                        ? Colors.orange.shade50
                        : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${task.priority} Priority',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: task.priority == 'High'
                        ? Colors.red
                        : task.priority == 'Medium'
                          ? Colors.orange.shade800
                          : Colors.green.shade700,
                    ),
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
      priority: task.priority,
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
