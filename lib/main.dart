import 'package:flutter/material.dart';
import 'widgets/home_screen.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.blue),
      home: const HomeScreen()));
}

