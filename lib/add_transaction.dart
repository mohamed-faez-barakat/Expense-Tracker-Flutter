import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddTransaction extends StatefulWidget {
final Map<String, dynamic>? transaction;

const AddTransaction({
super.key,
this.transaction,
});

@override
State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
final amountController = TextEditingController();
final descriptionController = TextEditingController();

String type = "Expense";
String currency = "JOD";
String category = "Food";

DateTime selectedDate = DateTime.now();

bool isLoading = false;

bool get isEditing => widget.transaction != null;

final supabase = Supabase.instance.client;

@override
void initState() {
super.initState();

if (isEditing) {
final transaction = widget.transaction!;

amountController.text =
transaction['amount']?.toString() ?? '';

descriptionController.text =
transaction['description']?.toString() ?? '';

type = transaction['type']?.toString() ?? 'Expense';

currency =
transaction['currency']?.toString() ?? 'JOD';

category =
transaction['category']?.toString() ?? 'Food';

if (transaction['date'] != null) {
try {
selectedDate = DateTime.parse(
transaction['date'].toString(),
);
} catch (_) {
selectedDate = DateTime.now();
}
}
}
}

// =========================================================
// SAVE TRANSACTION
// =========================================================

Future<void> saveTransaction() async {
final amountText = amountController.text.trim();

if (amountText.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("Please enter the amount"),
),
);
return;
}

final amount = double.tryParse(amountText);

if (amount == null || amount <= 0) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("Please enter a valid amount"),
),
);
return;
}

final user = supabase.auth.currentUser;

if (user == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("User is not logged in"),
),
);
return;
}

setState(() {
isLoading = true;
});

try {
final data = {
'type': type,
'amount': amount,
'currency': currency,
'category': category,
'description': descriptionController.text.trim(),
'date': selectedDate.toIso8601String(),
};

if (isEditing) {
await supabase
    .from('transaction')
    .update(data)
    .eq('id', widget.transaction!['id'])
    .eq('user_id', user.id);
} else {
await supabase.from('transaction').insert({
'user_id': user.id,
...data,
});
}

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
isEditing
? "Transaction updated successfully!"
    : "Transaction added successfully!",
),
),
);

Navigator.pop(context);
} catch (error) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("Error: $error"),
),
);
} finally {
if (mounted) {
setState(() {
isLoading = false;
});
}
}
}

// =========================================================
// SELECT DATE
// =========================================================

Future<void> selectDate() async {
final pickedDate = await showDatePicker(
context: context,
initialDate: selectedDate,
firstDate: DateTime(2020),
lastDate: DateTime(2100),
);

if (pickedDate == null) return;

setState(() {
selectedDate = pickedDate;
});
}

// =========================================================
// DISPOSE
// =========================================================

@override
void dispose() {
amountController.dispose();
descriptionController.dispose();
super.dispose();
}

// =========================================================
// BUILD
// =========================================================

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text(
isEditing
? "Edit Transaction"
    : "Add Transaction",
),
centerTitle: true,
backgroundColor: Colors.teal,
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Transaction Type
const Text(
"Transaction Type",
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

DropdownButtonFormField<String>(
value: type,
decoration: const InputDecoration(
border: OutlineInputBorder(),
),
items: const [
DropdownMenuItem(
value: "Expense",
child: Text("Expense"),
),
DropdownMenuItem(
value: "Income",
child: Text("Income"),
),
],
onChanged: (value) {
if (value == null) return;

setState(() {
type = value;
category =
type == "Income" ? "Salary" : "Food";
});
},
),

const SizedBox(height: 20),

// Amount
const Text(
"Amount",
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

TextField(
controller: amountController,
keyboardType:
const TextInputType.numberWithOptions(
decimal: true,
),
decoration: const InputDecoration(
hintText: "Enter amount",
border: OutlineInputBorder(),
),
),

const SizedBox(height: 20),

// Currency
const Text(
"Currency",
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

DropdownButtonFormField<String>(
value: currency,
decoration: const InputDecoration(
border: OutlineInputBorder(),
),
items: const [
DropdownMenuItem(
value: "JOD",
child: Text("JOD"),
),
DropdownMenuItem(
value: "USD",
child: Text("USD"),
),
DropdownMenuItem(
value: "EUR",
child: Text("EUR"),
),
],
onChanged: (value) {
if (value == null) return;

setState(() {
currency = value;
});
},
),

const SizedBox(height: 20),

// Category
const Text(
"Category",
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

DropdownButtonFormField<String>(
value: category,
decoration: const InputDecoration(
border: OutlineInputBorder(),
),
items: type == "Income"
? const [
DropdownMenuItem(
value: "Salary",
child: Text("Salary"),
),
DropdownMenuItem(
value: "Freelance",
child: Text("Freelance"),
),
DropdownMenuItem(
value: "Investment",
child: Text("Investment"),
),
DropdownMenuItem(
value: "Gift",
child: Text("Gift"),
),
DropdownMenuItem(
value: "Other",
child: Text("Other"),
),
]
    : const [
DropdownMenuItem(
value: "Food",
child: Text("Food"),
),
DropdownMenuItem(
value: "Transport",
child: Text("Transport"),
),
DropdownMenuItem(
value: "Shopping",
child: Text("Shopping"),
),
DropdownMenuItem(
value: "Bills",
child: Text("Bills"),
),
DropdownMenuItem(
value: "Other",
child: Text("Other"),
),
],
onChanged: (value) {
if (value == null) return;

setState(() {
category = value;
});
},
),

const SizedBox(height: 20),

// Description
const Text(
"Description",
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

TextField(
controller: descriptionController,
maxLines: 3,
decoration: const InputDecoration(
hintText: "Enter description",
border: OutlineInputBorder(),
),
),

const SizedBox(height: 20),

// Date
const Text(
"Date",
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

InkWell(
onTap: selectDate,
child: Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
border: Border.all(
color: Colors.grey,
),
borderRadius:
BorderRadius.circular(5),
),
child: Text(
"${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
style: const TextStyle(
fontSize: 16,
),
),
),
),

const SizedBox(height: 30),

// Save Button
SizedBox(
width: double.infinity,
height: 55,
child: ElevatedButton(
onPressed:
isLoading ? null : saveTransaction,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.teal,
foregroundColor: Colors.white,
),
child: isLoading
? const CircularProgressIndicator(
color: Colors.white,
)
    : Text(
isEditing
? "Update Transaction"
    : "Add Transaction",
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
),
),
],
),
),
);
}
}
