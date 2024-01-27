import 'package:flutter/material.dart';
import 'package:secure_messenger/services/auth/auth_service.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // tap to go to login page
  final void Function()? onTap;

  RegisterPage({
    super.key,
    required this.onTap,
  });

  // register method
  void register(BuildContext context) {
    // get auth service
    final auth = AuthService();

    // passwords match -> create user
    if (_passwordController.text == _confirmPasswordController.text) {
      auth
          .signUpWithEmailPassword(
            _emailController.text,
            _passwordController.text,
          )
          .then((_) {})
          .catchError((e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      });
      // passwords don't match -> tell user to fix
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Passwords don\'t match!'),
        ),
      );
    }
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
                      'Let\'s create an account for you',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary),
                    ),

                    const SizedBox(height: 25),

                    // email textfield
                    MyTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),

                    const SizedBox(height: 10),

                    // password textfield
                    MyTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 10),

                    // confirm password textfield
                    MyTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 25),

                    // sign in button
                    MyButton(onTap: () => register(context), text: 'Register'),

                    const SizedBox(height: 30),

                    // already have an account? login now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onTap,
                          child: const Text(
                            'Login',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
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
