import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'dart:math';

void main() => runApp(ExpenseTrackerApp());

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExpenseTrackerHome(),
    );
  }
}

class ExpenseTrackerHome extends StatefulWidget {
  @override
  _ExpenseTrackerHomeState createState() => _ExpenseTrackerHomeState();
}

class _ExpenseTrackerHomeState extends State<ExpenseTrackerHome> {
  final List<Expense> _userExpenses = [];
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Food'; // For adding new expense
  String _selectedFilterCategory = 'All'; // For filtering expenses
  final List<String> _categories = ['Food', 'Travel', 'Entertainment', 'Other'];
  double _totalExpenses = 0;
  double _maxExpense = 0;
  double _minExpense = 0;
  String _mostFrequentCategory = '';
  double _expenseLimit = 500000; // Example limit

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Finance Tracker'),
      ),
      body: SingleChildScrollView( // Enables scrolling
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildExpenseSummary(),
              _buildExpenseForm(),
              _buildCategoryFilter(),
              _buildExpenseHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseSummary() {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Total Expenses: \$${_totalExpenses.toStringAsFixed(2)}'),
              if (_totalExpenses > _expenseLimit)
                Text(
                  'Expense limit exceeded!',
                  style: TextStyle(color: Colors.red),
                ),
              Text('Max Expense: \$${_maxExpense.toStringAsFixed(2)}'),
              Text('Min Expense: \$${_minExpense.toStringAsFixed(2)}'),
              Text('Most Frequent Category: $_mostFrequentCategory'),
              ElevatedButton(
                onPressed: _clearExpenses,
                child: Text('Clear All Expenses'),
              ),
            ],
        ),
      ),
    );
  }

  Widget _buildExpenseForm() {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Enter The Description of Expense'),
              ),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
              ),
              DropdownButton<String>(
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _addExpense,
                child: Text('Add Expense'),
              ),
            ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
            children: [
              DropdownButton<String>(
                value: _selectedFilterCategory,
                items: ['All', ..._categories].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedFilterCategory = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildExpenseHistory() {
    final filteredExpenses = _selectedFilterCategory == 'All'
        ? _userExpenses
        : _userExpenses
        .where((expense) => expense.category == _selectedFilterCategory)
        .toList();

    return Container(
      height: 300, // Set a fixed height for the expense history section
      child: ListView.builder(
        itemCount: filteredExpenses.length,
        itemBuilder: (context, index) {
          final exp = filteredExpenses[index];
          return ListTile(
            title: Text('${exp.description} - \$${exp.amount.toStringAsFixed(2)}'),
            subtitle: Text('Category: ${exp.category}, Date: ${DateFormat.yMMMd().format(exp.dateTime)}'),
          );
        },
      ),
    );
  }





  void _addExpense() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0 || _descriptionController.text.isEmpty) {
      return;
    }
    final newExpense = Expense(
      description: _descriptionController.text,
      amount: amount,
      dateTime: DateTime.now(),
      category: _selectedCategory,
    );

    setState(() {
      _userExpenses.add(newExpense);
      _calculateStats();
    });

    _amountController.clear();
    _descriptionController.clear();
  }

  void _calculateStats() {
    _totalExpenses = _userExpenses.fold(0, (sum, item) => sum + item.amount);

    if (_userExpenses.isNotEmpty) {
      _maxExpense = _userExpenses.map((e) => e.amount).reduce(max);
      _minExpense = _userExpenses.map((e) => e.amount).reduce(min);
    } else {
      _maxExpense = 0;
      _minExpense = 0;
    }

    _mostFrequentCategory = _findMostFrequentCategory();
  }

  String _findMostFrequentCategory() {
    final categoryCount = <String, int>{};
    for (var expense in _userExpenses) {
      categoryCount.update(expense.category, (count) => count + 1, ifAbsent: () => 1);
    }
    return categoryCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  void _clearExpenses() {
    setState(() {
      _userExpenses.clear();
      _totalExpenses = 0;
      _maxExpense = 0;
      _minExpense = 0;
      _mostFrequentCategory = '';
    });
  }
}

class Expense {
  final String description;
  final double amount;
  final DateTime dateTime;
  final String category;

  Expense({
    required this.description,
    required this.amount,
    required this.dateTime,
    required this.category,
  });
}
