import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

import '../modal/task.dart';
import '../services/noti_service.dart';
import 'task_card.dart';
import 'modal_bottom_widget.dart';
import '../services/storage_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];
  final TextEditingController searchController = TextEditingController();
  final notificationService = NotificationService();
  int selectedFilter = 0; // 0: All, 1: Today, 2: Upcoming
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _handleAddTask(String name, DateTime dateTime) {
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final newItem = Task(
      id: DateTime.now().toString(),
      name: name,
      dateTime: dateTime,
      notificationId: notificationId,
    );
    setState(() {
      tasks.add(newItem);
      String json = jsonEncode(tasks.map((item) => item.toJson()).toList());
      StorageManager.saveData('data', json);
    });
    notificationService.scheduleNotificationBefore(notificationId, name,
        dateTime, 10); // Schedule notification 10 minutes before
  }

  void _handleDeleteTask(String id) {
    setState(() {
      final item = tasks.firstWhere((item) => item.id == id);
      tasks.removeWhere((item) => item.id == id);
      String json = jsonEncode(tasks.map((item) => item.toJson()).toList());
      StorageManager.saveData('data', json);
      notificationService.cancelNotification(item.notificationId);
    });
  }

  void _loadData() async {
    await notificationService.init();
    String json = await StorageManager.loadData('data');
    tasks.clear();
    if (json.isNotEmpty) {
      tasks.addAll((jsonDecode(json) as List)
          .map((jsonUser) => Task.fromJson(jsonUser))
          .toList());
    }
    setState(() {});
  }

  List<Task> getFilteredItems() {
    final now = DateTime.now();
    List<Task> filteredItems = tasks;
    if (selectedFilter == 1) {
      filteredItems =
          filteredItems.where((item) => isSameDay(item.dateTime, now)).toList();
    } else if (selectedFilter == 2) {
      filteredItems =
          filteredItems.where((item) => item.dateTime.isAfter(now)).toList();
    }
    if (searchQuery.isNotEmpty) {
      filteredItems = filteredItems
          .where((item) =>
              item.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return filteredItems;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Map<String, List<Task>> groupItemsByDate(List<Task> items) {
    Map<String, List<Task>> groupedItems = {};
    for (var item in items) {
      String formattedDate = DateFormat('EEEE, MMM d').format(item.dateTime) +
          (isSameDay(item.dateTime, DateTime.now()) ? ' - Today' : '');
      if (groupedItems.containsKey(formattedDate)) {
        groupedItems[formattedDate]!.add(item);
      } else {
        groupedItems[formattedDate] = [item];
      }
    }
    return groupedItems;
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredItems = getFilteredItems();
    filteredItems.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    Map<String, List<Task>> groupedItems = groupItemsByDate(filteredItems);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'To Do List',
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                suffixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ...groupedItems.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10).copyWith(left: 15),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                        ),
                      ...entry.value
                          .map((item) => TaskCard(
                                index: tasks.indexOf(item),
                                item: item,
                                deleteTask: _handleDeleteTask,
                              )),
                    ],
                  );
                }),
                const SizedBox(
                    height:
                        80), // Add a SizedBox at the end to avoid FAB overlap
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (BuildContext content) {
              return ModalBottom(addTask: _handleAddTask);
            },
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedFilter,
        onTap: (index) {
          setState(() {
            selectedFilter = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upcoming),
            label: 'Upcoming',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
