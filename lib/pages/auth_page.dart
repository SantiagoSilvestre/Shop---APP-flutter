import 'package:flutter/material.dart';
import 'package:shop/widgets/auth_form.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple,
                Colors.purple,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 70,
                ),
                transform: Matrix4.rotationZ(-8 * 3.14 / 180)..translate(-10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'My shop',
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: 'Anton',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              AuthForm()
            ],
          ),
        ),
      ],
    );
  }
}
