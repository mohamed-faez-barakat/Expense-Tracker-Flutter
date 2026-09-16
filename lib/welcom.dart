import 'package:flutter/material.dart';
import 'login.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const SizedBox(height: 40),

                // App Icon
                Container(
                  width: 130,
                  height: 130,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 75,
                    color: Colors.teal,
                  ),
                ),

                const SizedBox(height: 35),

                // App Name
                const Text(
                  "Expense Tracker",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                // Short Description
                const Text(
                  "Track your money.\nControl your future.",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 20),

                // App Description
                const Text(
                  "Easily track your income and expenses, "
                      "manage your spending, and understand "
                      "where your money goes.",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 45),

                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    child: const Text(
                      "Get Started",

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Manage your finances smarter 💰",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}