import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_transaction.dart';
import 'transaction.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double totalIncome = 0;
  double totalExpenses = 0;
  double totalBalance = 0;

  List<Map<String, dynamic>> recentTransactions = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('transaction')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false);

      final allTransactions =
      List<Map<String, dynamic>>.from(data);

      double income = 0;
      double expenses = 0;

      for (final transaction in allTransactions) {
        final amount =
            double.tryParse(
              transaction['amount'].toString(),
            ) ??
                0;

        final type =
            transaction['type']
                ?.toString()
                .toLowerCase() ??
                "";

        if (type == "income") {
          income += amount;
        } else if (type == "expense") {
          expenses += amount;
        }
      }

      if (!mounted) return;

      setState(() {
        totalIncome = income;
        totalExpenses = expenses;
        totalBalance = income - expenses;
        recentTransactions = allTransactions.take(5).toList();
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
            "Error loading data: $error",
          ),
        ),
      );
    }
  }

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

      default:
        return Icons.category;
    }
  }

  String formatDate(dynamic value) {
    if (value == null) {
      return "";
    }

    try {
      final date = DateTime.parse(
        value.toString(),
      );

      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        Supabase.instance.client.auth.currentUser;

    final fullName =
        user?.userMetadata?['full_name'] ?? 'User';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Expense Tracker"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: loadHomeData,
        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                // Welcome
                Text(
                  "Welcome, $fullName!",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Total Balance
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(20),
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
                        "Total Balance",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "${totalBalance.toStringAsFixed(2)} JOD",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Income & Expenses
                Row(
                  children: [

                    // Expenses
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

                              const Text("Expenses"),

                              const SizedBox(height: 5),

                              Text(
                                "${totalExpenses.toStringAsFixed(2)} JOD",
                                style:
                                const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Income
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding:
                          const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.arrow_upward,
                                color: Colors.green,
                              ),

                              const SizedBox(height: 5),

                              const Text("Income"),

                              const SizedBox(height: 5),

                              Text(
                                "${totalIncome.toStringAsFixed(2)} JOD",
                                style:
                                const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight.bold,
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

                // Recent Transactions
                const Text(
                  "Recent Transactions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                if (recentTransactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "No transactions yet",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else
                  ...recentTransactions.map(
                        (transaction) {
                      final category =
                          transaction['category']
                              ?.toString() ??
                              "Other";

                      final type =
                          transaction['type']
                              ?.toString() ??
                              "Expense";

                      final amount =
                          double.tryParse(
                            transaction['amount']
                                .toString(),
                          ) ??
                              0;

                      final currency =
                          transaction['currency']
                              ?.toString() ??
                              "JOD";

                      final isIncome =
                          type.toLowerCase() ==
                              "income";

                      return ListTile(
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
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          "${formatDate(transaction['date'])} • $type",
                        ),

                        trailing: Text(
                          "${isIncome ? '+' : '-'}${amount.toStringAsFixed(2)} $currency",
                          style: TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            color: isIncome
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 15),

                // View All Transactions
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const TransactionsPage(),
                        ),
                      );

                      await loadHomeData();
                    },

                    icon: const Icon(Icons.list),

                    label: const Text(
                      "View All Transactions",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),

      // Add Transaction
      floatingActionButton: SizedBox(
        width: 180,
        height: 55,
        child: FloatingActionButton.extended(
          backgroundColor: Colors.teal,
          icon: const Icon(Icons.add),

          label: const Text(
            "Add Transaction",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddTransaction(),
              ),
            );

            await loadHomeData();
          },
        ),
      ),
    );
  }
}