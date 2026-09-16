import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'nav.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isResettingPassword = false;

  // =========================
  // LOGIN
  // =========================

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter your email and password",
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response =
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response.user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
              (route) => false,
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $error",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =========================
  // FORGOT PASSWORD
  // =========================

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter your email first",
          ),
        ),
      );
      return;
    }

    setState(() {
      isResettingPassword = true;
    });

    try {
      final redirectUrl =
          '${Uri.base.origin}/reset-password';

      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password reset link has been sent to your email.",
          ),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $error",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isResettingPassword = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          "Login",
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              const SizedBox(height: 30),

              // Login Icon
              const Icon(
                Icons.account_circle,
                size: 80,
                color: Colors.teal,
              ),

              const SizedBox(height: 15),

              // Title
              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // EMAIL
              // =========================

              TextField(
                controller: emailController,

                keyboardType:
                TextInputType.emailAddress,

                decoration: InputDecoration(
                  labelText: "Email",

                  prefixIcon: const Icon(
                    Icons.email,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // PASSWORD
              // =========================

              TextField(
                controller: passwordController,

                obscureText: true,

                decoration: InputDecoration(
                  labelText: "Password",

                  prefixIcon: const Icon(
                    Icons.lock,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),

              // =========================
              // FORGOT PASSWORD
              // =========================

              Align(
                alignment: Alignment.centerRight,

                child: TextButton(
                  onPressed:
                  isResettingPassword
                      ? null
                      : forgotPassword,

                  child: isResettingPassword
                      ? const SizedBox(
                    width: 18,
                    height: 18,

                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.teal,
                    ),
                  )
                      : const Text(
                    "Forgot Password?",

                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // =========================
              // LOGIN BUTTON
              // =========================

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed:
                  isLoading ? null : login,

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.teal,

                    foregroundColor:
                    Colors.white,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),

                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "Login",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // SIGN UP
              // =========================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  const Text(
                    "Don't have an account? ",
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                          const Signup(),
                        ),
                      );
                    },

                    child: const Text(
                      "Sign Up",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}