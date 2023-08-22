import 'package:flutter/material.dart';
import 'user_transaction.dart';
import 'database_helper.dart';

class EditTransactionScreen extends StatefulWidget {
  final UserTransaction transaction;

  EditTransactionScreen({required this.transaction});

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.transaction.title;
    _amountController.text = widget.transaction.amount.toString();
  }

  void _saveEditedTransaction() async {
    final String newTitle = _titleController.text;
    final double newAmount = double.tryParse(_amountController.text) ?? 0;

    if (newTitle.isEmpty || newAmount <= 0) {
      return;
    }

    widget.transaction.updateTransaction(newTitle: newTitle, newAmount: newAmount);
    await DatabaseHelper().updateTransaction(widget.transaction);

    Navigator.pop(context); // Navigate back to the previous screen (Transactions tab)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            ElevatedButton(
              onPressed: _saveEditedTransaction,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
