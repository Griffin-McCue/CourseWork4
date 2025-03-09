import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const AdoptionTravelPlannerApp());
}

class AdoptionTravelPlannerApp extends StatelessWidget {
  const AdoptionTravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adoption & Travel Planner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PlanManagerScreen(),
    );
  }
}


class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });
}

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({super.key});

  @override
  State<PlanManagerScreen> createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  final List<Plan> plans = [];
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adoption & Travel Planner')),
      body: Column(
        children: [
          // Calendar Widget
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
          ),
          Expanded(
            child: plans.isEmpty
                ? const Center(child: Text('No plans yet. Tap + to add a plan!'))
                : ListView(
                    children: _groupPlansByDate().entries.map((entry) {
                      DateTime date = entry.key;
                      List<Plan> dayPlans = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "${date.toLocal()}".split(' ')[0],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...dayPlans.map((plan) => Draggable<Plan>(
                                data: plan,
                                feedback: Material(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(plan.name, style: const TextStyle(color: Colors.white)),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.5,
                                  child: _buildPlanTile(plan),
                                ),
                                child: DragTarget<Plan>(
                                  onAcceptWithDetails: (draggedPlan) {
                                    setState(() {
                                      draggedPlan.date = date;
                                    });
                                  },
                                  builder: (context, candidateData, rejectedData) {
                                    return _buildPlanTile(plan);
                                  },
                                ),
                              ))
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlanDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  
  void _showCreatePlanDialog() {
    String name = '';
    String description = '';
    DateTime selectedDate = _selectedDay;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Plan Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && description.isNotEmpty) {
                  setState(() {
                    plans.add(Plan(name: name, description: description, date: selectedDate));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

 
  Widget _buildPlanTile(Plan plan) {
    return GestureDetector(
      onDoubleTap: () => _deletePlan(plan), 
      child: ListTile(
        title: Text(
          plan.name,
          style: TextStyle(decoration: plan.isCompleted ? TextDecoration.lineThrough : null),
        ),
        subtitle: Text(plan.description),
        trailing: const Icon(Icons.drag_handle),
        onLongPress: () => _editPlan(plan),
      ),
    );
  }

  
  void _editPlan(Plan plan) {
    String updatedName = plan.name;
    String updatedDescription = plan.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: updatedName),
                decoration: const InputDecoration(labelText: 'Plan Name'),
                onChanged: (value) => updatedName = value,
              ),
              TextField(
                controller: TextEditingController(text: updatedDescription),
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => updatedDescription = value,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  plan.name = updatedName;
                  plan.description = updatedDescription;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

 
  void _deletePlan(Plan plan) {
    setState(() {
      plans.remove(plan);
    });
  }

  
  Map<DateTime, List<Plan>> _groupPlansByDate() {
    Map<DateTime, List<Plan>> groupedPlans = {};

    for (var plan in plans) {
      DateTime dateOnly = DateTime(plan.date.year, plan.date.month, plan.date.day);
      if (!groupedPlans.containsKey(dateOnly)) {
        groupedPlans[dateOnly] = [];
      }
      groupedPlans[dateOnly]!.add(plan);
    }

    return groupedPlans;
  }
}