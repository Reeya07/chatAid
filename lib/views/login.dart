import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  final _loginformKey = GlobalKey<FormState>();

  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  final LoginController _loginController = LoginController();
  bool _isloading = false;

  @override
  void dispose() {
    emailC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_loginformKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isloading = true;
    });

    final String? errorMessage = await _loginController.login(
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
          content: Text('Login Successful.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, 'views/chat');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        ),
      );
    }
  }

  //To add anonymous
  Future<void> anonymousLogin() async {
    setState(() {
      _isloading = true;
    });
    final String? errorMessage = await _loginController.anonymous();
    if (!mounted) {
      return;
    }
    setState(() {
      _isloading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? 'Logged in Successfully'),
        backgroundColor: errorMessage == null ? Colors.green : Colors.red,
      ),
    );
    Navigator.pushReplacementNamed(context, 'views/chat');
  }

  Future<void> resetPassword() async {
    if (emailC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isloading = true;
    });

    final String? errorMessage = await _loginController.resetPassword(
      emailC.text,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _isloading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? ' Password reset email sent.'),
        backgroundColor: errorMessage == null ? Colors.green : Colors.red,
      ),
    );
  }

  //To add reset password
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFD3A84), Color(0xFF4A79FF)],
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ChatAid',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your Mental Wellness companion',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
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
                        key: _loginformKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 4),
                            Center(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9C40FF),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
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
                                filled: true,
                                fillColor: Color(0xFFF4F4F4),
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
                                return null;
                              },
                            ),

                            const SizedBox(height: 26),

                            //Login button
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isloading ? null : _login,
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
                                        Color(0xFF4A79FF),
                                        Color(0xFFB146FF),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: _isloading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 20,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Login',
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
                            SizedBox(height: 16),
                            SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: _isloading ? null : anonymousLogin,
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  side: BorderSide(color: Color(0xFFB146FF)),
                                ),
                                child: Text(
                                  'Enter Anonymously',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB146FF),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            TextButton(
                              onPressed: resetPassword,
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(color: Color(0xFFB146FF)),
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
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          'views/register',
                        );
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
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
