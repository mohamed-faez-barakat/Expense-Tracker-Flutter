import 'package:flutter/material.dart';
import 'budget.dart';
import 'chart.dart';
import 'currencies.dart';
import 'home.dart';
import 'setings.dart';

class MainNavigation extends StatefulWidget {
const MainNavigation({super.key});

@override
State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
int currentIndex = 0;

int statisticsKey = 0;
int budgetKey = 0;

@override
Widget build(BuildContext context) {
final List<Widget> pages = [
const Home(),

// Statistics
Statistics(
key: ValueKey(statisticsKey),
),

// Budget
BudgetPage(
key: ValueKey(budgetKey),
),

// Currencies
const CurrenciesPage(),

// Settings
const SettingsPage(),
];

return Scaffold(
body: IndexedStack(
index: currentIndex,
children: pages,
),
bottomNavigationBar: BottomNavigationBar(
currentIndex: currentIndex,
onTap: (index) {
setState(() {
currentIndex = index;

// Refresh Statistics
if (index == 1) {
statisticsKey++;
}

// Refresh Budget
if (index == 2) {
budgetKey++;
}
});
},
type: BottomNavigationBarType.fixed,
selectedItemColor: Colors.teal,
unselectedItemColor: Colors.grey,
items: const [
BottomNavigationBarItem(
icon: Icon(Icons.home),
label: 'Home',
),
BottomNavigationBarItem(
icon: Icon(Icons.bar_chart),
label: 'Statistics',
),
BottomNavigationBarItem(
icon: Icon(Icons.account_balance_wallet),
label: 'Budget',
),
BottomNavigationBarItem(
icon: Icon(Icons.currency_exchange),
label: 'Currencies',
),
BottomNavigationBarItem(
icon: Icon(Icons.settings),
label: 'Settings',
),
],
),
);
}
}
