import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() =>
      _ResetPasswordState();
}

class _ResetPasswordState
    extends State<ResetPassword> {

  final passwordController =
  TextEditingController();

  final confirmPasswordController =
  TextEditingController();

  bool isLoading = false;
  bool isVerifying = true;
  bool sessionReady = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    handleRecovery();
  }

  // =========================
  // HANDLE RESET LINK
  // =========================

  Future<void> handleRecovery() async {
    final supabase =
        Supabase.instance.client;

    try {
      final uri = Uri.base;

      final code =
      uri.queryParameters['code'];

      // No code
      if (code == null || code.isEmpty) {
        if (!mounted) return;

        setState(() {
          sessionReady = false;
          isVerifying = false;
        });

        return;
      }

      // Exchange PKCE code for session
      await supabase.auth
          .exchangeCodeForSession(code);

      // Get created session
      final session =
          supabase.auth.currentSession;

      if (!mounted) return;

      setState(() {
        sessionReady = session != null;
        isVerifying = false;
      });

    } on AuthException catch (error) {

      if (!mounted) return;

      setState(() {
        sessionReady = false;
        isVerifying = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error.message,
          ),
        ),
      );

    } catch (error) {

      if (!mounted) return;

      setState(() {
        sessionReady = false;
        isVerifying = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Error verifying reset link: $error",
          ),
        ),
      );
    }
  }

  // =========================
  // RESET PASSWORD
  // =========================

  Future<void> resetPassword() async {

    final password =
    passwordController.text.trim();

    final confirmPassword =
    confirmPasswordController.text.trim();

    // Empty
    if (password.isEmpty ||
        confirmPassword.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all fields",
          ),
        ),
      );

      return;
    }

    // Minimum length
    if (password.length < 6) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Password must be at least 6 characters",
          ),
        ),
      );

      return;
    }

    // Match
    if (password != confirmPassword) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Passwords do not match",
          ),
        ),
      );

      return;
    }

    // Check session again
    final session =
        Supabase.instance.client
            .auth
            .currentSession;

    if (session == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Reset link is invalid or expired. Please request a new link.",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      // Update password
      await Supabase.instance.client.auth
          .updateUser(
        UserAttributes(
          password: password,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Password changed successfully!",
          ),
        ),
      );

      // Sign out recovery session
      await Supabase.instance.client.auth
          .signOut();

      if (!mounted) return;

      // Back to login
      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(
          builder: (context) =>
          const Login(),
        ),

            (route) => false,
      );

    } on AuthException catch (error) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error.message,
          ),
        ),
      );

    } catch (error) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

  @override
  void dispose() {

    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          "Reset Password",
        ),

        centerTitle: true,

        backgroundColor:
        Colors.teal,
      ),

      body: isVerifying

      // =========================
      // VERIFYING
      // =========================

          ? const Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            CircularProgressIndicator(
              color: Colors.teal,
            ),

            SizedBox(height: 20),

            Text(
              "Verifying reset link...",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      )

      // =========================
      // INVALID LINK
      // =========================

          : !sessionReady

          ? Center(
        child: Padding(
          padding:
          const EdgeInsets.all(30),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.link_off,
                size: 80,
                color: Colors.red,
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                "Invalid or Expired Link",

                textAlign:
                TextAlign.center,

                style: TextStyle(
                  fontSize: 26,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              const Text(
                "This password reset link is invalid or has expired.\nPlease request a new reset link.",

                textAlign:
                TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(
                width:
                double.infinity,

                height: 50,

                child:
                ElevatedButton(
                  onPressed: () {

                    Navigator
                        .pushAndRemoveUntil(
                      context,

                      MaterialPageRoute(
                        builder:
                            (context) =>
                        const Login(),
                      ),

                          (route) => false,
                    );
                  },

                  style:
                  ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    Colors.teal,

                    foregroundColor:
                    Colors.white,
                  ),

                  child: const Text(
                    "Back to Login",

                    style:
                    TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )

      // =========================
      // RESET FORM
      // =========================

          : SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.all(20),

          child: Column(
            children: [

              const SizedBox(
                height: 40,
              ),

              const Icon(
                Icons.lock_reset,
                size: 90,
                color: Colors.teal,
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                "Reset Password",

                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              const Text(
                "Enter your new password below.",

                textAlign:
                TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 35,
              ),

              // =========================
              // NEW PASSWORD
              // =========================

              TextField(
                controller:
                passwordController,

                obscureText:
                obscurePassword,

                decoration:
                InputDecoration(
                  labelText:
                  "New Password",

                  prefixIcon:
                  const Icon(
                    Icons.lock,
                  ),

                  suffixIcon:
                  IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                        !obscurePassword;
                      });
                    },

                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(12),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // =========================
              // CONFIRM PASSWORD
              // =========================

              TextField(
                controller:
                confirmPasswordController,

                obscureText:
                obscureConfirmPassword,

                decoration:
                InputDecoration(
                  labelText:
                  "Confirm Password",

                  prefixIcon:
                  const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon:
                  IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword =
                        !obscureConfirmPassword;
                      });
                    },

                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(12),
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // =========================
              // RESET BUTTON
              // =========================

              SizedBox(
                width:
                double.infinity,

                height: 50,

                child:
                ElevatedButton(
                  onPressed:
                  isLoading
                      ? null
                      : resetPassword,

                  style:
                  ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    Colors.teal,

                    foregroundColor:
                    Colors.white,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(12),
                    ),
                  ),

                  child: isLoading

                      ? const CircularProgressIndicator(
                    color:
                    Colors.white,
                  )

                      : const Text(
                    "Reset Password",

                    style:
                    TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // =========================
              // BACK TO LOGIN
              // =========================

              TextButton(
                onPressed:
                isLoading
                    ? null
                    : () {

                  Navigator
                      .pushAndRemoveUntil(
                    context,

                    MaterialPageRoute(
                      builder:
                          (context) =>
                      const Login(),
                    ),

                        (route) =>
                    false,
                  );
                },

                child: const Text(
                  "Back to Login",

                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}