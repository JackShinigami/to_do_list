import 'package:flutter/material.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

import '../modal/items.dart';

// ignore: must_be_immutable
class CardBody extends StatelessWidget {
  CardBody({super.key, required this.index, required this.item, required this.deleteTask});

  final Function? deleteTask;
  final DataItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: index % 2 == 0 ? const Color(0xffDFDFDF) : Colors.lightBlueAccent,
          ),
          width: double.infinity,
          height: 90,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  item.name,
                  style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Date: ${item.dateTime.toLocal()}',
                  style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  ),
                ),
                ],
              ),
              InkWell(
                onTap: () async {
                if (await confirm(context)) {
                  return deleteTask!(item.id);
                }
                return;
                },
                child: const Icon(
                Icons.delete,
                color: Colors.black,
                size: 30,
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }
}
