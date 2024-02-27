import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../components/my_button.dart';
import '../components/custom_textfield.dart';
import '../services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllerers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final LocalAuthentication auth;
  // ignore: unused_field
  bool _isAuthenticated = false;
  // ignore: unused_field
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    auth = LocalAuthentication();
    checkBiometricAuth();
  }

  Future<void> checkBiometricAuth() async {
    if (!_isMounted) return;
    _isAuthenticated = await AuthService.authenticateUser();
    if (_isMounted) {
      setState(() {});
    }
  }

  void wrongCredentialsMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Center(
            child: Text(
              'Invalid Credentials',
            ),
          ),
        );
      },
    );
  }

  // login method
  void signIn() async {
    // auth service
    final auth = AuthService();

    // try signing in
    try {
      auth.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
        wrongCredentialsMessage,
      );
    }

    // catch errors
    catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    // logo
                    Icon(
                      Icons.message,
                      size: 90,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const SizedBox(height: 50),

                    // welcome back message
                    Text(
                      'Welcome back, you\'ve been missed!',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary),
                    ),

                    const SizedBox(height: 25),

                    // email textfield
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),

                    const SizedBox(height: 10),

                    // password textfield
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 25),

                    // sign in button
                    MyButton(
                      onTap: signIn,
                      text: 'Login',
                    ),

                    const SizedBox(height: 30),

                    // not a member? register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Not a member?'),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            'Register now',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
