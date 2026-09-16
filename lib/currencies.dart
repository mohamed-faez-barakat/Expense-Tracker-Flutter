import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrenciesPage extends StatefulWidget {
  const CurrenciesPage({super.key});

  @override
  State<CurrenciesPage> createState() => _CurrenciesPageState();
}

class _CurrenciesPageState extends State<CurrenciesPage> {
  final amountController = TextEditingController();

  final List<String> currencies = [
    'JOD',
    'USD',
    'EUR',
    'GBP',
    'SAR',
    'AED',
    'EGP',
    'JPY',
  ];

  String fromCurrency = 'JOD';
  String toCurrency = 'USD';

  String result = '';
  bool isLoading = false;

  Future<void> convertCurrency() async {
    final amountText = amountController.text.trim();

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an amount"),
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);

    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid amount"),
        ),
      );
      return;
    }

    if (fromCurrency == toCurrency) {
      setState(() {
        result =
        "${amount.toStringAsFixed(2)} $toCurrency";
      });
      return;
    }

    setState(() {
      isLoading = true;
      result = '';
    });

    try {
      final url = Uri.parse(
        'https://api.frankfurter.dev/v2/rate/'
            '$fromCurrency/$toCurrency',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
          "Failed to get exchange rate",
        );
      }

      final data = jsonDecode(response.body);

      final rate =
      (data['rate'] as num).toDouble();

      final convertedAmount = amount * rate;

      if (!mounted) return;

      setState(() {
        result =
        "${convertedAmount.toStringAsFixed(2)} $toCurrency";
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
            "Error getting exchange rate: $error",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Currency Converter"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              const Text(
                "Currency Converter",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Convert between different currencies",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 30),

              // Amount
              TextField(
                controller: amountController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Amount",
                  hintText: "Enter amount",
                  prefixIcon:
                  const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // From
              DropdownButtonFormField<String>(
                value: fromCurrency,
                decoration: InputDecoration(
                  labelText: "From",
                  prefixIcon:
                  const Icon(Icons.money),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
                items: currencies.map(
                      (currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    fromCurrency = value;
                  });
                },
              ),

              const SizedBox(height: 15),

              // Swap Button
              Center(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      final temp = fromCurrency;

                      fromCurrency = toCurrency;
                      toCurrency = temp;

                      result = '';
                    });
                  },
                  icon: const Icon(
                    Icons.swap_vert,
                    size: 35,
                    color: Colors.teal,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // To
              DropdownButtonFormField<String>(
                value: toCurrency,
                decoration: InputDecoration(
                  labelText: "To",
                  prefixIcon: const Icon(
                    Icons.currency_exchange,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
                items: currencies.map(
                      (currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    toCurrency = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              // Convert Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : convertCurrency,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "Convert",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Result
              if (result.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [

                      const Text(
                        "Result",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        result,
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
            ],
          ),
        ),
      ),
    );
  }
}