import 'package:flutter/material.dart';

class BudgetTipScreen extends StatefulWidget {
  const BudgetTipScreen({super.key});

  @override
  State<BudgetTipScreen> createState() => _BudgetTipScreenState();
}

class _BudgetTipScreenState extends State<BudgetTipScreen> {
  final List<Map<String, dynamic>> tips = [
    {
      "title": "Track every expense",
      "desc": "Log every spending so you know where your money goes.",
      "icon": Icons.receipt_long,
      "color": Colors.blue,
    },
    {
      "title": "Set a monthly budget",
      "desc": "Limit your spending based on your income.",
      "icon": Icons.account_balance_wallet,
      "color": Colors.green,
    },
    {
      "title": "Avoid impulse buying",
      "desc": "Wait 24 hours before buying non-essential items.",
      "icon": Icons.shopping_cart,
      "color": Colors.orange,
    },
    {
      "title": "Save first, spend later",
      "desc": "Put savings aside before using your money.",
      "icon": Icons.savings,
      "color": Colors.purple,
    },
    {
      "title": "Review weekly",
      "desc": "Check your spending every week to stay on track.",
      "icon": Icons.insights,
      "color": Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Tips"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: tip["color"].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    tip["icon"],
                    color: tip["color"],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip["title"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip["desc"],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}