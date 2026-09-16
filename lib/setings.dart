import 'package:flutter/material.dart';
import 'package:project/welcom.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
const SettingsPage({super.key});

@override
State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
bool notifications = true;

@override
Widget build(BuildContext context) {
final user = Supabase.instance.client.auth.currentUser;

final fullName = user?.userMetadata?['full_name'] ?? 'User';
final email = user?.email ?? 'No email';

return Scaffold(
appBar: AppBar(
automaticallyImplyLeading: false,
title: const Text('Settings'),
centerTitle: true,
backgroundColor: Colors.teal,
),
body: ListView(
padding: const EdgeInsets.all(20),
children: [
// Profile
const Text(
'Profile',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

Card(
child: ListTile(
leading: const CircleAvatar(
backgroundColor: Colors.teal,
child: Icon(
Icons.person,
color: Colors.white,
),
),
title: Text(
fullName,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
subtitle: Text(email),
),
),

const SizedBox(height: 25),

// Appearance
const Text(
'Appearance',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

// Dark Mode
ValueListenableBuilder<bool>(
valueListenable: isDarkMode,
builder: (context, darkMode, child) {
return Card(
child: SwitchListTile(
secondary: const Icon(
Icons.dark_mode,
color: Colors.teal,
),
title: const Text('Dark Mode'),
subtitle: const Text('Use dark theme'),
value: darkMode,
onChanged: (value) {
isDarkMode.value = value;
},
),
);
},
),

const SizedBox(height: 15),

// Notifications
Card(
child: SwitchListTile(
secondary: const Icon(
Icons.notifications,
color: Colors.teal,
),
title: const Text('Notifications'),
subtitle: const Text('Receive notifications'),
value: notifications,
onChanged: (value) {
setState(() {
notifications = value;
});
},
),
),

const SizedBox(height: 25),

// Account
const Text(
'Account',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

// Change Password
Card(
child: ListTile(
leading: const Icon(
Icons.lock,
color: Colors.teal,
),
title: const Text('Change Password'),
subtitle: const Text('Update your password'),
trailing: const Icon(
Icons.arrow_forward_ios,
size: 18,
),
onTap: () {
final passwordController = TextEditingController();

showDialog(
context: context,
builder: (context) {
return AlertDialog(
title: const Text('Change Password'),
content: TextField(
controller: passwordController,
obscureText: true,
decoration: const InputDecoration(
labelText: 'New Password',
border: OutlineInputBorder(),
),
),
actions: [
TextButton(
onPressed: () {
passwordController.dispose();
Navigator.pop(context);
},
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () async {
final password =
passwordController.text.trim();

if (password.length < 6) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Password must be at least 6 characters',
),
),
);
return;
}

try {
await Supabase.instance.client.auth.updateUser(
UserAttributes(
password: password,
),
);

if (!context.mounted) return;

passwordController.dispose();
Navigator.pop(context);

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Password changed successfully!',
),
),
);
} catch (error) {
if (!context.mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Error: $error'),
),
);
}
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.teal,
foregroundColor: Colors.white,
),
child: const Text('Change'),
),
],
);
},
);
},
),
),

const SizedBox(height: 15),

// About
Card(
child: ListTile(
leading: const Icon(
Icons.info,
color: Colors.teal,
),
title: const Text('About'),
subtitle: const Text('Expense Tracker'),
trailing: const Icon(
Icons.arrow_forward_ios,
size: 18,
),
onTap: () {
showAboutDialog(
context: context,
applicationName: 'Expense Tracker',
applicationVersion: '1.0.0',
applicationIcon: const Icon(
Icons.account_balance_wallet,
color: Colors.teal,
size: 40,
),
children: const [
Text(
'An application for managing and tracking your income and expenses.',
),
],
);
},
),
),

const SizedBox(height: 30),

// Logout
SizedBox(
width: double.infinity,
height: 50,
child: ElevatedButton.icon(
onPressed: () async {
final shouldLogout = await showDialog<bool>(
context: context,
builder: (context) {
return AlertDialog(
title: const Text('Logout'),
content: const Text(
'Are you sure you want to logout?',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(context, false);
},
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
Navigator.pop(context, true);
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
foregroundColor: Colors.white,
),
child: const Text('Logout'),
),
],
);
},
);

if (shouldLogout != true) return;

await Supabase.instance.client.auth.signOut();

if (!mounted) return;

// Go back to Welcome Page
Navigator.of(context).pushAndRemoveUntil(
MaterialPageRoute(
builder: (context) => const WelcomePage(),
),
(route) => false,
);
},
icon: const Icon(Icons.logout),
label: const Text(
'Logout',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
foregroundColor: Colors.white,
),
),
),

const SizedBox(height: 20),
],
),
);
}
}
