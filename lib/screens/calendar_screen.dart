import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/database_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const Color green = Color(0xFF20A879);
  static const Color dark = Color(0xFF252525);
  static const Color gray = Color(0xFF888888);

  List<Task> tasks = [];
  bool isLoading = true;

  DateTime selectedDate = DateTime.now();
  DateTime displayedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  @override
  void initState(){
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    try{
      final loadedTasks = await DatabaseService.instance.getTasks();

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
        SnackBar(content: Text('unable to load tasks: $e')),
        );
    }
  }

  bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year && 
        first.month == second.month &&
        first.day == second.day;
  }

  List<Task> get selectedDateTasks {
    return tasks.where((task) {
      if(task.dueDate == null) return false;

      return isSameDay(task.dueDate!, selectedDate);
    }).toList();
  }

  bool hasTasks(DateTime date) {
    return tasks.any((task) {
      if(task.dueDate == null) return false;

      return isSameDay(task.dueDate!, date);
    });
  }

  void changeMonth(int amount) {
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month + amount,
      );
    });
  }

  String get monthName {
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

    return '${months[displayedMonth.month - 1]} ${displayedMonth.year}';
  }

  String get selectedDateLabel {
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

      return '${months[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}';
  }

  Widget buildCalendar() {
    final firstDay = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    ).day;

    final startingWeekday = firstDay.weekday - 1;

    final totalCells = 
    ((startingWeekday + daysInMonth + 6) ~/ 7) * 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            'Mon',
            'Tue',
            'Wed',
            'Thu',
            'Fri',
            'Sat',
            'Sun',
          ].map((day) {
            return SizedBox(
              width: 38,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: gray,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 15),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: 
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 10,
          crossAxisSpacing: 4,
          childAspectRatio: 0.85,
          ),

          itemBuilder: (context, index) {
            final day = index - startingWeekday + 1;

            if(day < 1 || day > daysInMonth){
              return const SizedBox();
            }

            final date = DateTime(
              displayedMonth.year,
              displayedMonth.month,
              day,
            );

            final isSelected = isSameDay(date, selectedDate);
            final isToday = isSameDay(date, DateTime.now());
            final hasDueTasks = hasTasks(date);

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate = date;
                });
              },

              child: Column(
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? green : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                        ? Border.all(color: green)
                        : null,
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.white : dark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Container(
                    height: 5,
                    width: 5,
                    decoration: BoxDecoration(
                      color: hasDueTasks
                        ? green
                        : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ]
    );
  }

  Widget taskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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

          const  SizedBox(width: 12),

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
              ],
            )
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9F8),
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: dark),
      ),

      body: isLoading
        ? const Center(
          child: CircularProgressIndicator(color: green),
        )
        : SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: dark,
                    ),
                  ),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () => changeMonth(-1), 
                        icon: const Icon(
                          Icons.chevron_left,
                          color: dark,
                          ),
                        ),
                      
                      IconButton(
                        onPressed: () => changeMonth(1),
                        icon: const Icon(
                          Icons.chevron_right,
                          color: dark 
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: buildCalendar(),
              ),

              const SizedBox(height: 30),

              Text(
                selectedDateLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),

              const SizedBox(height: 18),

                  if (selectedDateTasks.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25),
                        child: Text(
                          'No tasks scheduled for this date.',
                          style: TextStyle(
                            color: gray,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ...selectedDateTasks.map(taskCard),
                ],
              ),
            ),
    );
  }
}