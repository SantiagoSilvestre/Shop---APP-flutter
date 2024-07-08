import 'package:flutter/material.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  bool isLogin() => _authMode == AuthMode.Login;
  bool isSignup() => _authMode == AuthMode.Signup;

  void _swithAuthMode() {
    setState(() {
      if (isLogin()) {
        _authMode = AuthMode.Signup;
      } else {
        _authMode = AuthMode.Login;
      }
    });
  }

  void _sumit() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => isLoading = true);

    if (isLogin()) {
      // Login
    } else {
      // Register
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: isLogin() ? 310 : 400,
        width: deviceSize.width * 0.75,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => _authData['email'] = email ?? '',
                validator: (emails) {
                  if (emails == null ||
                      emails.trim().isEmpty ||
                      !emails.contains('@')) {
                    return 'Invalid email!';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                controller: passwordController,
                onSaved: (password) => _authData['password'] = password ?? '',
                // keyboardType: TextInputType.p,
                obscureText: true,
                validator: (password) {
                  if (password == null ||
                      password.isEmpty ||
                      password.length < 5) {
                    return 'Password is too short!';
                  }
                  return null;
                },
              ),
              if (isSignup())
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Password confirmation'),
                  // keyboardType: TextInputType.p,
                  obscureText: true,
                  validator: isLogin()
                      ? null
                      : (passwordConfirmation) {
                          if (passwordConfirmation != passwordController.text) {
                            return 'Passwords are different';
                          }
                          return null;
                        },
                ),
              const SizedBox(
                height: 20,
              ),
              if (isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _sumit,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                  ),
                  child:
                      Text(_authMode == AuthMode.Login ? 'Submit' : 'Register'),
                ),
              const Spacer(),
              TextButton(
                onPressed: _swithAuthMode,
                child: Text(
                  isLogin()
                      ? 'De not have an account? Register'
                      : 'I already have an account',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
