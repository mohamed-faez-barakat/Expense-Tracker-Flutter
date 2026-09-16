import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  bool isLoading = true;

  Map<String, double> expensesByCategory = {};

  double totalExpenses = 0;

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('transaction')
          .select()
          .eq('user_id', user.id)
          .eq('type', 'Expense');

      Map<String, double> categories = {};

      double total = 0;

      for (final transaction in data) {
        final category =
            transaction['category']?.toString() ?? 'Other';

        final amount =
            double.tryParse(
              transaction['amount'].toString(),
            ) ??
                0;

        total += amount;

        categories[category] =
            (categories[category] ?? 0) + amount;
      }

      if (!mounted) return;

      setState(() {
        expensesByCategory = categories;
        totalExpenses = total;
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
            "Error loading expenses: $error",
          ),
        ),
      );
    }
  }

  List<PieChartSectionData> getSections() {
    if (expensesByCategory.isEmpty) {
      return [];
    }

    final categories =
    expensesByCategory.entries.toList();

    return List.generate(
      categories.length,
          (index) {
        final category = categories[index];

        final percentage = totalExpenses == 0
            ? 0
            : (category.value / totalExpenses) * 100;

        return PieChartSectionData(
          value: category.value,
          title:
          "${percentage.toStringAsFixed(0)}%",
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      },
    );
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;

      case 'Transport':
        return Icons.directions_bus;

      case 'Shopping':
        return Icons.shopping_bag;

      case 'Bills':
        return Icons.receipt_long;

      case 'Entertainment':
        return Icons.movie;

      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: loadExpenses,
        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                const Text(
                  "Expense Statistics",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "See where your money goes",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 25),

                // Total Expenses Card
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
                        "Total Expenses",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "${totalExpenses.toStringAsFixed(2)} JOD",
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

                const SizedBox(height: 30),

                // Chart
                if (expensesByCategory.isEmpty)
                  const Center(
                    child: Padding(
                      padding:
                      EdgeInsets.all(30),
                      child: Text(
                        "No expenses yet.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else ...[
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections:
                        getSections(),
                        centerSpaceRadius: 50,
                        sectionsSpace: 3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Expenses by Category",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  ...expensesByCategory.entries.map(
                        (entry) {
                      final percentage =
                      totalExpenses == 0
                          ? 0
                          : (entry.value /
                          totalExpenses) *
                          100;

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              getCategoryIcon(
                                entry.key,
                              ),
                            ),
                          ),

                          title: Text(
                            entry.key,
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            "${percentage.toStringAsFixed(1)}% of expenses",
                          ),

                          trailing: Text(
                            "${entry.value.toStringAsFixed(2)} JOD",
                            style:
                            const TextStyle(
                              color: Colors.red,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}