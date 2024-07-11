import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/models/auth.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  AnimationController? _controller;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  bool isLogin() => _authMode == AuthMode.Login;
  // bool isSignup() => _authMode == AuthMode.Signup;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.bounceIn,
      ),
    );

    _slideAnimation = Tween(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.bounceIn,
      ),
    );

    // _opacityAnimation?.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  void _swithAuthMode() {
    setState(() {
      if (isLogin()) {
        _authMode = AuthMode.Signup;
        _controller?.forward();
      } else {
        _authMode = AuthMode.Login;
        _controller?.reverse();
      }
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ocorreu um erro"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Fechar"),
          )
        ],
      ),
    );
  }

  Future<void> _sumit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => isLoading = true);

    _formKey.currentState?.save();
    Auth auth = Provider.of<Auth>(context, listen: false);

    try {
      if (isLogin()) {
        // Login
        await auth.login(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        // Register
        await auth.signup(
          _authData['email']!,
          _authData['password']!,
        );
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog("Ocorreu um erro inesperado");
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInExpo,
        padding: const EdgeInsets.all(16),
        height: isLogin() ? 310 : 400,
        // height: _opacityAnimation?.value.height ?? (isLogin() ? 310 : 400),
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
              AnimatedContainer(
                constraints: BoxConstraints(
                  minHeight: isLogin() ? 0 : 60,
                  maxHeight: isLogin() ? 0 : 120,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInCirc,
                child: FadeTransition(
                  opacity: _opacityAnimation!,
                  child: SlideTransition(
                    position: _slideAnimation!,
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Password confirmation'),
                      // keyboardType: TextInputType.p,
                      obscureText: true,
                      validator: isLogin()
                          ? null
                          : (passwordConfirmation) {
                              if (passwordConfirmation !=
                                  passwordController.text) {
                                return 'Passwords are different';
                              }
                              return null;
                            },
                    ),
                  ),
                ),
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
