import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

import '../modal/items.dart';
import '../service/noti_service.dart';
import '../widget/card_body_widget.dart';
import '../widget/modal_bottom_widget.dart';
import '../storage_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<DataItem> items = [];
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
    final newItem =
        DataItem(id: DateTime.now().toString(), name: name, dateTime: dateTime);
    setState(() {
      items.add(newItem);
      String json = jsonEncode(items.map((user) => user.toJson()).toList());
      StorageManager.saveData('data', json);
    });

    notificationService.scheduleNotificationBefore(
        name, dateTime, 10); // Đặt thông báo 10 phút trước thời gian đã cho
  }

  void _handleDeleteTask(String id) {
    setState(() {
      items.removeWhere((item) => item.id == id);
      String json = jsonEncode(items.map((user) => user.toJson()).toList());
      StorageManager.saveData('data', json);
    });
  }

  void _loadData() async {
    await notificationService.init();
    String json = await StorageManager.loadData('data');
    items.clear();
    if (json.isNotEmpty) {
      items.addAll((jsonDecode(json) as List)
          .map((jsonUser) => DataItem.fromJson(jsonUser))
          .toList());
    }
    setState(() {});
  }

  List<DataItem> getFilteredItems() {
    final now = DateTime.now();
    List<DataItem> filteredItems = items;
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

  Map<String, List<DataItem>> groupItemsByDate(List<DataItem> items) {
    Map<String, List<DataItem>> groupedItems = {};
    for (var item in items) {
      String formattedDate = DateFormat('EEEE, MMM d').format(item.dateTime) + (isSameDay(item.dateTime, DateTime.now()) ? ' - Today' : '');
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
    List<DataItem> filteredItems = getFilteredItems();
    filteredItems.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    Map<String, List<DataItem>> groupedItems = groupItemsByDate(filteredItems);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'To do list',
          style: TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
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
              padding: const EdgeInsets.all(20),
              children: groupedItems.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...entry.value
                        .map((item) => CardBody(
                              index: items.indexOf(item),
                              item: item,
                              deleteTask: _handleDeleteTask,
                            ))
                        ,
                  ],
                );
              }).toList(),
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
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25))),
                builder: (BuildContext content) {
                  return ModalBottom(addTask: _handleAddTask);
                });
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add)),
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
      ),
    );
  }
}
