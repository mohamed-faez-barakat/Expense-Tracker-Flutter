import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'verfi_email.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> signup() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    // ==============================
    // VALIDATION
    // ==============================

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    if (!email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email"),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password must be at least 6 characters",
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ==============================
      // SIGN UP
      // ==============================

      final response =
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,

        emailRedirectTo: Uri.base.origin,

        data: {
          'full_name': fullName,
        },
      );

      if (!mounted) return;

      // ==========================================
      // USER CREATED / VERIFICATION REQUIRED
      // ==========================================

      if (response.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VerifyEmail(),
          ),
        );
      }
    }

    // ==========================================
    // SUPABASE AUTH ERROR
    // ==========================================

    on AuthException catch (error) {
      if (!mounted) return;

      final message = error.message.toLowerCase();

      // Existing email
      if (message.contains("already registered") ||
          message.contains("already exists") ||
          message.contains("user already")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "An account already exists with this email. Please login.",
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }

      // Other authentication errors
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    // ==========================================
    // OTHER ERROR
    // ==========================================

    catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $error"),
        ),
      );
    }

    // ==========================================
    // STOP LOADING
    // ==========================================

    finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Sign Up"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 20),

              // ==============================
              // ICON
              // ==============================

              const Icon(
                Icons.person_add,
                size: 70,
                color: Colors.teal,
              ),

              const SizedBox(height: 15),

              // ==============================
              // TITLE
              // ==============================

              const Text(
                "Create Account",

                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // ==============================
              // FULL NAME
              // ==============================

              TextField(
                controller: fullNameController,

                decoration: InputDecoration(
                  labelText: "Full Name",

                  prefixIcon: const Icon(
                    Icons.person,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==============================
              // EMAIL
              // ==============================

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

              // ==============================
              // PASSWORD
              // ==============================

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

              const SizedBox(height: 30),

              // ==============================
              // CREATE ACCOUNT
              // ==============================

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed:
                  isLoading ? null : signup,

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),

                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "Create Account",

                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ==============================
              // LOGIN
              // ==============================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [
                  const Text(
                    "Already have an account? ",
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },

                    child: const Text(
                      "Login",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}