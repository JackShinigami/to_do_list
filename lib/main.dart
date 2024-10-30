import 'dart:convert';

import 'package:flutter/material.dart';

import 'modal/items.dart';
import 'widget/card_body_widget.dart';
import 'widget/modal_bottom_widget.dart';
import 'storage_manager.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.blue),
      home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<DataItem> items = [];
  int selectedFilter = 0; // 0: All, 1: Today, 2: Upcoming

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
  }

  void _handleDeleteTask(String id) {
    setState(() {
      items.removeWhere((item) => item.id == id);
      String json = jsonEncode(items.map((user) => user.toJson()).toList());
      StorageManager.saveData('data', json);
    });
  }

  void _loadData() async {
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
    if (selectedFilter == 1) {
      return items.where((item) => isSameDay(item.dateTime, now)).toList();
    } else if (selectedFilter == 2) {
      return items.where((item) => item.dateTime.isAfter(now)).toList();
    }
    return items; // All
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: getFilteredItems()
                  .map((item) => CardBody(
                      index: items.indexOf(item),
                      item: item,
                      deleteTask: _handleDeleteTask))
                  .toList(),
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
