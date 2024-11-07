import 'package:flutter/material.dart';

import '../modal/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.index,
    required this.item,
    required this.deleteTask,
  });

  final Function? deleteTask;
  final Task item;
  final int index;

  @override
  Widget build(BuildContext context) {
    bool isChecked = false;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          width: double.infinity,
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'At ${item.dateTime.toLocal().toString().split(' ')[1].substring(0, 5)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) async {
                        if (value == true) {
                          setState(() {
                            isChecked = true;
                          });
                          await Future.delayed(const Duration(seconds: 1));
                          deleteTask!(item.id);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
