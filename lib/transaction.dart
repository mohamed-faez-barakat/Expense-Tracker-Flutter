import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_transaction.dart';

class TransactionsPage extends StatefulWidget {
const TransactionsPage({super.key});

@override
State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
final supabase = Supabase.instance.client;

List<Map<String, dynamic>> transactions = [];
bool isLoading = true;

@override
void initState() {
super.initState();
loadTransactions();
}

// Load transactions
Future<void> loadTransactions() async {
final user = supabase.auth.currentUser;

if (user == null) {
if (!mounted) return;

setState(() {
isLoading = false;
});

return;
}

try {
final data = await supabase
    .from('transaction')
    .select()
    .eq('user_id', user.id)
    .order('date', ascending: false);

if (!mounted) return;

setState(() {
transactions = List<Map<String, dynamic>>.from(data);
isLoading = false;
});
} catch (error) {
if (!mounted) return;

setState(() {
isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("Error loading transactions: $error"),
),
);
}
}

// Edit transaction
Future<void> editTransaction(
Map<String, dynamic> transaction,
) async {
await Navigator.push(
context,
MaterialPageRoute(
builder: (context) => AddTransaction(
transaction: transaction,
),
),
);

await loadTransactions();
}

// Delete transaction
Future<void> deleteTransaction(
Map<String, dynamic> transaction,
) async {
final user = supabase.auth.currentUser;

if (user == null) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("User is not logged in"),
),
);

return;
}

final id = transaction['id'];

if (id == null) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("Transaction ID is missing"),
),
);

return;
}

final confirm = await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text("Delete Transaction"),
content: const Text(
"Are you sure you want to delete this transaction?",
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext, false);
},
child: const Text("Cancel"),
),
ElevatedButton(
onPressed: () {
Navigator.pop(dialogContext, true);
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
foregroundColor: Colors.white,
),
child: const Text("Delete"),
),
],
);
},
);

if (confirm != true) {
return;
}

try {
await supabase
    .from('transaction')
    .delete()
    .eq('id', id)
    .eq('user_id', user.id);

if (!mounted) return;

setState(() {
transactions.removeWhere(
(item) => item['id'] == id,
);
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Transaction deleted successfully!",
),
),
);

await loadTransactions();
} catch (error) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
"Delete error: $error",
),
),
);
}
}

// Category icons
IconData getCategoryIcon(String category) {
switch (category.toLowerCase()) {
case "food":
return Icons.restaurant;

case "transport":
return Icons.directions_bus;

case "shopping":
return Icons.shopping_bag;

case "bills":
return Icons.receipt_long;

case "entertainment":
return Icons.movie;

case "health":
return Icons.health_and_safety;

case "education":
return Icons.school;

case "salary":
return Icons.account_balance_wallet;

case "freelance":
return Icons.work;

case "investment":
return Icons.trending_up;

case "gift":
return Icons.card_giftcard;

case "other":
return Icons.category;

default:
return Icons.category;
}
}

// Format date
String formatDate(dynamic value) {
if (value == null) {
return "";
}

try {
final date = DateTime.parse(value.toString());

return "${date.day}/${date.month}/${date.year}";
} catch (_) {
return value.toString();
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text("Transactions"),
centerTitle: true,
backgroundColor: Colors.teal,
),
body: _buildBody(),
);
}

Widget _buildBody() {
if (isLoading) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (transactions.isEmpty) {
return RefreshIndicator(
onRefresh: loadTransactions,
child: ListView(
children: const [
SizedBox(height: 200),
Center(
child: Text(
"No transactions yet",
style: TextStyle(
fontSize: 18,
color: Colors.grey,
),
),
),
],
),
);
}

return RefreshIndicator(
onRefresh: loadTransactions,
child: ListView.builder(
padding: const EdgeInsets.all(12),
itemCount: transactions.length,
itemBuilder: (context, index) {
return _buildTransactionCard(
transactions[index],
);
},
),
);
}

Widget _buildTransactionCard(
Map<String, dynamic> transaction,
) {
final category =
transaction['category']?.toString() ?? "Other";

final type =
transaction['type']?.toString() ?? "Expense";

final amount =
double.tryParse(
transaction['amount']?.toString() ?? "0",
) ??
0;

final currency =
transaction['currency']?.toString() ?? "JOD";

final description =
transaction['description']?.toString() ?? "";

final isIncome = type.toLowerCase() == "income";

return Card(
margin: const EdgeInsets.only(bottom: 10),
child: ListTile(
contentPadding: const EdgeInsets.all(10),

leading: CircleAvatar(
backgroundColor: isIncome
? Colors.green.shade100
    : Colors.red.shade100,
child: Icon(
getCategoryIcon(category),
color: isIncome
? Colors.green
    : Colors.red,
),
),

title: Text(
category,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),

subtitle: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
"${formatDate(transaction['date'])} • $type",
),
if (description.isNotEmpty)
Text(description),
],
),

trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
Text(
"${isIncome ? '+' : '-'}"
"${amount.toStringAsFixed(2)} "
"$currency",
style: TextStyle(
fontWeight: FontWeight.bold,
color: isIncome
? Colors.green
    : Colors.red,
),
),

IconButton(
tooltip: "Edit",
icon: const Icon(
Icons.edit,
color: Colors.blue,
),
onPressed: () {
editTransaction(transaction);
},
),

IconButton(
tooltip: "Delete",
icon: const Icon(
Icons.delete,
color: Colors.red,
),
onPressed: () {
deleteTransaction(transaction);
},
),
],
),
),
);
}
}
