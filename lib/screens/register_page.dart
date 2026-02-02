import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../app_language.dart';
import '../app_strings.dart';

class RegisterPage extends StatefulWidget {
  final AppLanguage appLanguage;
  const RegisterPage({super.key, required this.appLanguage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool isEmailValid = false;
  bool isPasswordValid = false;
  bool isConfirmPasswordValid = false;

  String? error;
  bool loading = false;

  static const headerColor = Color(0xFF386641);

  bool validateEmail(String value) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
  }

  bool validatePassword(String value) {
    return value.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.appLanguage.code;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [

          // 🔵 HEADER
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF386641), Color(0xFF6A994E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.language, color: Colors.white),
                          onPressed: widget.appLanguage.toggle,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      AppStrings.get('register', lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🟢 FORMULAIRE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [

                      if (error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            error!,
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      _field(firstName, AppStrings.get('first_name', lang)),
                      _field(lastName, AppStrings.get('last_name', lang)),
                      _field(phone, AppStrings.get('phone', lang),
                          type: TextInputType.phone),

                      _field(
                        email,
                        AppStrings.get('email', lang),
                        onChanged: (v) {
                          setState(() => isEmailValid = validateEmail(v));
                        },
                        suffixIcon: email.text.isEmpty
                            ? null
                            : _icon(isEmailValid),
                      ),

                      _field(
                        password,
                        AppStrings.get('password', lang),
                        obscure: true,
                        onChanged: (v) {
                          setState(() {
                            isPasswordValid = validatePassword(v);
                            isConfirmPasswordValid =
                                confirmPassword.text == v && v.isNotEmpty;
                          });
                        },
                        suffixIcon: password.text.isEmpty
                            ? null
                            : _icon(isPasswordValid),
                      ),

                      _field(
                        confirmPassword,
                        AppStrings.get('confirm_password', lang),
                        obscure: true,
                        onChanged: (v) {
                          setState(() {
                            isConfirmPasswordValid =
                                v == password.text && v.isNotEmpty;
                          });
                        },
                        suffixIcon: confirmPassword.text.isEmpty
                            ? null
                            : _icon(isConfirmPasswordValid),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: loading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: headerColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            AppStrings.get('register', lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Retour", style: TextStyle(color: headerColor)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon(bool ok) {
    return Icon(
      ok ? Icons.check_circle : Icons.cancel,
      color: ok ? Colors.green : Colors.red,
    );
  }

  Widget _field(
      TextEditingController controller,
      String label, {
        bool obscure = false,
        TextInputType type = TextInputType.text,
        void Function(String)? onChanged,
        Widget? suffixIcon,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon,
          floatingLabelStyle: const TextStyle(
            color: headerColor,
            fontWeight: FontWeight.bold,
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: headerColor),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!isEmailValid || !isPasswordValid || !isConfirmPasswordValid) {
      setState(() => error = "Veuillez corriger les champs");
      return;
    }

    setState(() {
      error = null;
      loading = true;
    });

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.text.trim().toLowerCase(),
        password: password.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'firstName': firstName.text.trim(),
        'lastName': lastName.text.trim(),
        'phone': phone.text.trim(),
        'email': email.text.trim().toLowerCase(),
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() => error = "Erreur lors de l'inscription");
    } finally {
      setState(() => loading = false);
    }
  }
}
