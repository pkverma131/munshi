import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user_transaction.dart';
import 'edit_transaction_screen.dart';

void main() {
  runApp(MunshiApp());
}

class MunshiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MunshiAppHome(),
    );
  }
}

class MunshiAppHome extends StatefulWidget {
  @override
  _MunshiAppHomeState createState() => _MunshiAppHomeState();
}

class _MunshiAppHomeState extends State<MunshiAppHome> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  UserTransaction? _editingTransaction;
  List<UserTransaction> _transactions = [];
  int _editingTransactionIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  void _addTransaction() async {
    final String title = _titleController.text;
    final double amount = double.tryParse(_amountController.text) ?? 0;

    if (title.isEmpty || amount <= 0) {
      return;
    }

    if (_editingTransaction != null) {
      _editingTransaction!.updateTransaction(newTitle: title, newAmount: amount);
      await DatabaseHelper().updateTransaction(_editingTransaction!);

      setState(() {
        _editingTransaction = null;
        _titleController.clear();
        _amountController.clear();
      });
    } else {
      final newTransaction = UserTransaction(
        id: DateTime.now().toString(),
        title: title,
        amount: amount,
      );

      await DatabaseHelper().insertTransaction(newTransaction);

      setState(() {
        _transactions.add(newTransaction);
        _titleController.clear();
        _amountController.clear();
      });
    }
  }

  void _editTransaction(UserTransaction transaction, int index) {
    setState(() {
      _editingTransactionIndex = index;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    ).then((_) {
      setState(() {
        _editingTransactionIndex = -1;
      });

      _fetchTransactions();
    });
  }

  void _deleteTransaction(UserTransaction transaction) async {
    await DatabaseHelper().deleteTransaction(transaction.id);

    setState(() {
      _transactions.remove(transaction);
    });
  }

  void _fetchTransactions() async {
    final transactions = await DatabaseHelper().getTransactions();
    setState(() {
      _transactions = transactions;
    });
  }

  void _saveEditedTransaction() async {
    if (_editingTransaction == null) {
      return;
    }

    final String newTitle = _titleController.text;
    final double newAmount = double.tryParse(_amountController.text) ?? 0;

    if (newTitle.isEmpty || newAmount <= 0) {
      return;
    }

    _editingTransaction!.updateTransaction(newTitle: newTitle, newAmount: newAmount);
    await DatabaseHelper().updateTransaction(_editingTransaction!);

    setState(() {
      _editingTransaction = null;
      _titleController.clear();
      _amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Manager'),
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
                onPressed: () {
                  if (_editingTransaction != null) {
                    _saveEditedTransaction();
                  } else {
                    _addTransaction();
                  }
                },
                child: Text(_editingTransaction != null ? 'Save Transaction' : 'Add Transaction'),
              ),
              SizedBox(height: 16),
              FutureBuilder<double>(
                future: DatabaseHelper().calculateTotalAmount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final totalAmount = snapshot.data ?? 0.0;
                    return Text(
                      'Total: ₹${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    );
                  }
                },
              ),
              SizedBox(height: 16),
              Expanded(
              child: ListView.builder(
              itemCount: _transactions.length,
              reverse: true,
              itemBuilder: (ctx, index) {
              final transaction = _transactions[index];
              return ListTile(
                    title: Text(transaction.title),
                    subtitle: Text('₹${transaction.amount.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editTransaction(transaction, index),
                        ),
                        IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteTransaction(transaction),
                          ),
                        ],
                      ),
                    );
                  },
                )
              ),
            ],
          ),
        ),
    );
  }
}
