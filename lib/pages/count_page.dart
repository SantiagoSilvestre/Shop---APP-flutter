import 'package:flutter/material.dart';
import 'package:shop/providers/couter.dart';

class CountPage extends StatefulWidget {
  const CountPage({super.key});

  @override
  State<CountPage> createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Count Page'),
      ),
      body: Column(
        children: [
          Text(CounterProvider.of(context)?.state.count.toString() ?? "0"),
          IconButton(
            onPressed: () {
              setState(() {
                CounterProvider.of(context)?.state.increment();
              });
            },
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                CounterProvider.of(context)?.state.decrement();
              });
            },
            icon: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
