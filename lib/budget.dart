import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetPage extends StatefulWidget {
const BudgetPage({super.key});

@override
State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
final budgetController = TextEditingController();

double budget = 0;
double spent = 0;

bool isLoading = true;
bool isSaving = false;

@override
void initState() {
super.initState();
loadBudget();
}

// =========================================================
// LOAD BUDGET
// =========================================================

Future<void> loadBudget() async {
final user = Supabase.instance.client.auth.currentUser;

if (user == null) {
setState(() {
isLoading = false;
});
return;
}

try {
// Get current month
final now = DateTime.now();

final month = DateTime(
now.year,
now.month,
1,
);

// Get budget
final budgetData = await Supabase.instance.client
    .from('budget')
    .select()
    .eq('user_id', user.id)
    .eq(
'month',
'${month.year}-${month.month.toString().padLeft(2, '0')}-01',
)
    .maybeSingle();

// Get this month's expenses
final startDate =
'${now.year}-${now.month.toString().padLeft(2, '0')}-01';

final nextMonth = DateTime(
now.year,
now.month + 1,
1,
);

final endDate =
'${nextMonth.year}-${nextMonth.month.toString().padLeft(2, '0')}-01';

final transactions = await Supabase.instance.client
    .from('transaction')
    .select()
    .eq('user_id', user.id)
    .eq('type', 'Expense')
    .gte('date', startDate)
    .lt('date', endDate);

double totalSpent = 0;

for (final transaction in transactions) {
totalSpent +=
double.tryParse(
transaction['amount'].toString(),
) ??
0;
}

if (!mounted) return;

setState(() {
budget = budgetData == null
? 0
    : double.tryParse(
budgetData['amount'].toString(),
) ??
0;

spent = totalSpent;

budgetController.text =
budget == 0 ? '' : budget.toString();

isLoading = false;
});
} catch (error) {
if (!mounted) return;

setState(() {
isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Error loading budget: $error',
),
),
);
}
}

// =========================================================
// SAVE BUDGET
// =========================================================

Future<void> saveBudget() async {
final user = Supabase.instance.client.auth.currentUser;

if (user == null) {
return;
}

final amount = double.tryParse(
budgetController.text.trim(),
);

if (amount == null || amount <= 0) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Please enter a valid budget',
),
),
);
return;
}

setState(() {
isSaving = true;
});

try {
final now = DateTime.now();

final month = DateTime(
now.year,
now.month,
1,
);

final monthString =
'${month.year}-${month.month.toString().padLeft(2, '0')}-01';

// Check if budget already exists
final existing = await Supabase.instance.client
    .from('budget')
    .select('id')
    .eq('user_id', user.id)
    .eq('month', monthString)
    .maybeSingle();

if (existing == null) {
await Supabase.instance.client
    .from('budget')
    .insert({
'user_id': user.id,
'amount': amount,
'month': monthString,
});
} else {
await Supabase.instance.client
    .from('budget')
    .update({
'amount': amount,
})
    .eq('id', existing['id']);
}

if (!mounted) return;

setState(() {
budget = amount;
isSaving = false;
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Budget saved successfully!',
),
),
);

await loadBudget();
} catch (error) {
if (!mounted) return;

setState(() {
isSaving = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Error saving budget: $error',
),
),
);
}
}

// =========================================================
// CALCULATIONS
// =========================================================

double get remaining {
return budget - spent;
}

double get progress {
if (budget <= 0) {
return 0;
}

final value = spent / budget;

if (value > 1) {
return 1;
}

return value;
}

@override
void dispose() {
budgetController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final now = DateTime.now();

final monthName = [
'January',
'February',
'March',
'April',
'May',
'June',
'July',
'August',
'September',
'October',
'November',
'December',
][now.month - 1];

return Scaffold(
appBar: AppBar(
automaticallyImplyLeading: false,
title: const Text('Monthly Budget'),
centerTitle: true,
backgroundColor: Colors.teal,
),
body: isLoading
? const Center(
child: CircularProgressIndicator(),
)
    : RefreshIndicator(
onRefresh: loadBudget,
child: SingleChildScrollView(
physics:
const AlwaysScrollableScrollPhysics(),
child: Padding(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'$monthName ${now.year}',
style: const TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

const Text(
'Set and monitor your monthly spending budget.',
style: TextStyle(
fontSize: 16,
color: Colors.grey,
),
),

const SizedBox(height: 25),

// Budget Input
TextField(
controller: budgetController,
keyboardType:
const TextInputType.numberWithOptions(
decimal: true,
),
decoration: InputDecoration(
labelText: 'Monthly Budget',
hintText: 'Example: 500',
prefixIcon: const Icon(
Icons.account_balance_wallet,
),
suffixText: 'JOD',
border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(12),
),
),
),

const SizedBox(height: 15),

// Save Button
SizedBox(
width: double.infinity,
height: 50,
child: ElevatedButton(
onPressed:
isSaving ? null : saveBudget,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.teal,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(12),
),
),
child: isSaving
? const CircularProgressIndicator(
color: Colors.white,
)
    : const Text(
'Save Budget',
style: TextStyle(
fontSize: 17,
fontWeight:
FontWeight.bold,
),
),
),
),

const SizedBox(height: 30),

// Budget Card
Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.teal,
borderRadius:
BorderRadius.circular(15),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Monthly Budget',
style: TextStyle(
color: Colors.white,
fontSize: 16,
),
),

const SizedBox(height: 8),

Text(
'${budget.toStringAsFixed(2)} JOD',
style: const TextStyle(
color: Colors.white,
fontSize: 28,
fontWeight: FontWeight.bold,
),
),
],
),
),

const SizedBox(height: 20),

// Spent / Remaining
Row(
children: [
Expanded(
child: Card(
child: Padding(
padding:
const EdgeInsets.all(15),
child: Column(
children: [
const Icon(
Icons.arrow_downward,
color: Colors.red,
),

const SizedBox(height: 5),

const Text('Spent'),

const SizedBox(height: 5),

Text(
'${spent.toStringAsFixed(2)} JOD',
style:
const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),
],
),
),
),
),

Expanded(
child: Card(
child: Padding(
padding:
const EdgeInsets.all(15),
child: Column(
children: [
const Icon(
Icons
    .account_balance_wallet,
color: Colors.green,
),

const SizedBox(height: 5),

const Text('Remaining'),

const SizedBox(height: 5),

Text(
'${remaining.toStringAsFixed(2)} JOD',
style: TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
color: remaining < 0
? Colors.red
    : Colors.green,
),
),
],
),
),
),
),
],
),

const SizedBox(height: 25),

// Progress
const Text(
'Spending Progress',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 12),

LinearProgressIndicator(
value: progress,
minHeight: 12,
borderRadius:
BorderRadius.circular(10),
backgroundColor:
Colors.grey.shade300,
color: spent > budget
? Colors.red
    : Colors.teal,
),

const SizedBox(height: 10),

Text(
'${(progress * 100).toStringAsFixed(1)}% of your budget used',
style: const TextStyle(
color: Colors.grey,
),
),
],
),
),
),
),
);
}
}
