import 'package:flutter/material.dart';
import 'login.dart';

class VerifyEmail extends StatelessWidget {
const VerifyEmail({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text("Verify Email"),
centerTitle: true,
backgroundColor: Colors.teal,
),

body: Center(
child: Padding(
padding: const EdgeInsets.all(30),

child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(
Icons.mark_email_unread,
size: 90,
color: Colors.teal,
),

const SizedBox(height: 25),

const Text(
"Check Your Email",
style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

const Text(
"Your account has been created successfully.\n\n"
"We sent a verification link to your email.\n"
"Please verify your email before logging in.",
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 16,
),
),

const SizedBox(height: 30),

SizedBox(
width: double.infinity,
height: 50,

child: ElevatedButton(
onPressed: () {
Navigator.pushAndRemoveUntil(
context,

MaterialPageRoute(
builder: (context) => const Login(),
),

(route) => false,
);
},

style: ElevatedButton.styleFrom(
backgroundColor: Colors.teal,
foregroundColor: Colors.white,
),

child: const Text(
"Back to Login",
style: TextStyle(
fontSize: 18,
),
),
),
),
],
),
),
),
);
}
}
