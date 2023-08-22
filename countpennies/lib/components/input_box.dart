import 'package:flutter/material.dart';

class InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  InputBox({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Expanded(
          flex: 3, // Set the horizontal flex value for the TextField
          child: TextField(
            controller: controller,
            decoration: InputDecoration.collapsed(hintText: label),
          ),
        ),
      ),
    );
  }
}
