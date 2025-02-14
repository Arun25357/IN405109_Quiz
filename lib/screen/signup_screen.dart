import 'package:flutter/material.dart';
import 'package:in_and_ex/service/auth-service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _errorMessage = "";

  // Function to validate and sign up
  void _signup() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Validate passwords
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Passwords do not match";
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        _errorMessage = "Password must be at least 8 characters long";
      });
      return;
    }

    // Call AuthService to register
    var res = await AuthService().reqistration(
      email: email,
      password: password,
      confirm: confirmPassword,
    );

    if (res == 'success') {
      // Navigate back to SigninScreen
      Navigator.pop(context); // This will return to the previous screen
    } else {
      setState(() {
        _errorMessage = res!; // Display error from the auth service
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 227, 138, 100),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 118, 231, 116),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color.fromARGB(255, 227, 138, 100)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.email, color: const Color.fromARGB(255, 118, 231, 116)),
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Color.fromARGB(255, 227, 138, 100)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.lock, color: const Color.fromARGB(255, 118, 231, 116)),
              ),
            ),
            const SizedBox(height: 20),

            // Confirm Password Field
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: Color.fromARGB(255, 227, 138, 100)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.lock_outline, color: const Color.fromARGB(255, 118, 231, 116)),
              ),
            ),
            const SizedBox(height: 20),

            // Error Message
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Sign Up Button
            ElevatedButton(
              onPressed: _signup,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18,color: Color.fromARGB(255, 227, 138, 100)),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 118, 231, 116),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Already have an account?
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Go back to SigninScreen
              },
              child: Text(
                'Already have an account? Sign in',
                style: TextStyle(color: Color.fromARGB(255, 227, 138, 100)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}