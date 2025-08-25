import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Category extends StatelessWidget {
  const Category({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Category"),
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Row(
                  children: [
                    Icon(Icons.wallet, color: Colors.green),
                    Text("Income"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Icon(Icons.wallet, color: Colors.red),
                    Text("Expenses"),
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
