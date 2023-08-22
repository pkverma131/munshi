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
  List<UserTransaction> _transactions = []; // Declare _transactions list
  int _editingTransactionIndex = -1; // Declare _editingTransactionIndex and initialize it with -1

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

    // Check if an existing transaction is being edited
    if (_editingTransaction != null) {
      _editingTransaction!.updateTransaction(newTitle: title, newAmount: amount);

      await DatabaseHelper().updateTransaction(_editingTransaction!);

      setState(() {
        _editingTransaction = null;
        _titleController.clear();
        _amountController.clear();
      });
    } else {
      // If not editing, insert a new transaction
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
      // When returning from EditTransactionScreen, reset the editing index
      setState(() {
        _editingTransactionIndex = -1;
      });

      // Refresh the transactions
      _fetchTransactions();
    });
  }
  void _deleteTransaction(UserTransaction transaction) async {
    await DatabaseHelper().deleteTransaction(transaction.id);

    // Remove the deleted transaction from the list
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
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Expense Manager'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Transactions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildHomeTab(),
            _buildTransactionsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            keyboardType: TextInputType.text, // Specify the keyboard type
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number, // Specify the keyboard type
            decoration: InputDecoration(labelText: 'Amount'),
          ),
          ElevatedButton(
            onPressed: _addTransaction,
            child: Text('Add Transaction'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            child: FutureBuilder<List<UserTransaction>>(
              future: DatabaseHelper().getTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final transactions = snapshot.data!;
                  return ListView.builder(
                    itemCount: transactions.length,
                    reverse: true, // Add this line to reverse the order
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
                  );
                } else {
                  return Text('No transactions found.');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
