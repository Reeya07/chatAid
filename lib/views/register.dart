import 'package:flutter/material.dart';
import '../controllers/register_controller.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final _registerformKey = GlobalKey<FormState>();

  final TextEditingController nameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController confirmPasswordC = TextEditingController();

  final RegisterController _authController = RegisterController();
  bool _isloading = false;

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    passwordC.dispose();
    confirmPasswordC.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_registerformKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isloading = true;
    });

    final String? errorMessage = await _authController.register(
      name: nameC.text,
      email: emailC.text,
      password: passwordC.text,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _isloading = false;
    });
    //boolean in all state class that tells flutter widget is true/false.
    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully created!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, 'views/nav');
      nameC.clear();
      emailC.clear();
      passwordC.clear();
      confirmPasswordC.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0XFFE1D5FF), Color(0XFF8CB4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 150,
                  height: 80,
                  child: Image.asset(
                    'assets/image/logo.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ChatAid',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 4, 108, 193),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your Mental Wellness companion',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 0, 140, 254),
                  ),
                ),
                const SizedBox(height: 28),
                //white form
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.85,
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black, //TO ADD OPACITY
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _registerformKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 4),
                            Center(
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E88E5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            //Name
                            const Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: nameC,
                              decoration: InputDecoration(
                                labelText: 'Enter your name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            //email
                            const Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: emailC,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Enter your email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            //password
                            const Text(
                              'Password',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: passwordC,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Enter your password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'At least 6 characters';
                                }
                                if (!RegExp(r'[0-9]').hasMatch(value)) {
                                  return 'Must contain at least one number';
                                }

                                // Must contain a letter
                                if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
                                  return 'Must contain at least one letter';
                                }

                                // Must contain a special character
                                if (!RegExp(
                                  r'[!@#$%^&*(),.?":{}|<>]',
                                ).hasMatch(value)) {
                                  return 'Must include at least one special character like @ # ! %';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            //confirmPassword
                            TextFormField(
                              controller: confirmPasswordC,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Confirm your password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Password is required';
                                }
                                if (value != passwordC.text) {
                                  return 'Password does not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 26),

                            //register button
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isloading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1565C0),
                                        Color(0xFF42A5F5),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: _isloading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 10,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Register',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, 'views/login');
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your safe place for mental wellness',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
