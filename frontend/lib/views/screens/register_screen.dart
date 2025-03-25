import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  void _register() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registered successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Register',
            style: TextStyle(fontSize: 32, fontStyle: FontStyle.italic),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Reenter password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: Text('Register')),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text('Already have an account? Login'),
              ),
              TextButton(onPressed: () => context.go('/'), child: Text('Home'))
          ])),
      ),
    );
  }
}
