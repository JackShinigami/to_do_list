import 'package:flutter/material.dart';

class ModalBottom extends StatefulWidget {
  ModalBottom({
    super.key, required this.addTask
  });
  final Function? addTask;

  @override
  _ModalBottomState createState() => _ModalBottomState();
}

class _ModalBottomState extends State<ModalBottom> {
  TextEditingController controller = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // Khởi tạo với ngày giờ hiện tại
  }

  void _handleOnClicked(BuildContext context) {
    if(controller.text.isEmpty) return;
    widget.addTask!(controller.text, selectedDate);
    Navigator.pop(context);
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          color: Colors.white
        ),
        padding: const EdgeInsets.all(20),
        height: 300,
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Your Task'),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => _selectDateTime(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate == null
                        ? 'Select Date & Time'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} ${selectedDate!.hour}:${selectedDate!.minute}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(  
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleOnClicked(context), 
                child: const Text('Add Task')
              ),
            )
          ],
        ),
      ),
    );
  }
}