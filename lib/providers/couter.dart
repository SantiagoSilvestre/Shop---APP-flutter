import 'package:flutter/material.dart';

class CounterState {
  int _counter = 0;

  void increment() => _counter++;
  void decrement() => _counter--;
  int get count => _counter;
  bool diff(CounterState old) => old._counter != _counter;
}

class CounterProvider extends InheritedWidget {
  CounterProvider({
    required child,
  }) : super(child: child);

  final CounterState state = CounterState();

  static CounterProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterProvider>();
  }

  @override
  bool updateShouldNotify(covariant CounterProvider oldWidget) {
    return oldWidget.state.diff(state);
  }
}
