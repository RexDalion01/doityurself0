import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/database_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static const Color green = Color(0xFF20A879);
  static const Color dark = Color(0xFF252525);
  static const Color gray = Color(0xFF888888);

  List<Task> tasks = [];
  bool isLoading = true;

  int get totalTasks => tasks.length;

  int get completedTasks =>
      tasks.where((task) => task.isComplete).length;

  int get pendingTasks =>
      tasks.where((task) => !task.isComplete).length;

  double get completionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  int get highPriorityTasks => 
      tasks.where((task) => task.priority == 'High').length;
  
  int get mediumPriorityTasks =>
      tasks.where((task) => task.priority == 'Medium').length;

  int get lowPriorityTasks =>
      tasks.where((task) => task.priority == 'Low').length;

  int get personalTasks => 
      tasks.where((task) => task.category == 'Personal').length;

  int get schoolTasks =>
      tasks.where((task) => task.category == 'School').length;

  int get choreTasks =>
      tasks.where((task) => task.category == 'Chore').length;

  int get shoppingTasks =>
      tasks.where((task) => task.category == 'Shopping').length;
  
  @override
  void initState () {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final loadedTasks = await DatabaseService.instance.getTasks();

    if (!mounted) return;

    setState(() {
      tasks = loadedTasks;
      isLoading = false;
    });
  }

  Widget buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: green, size: 25),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: dark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: gray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPriorityRow(String priority, int count){
    Color priorityColor;

    if(priority == 'High') {
      priorityColor = Colors.red;
    } else if(priority == 'Medium') {
      priorityColor = Colors.orange;
    } else {
      priorityColor = green;
    }

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: priorityColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            priority,
            style: const TextStyle(
              fontSize: 14,
              color: dark,
            ),
          ),
        ),
        Text(
          '$count tasks',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: dark,
          )
        )
      ],
    );
  }

  Widget buildCategoryRow(String category, int count) {
    return Row(
      children: [
        Expanded(
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 14,
              color: dark,
            ),
          ),
        ),
        Text(
          '$count tasks',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: dark,
          )
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(
            color: dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: dark),
      ),
      body: isLoading
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
        onRefresh: loadTasks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your productivity',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Here is an overview of your tasks.',
                style: TextStyle(color: gray),
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  buildStatCard(
                    'Total Tasks',
                    '$totalTasks',
                    Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 12),
                  buildStatCard(
                    'Completed', 
                    '$completedTasks', 
                    Icons.task_alt,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  buildStatCard(
                    'Pending',
                    '$pendingTasks',
                    Icons.pending_actions,
                  ),
                  const SizedBox(width: 12),
                  buildStatCard(
                    'Completion Percent', 
                    '${(completionRate * 100).round()}%',
                    Icons.trending_up,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Completion Progress',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: completionRate,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: 
                          const AlwaysStoppedAnimation<Color>(
                              green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$completedTasks out of $totalTasks tasks completed',
                        style: const TextStyle(
                          color: gray,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Priority Breakdown',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: dark,
                        ),
                      ),
                      const SizedBox(height: 18),

                      buildPriorityRow('High', highPriorityTasks),
                      const SizedBox(height: 14),

                      buildPriorityRow('Medium', mediumPriorityTasks),
                      const SizedBox(height: 14),

                      buildPriorityRow('Low', lowPriorityTasks),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category Breakdown',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: dark,
                        ),
                      ),
                      const SizedBox(height: 18),

                      buildCategoryRow('Personal', personalTasks),
                      const SizedBox(height: 14),

                      buildCategoryRow('School', schoolTasks),
                      const SizedBox(height: 14),

                      buildCategoryRow('Chore', choreTasks),
                      const SizedBox(height: 14),

                      buildCategoryRow('Shopping', shoppingTasks),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

    );
  }
}