import 'package:flutter/material.dart';

import '../modal/items.dart';

class CardBody extends StatelessWidget {
  const CardBody(
      {super.key,
      required this.index,
      required this.item,
      required this.deleteTask});

  final Function? deleteTask;
  final DataItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    bool isChecked = false;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xffDFDFDF),
          ),
          width: double.infinity,
          height: 90,
          child: Padding(
            padding: const EdgeInsets.all(10),
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
                        child: Text(
                          'At ${item.dateTime.toLocal().toString().split(' ')[1].substring(0, 5)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
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
