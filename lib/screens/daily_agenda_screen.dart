import 'package:doityurself0/services/database_service.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';

class DailyAgendaScreen extends StatefulWidget{
  const DailyAgendaScreen({super.key});

  @override
  State<DailyAgendaScreen> createState() => _DailyAgendaScreenState();
}

class _DailyAgendaScreenState extends State<DailyAgendaScreen>{
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

  Future<void> loadTasks() async {
    try{
      final loadedTasks = 
      await DatabaseService.instance.getTasks();

      if(!mounted) return;

      setState(() {
        tasks = loadedTasks;
        isLoading = false;
      });
    } catch (e) {
      if(!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load tasks: $e'),
        ),
      );
    }
  }


  DateTime get today {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day);
  }

  DateTime getDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<Task> get overdueTasks {
    return tasks.where((task) {
      if(task.dueDate == null || task.isComplete){
        return false;
      }

      return getDateOnly(task.dueDate!).isBefore(today);
    }).toList();
  }

  List<Task> get todaysTasks {
    return tasks.where((task) {
      if(task.dueDate == null || task.isComplete) {
        return false;
      }

      return getDateOnly(task.dueDate!) == today;
    }).toList();
  }

  List<Task> get completedTasks {
  return tasks.where((task) {
    return task.isComplete;
  }).toList();
  }

  String get formattedDate {
    const months = [
            'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[today.month - 1]} ${today.day}, ${today.year}';
  }

  Widget sectionHeader(
    String title,
    int count,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget taskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            task.isComplete
              ? Icons.check_circle
              : Icons.circle_outlined,
            color: task.isComplete ? green : gray,
          ),

          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment:  CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:  FontWeight.w600,
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
                  Text(
                    'Due: ${task.dueDate!.month}/${task.dueDate!.day}/${task.dueDate!.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: gray
                    ),
                  ),
                ],
                
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: gray,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget buildSection({ 
    required String title,
    required List<Task> sectionTasks,
    required Color color,
    required String emptyMessage,
  }) {
    return Column(
      children: [
        sectionHeader(title, sectionTasks.length, color),

        if(sectionTasks.isEmpty)
          emptyState(emptyMessage)
        else
          ...sectionTasks.map(taskCard),

        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),

      appBar: AppBar(
        backgroundColor:  const Color(0xFFF8F9F8),
        elevation: 0,
        title: const Text(
          'Daily Agenda',
        style: TextStyle(
          color: dark,
          fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: dark),
      ),

      body: isLoading
        ? const Center(
          child: CircularProgressIndicator(
            color: green,
            ),
          )
        : RefreshIndicator(
          color: green,
          onRefresh: loadTasks,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Your Schedule',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: dark,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: gray,
                  ),
                ),

                const SizedBox(height: 28),

                buildSection(
                  title: 'Overdue Tasks',
                  sectionTasks: overdueTasks,
                  color: Colors.red,
                  emptyMessage: 'No overdue tasks. Great job!',
                ),

                buildSection(
                  title: "Today's Tasks",
                  sectionTasks: todaysTasks,
                  color: green,
                  emptyMessage: 'No tasks scheduled for today.', 
                ),

                buildSection(
                  title: 'Completed Tasks',
                  sectionTasks: completedTasks,
                  color: Colors.blue,
                  emptyMessage: 'No completed tasks due today yet.',
                ),
              ],
            ),
          ),
    );
  }
}