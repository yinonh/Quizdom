import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trivia/features/avatar_screen/avatar_screen.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = "/login";

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLogin = true;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String _email = '';
  String _password = '';
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus(); // Close keyboard

    if (isValid) {
      _formKey.currentState!.save();

      try {
        if (_isLogin) {
          await _auth.signInWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          Navigator.pushReplacementNamed(context, AvatarScreen.routeName);
          print("Successful login");
        } else {
          await _auth.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          print("Successful registration");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
        print("Error: ${e.toString()}");
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents overflow when keyboard opens
      body: Stack(
        children: [
          SvgPicture.asset(
            "assets/blob-scene-haikei.svg",
            fit: BoxFit.cover, // Ensure the SVG covers the entire screen
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Positioned(
            left: 30,
            top: 100,
            child: Text(
              !_isLogin ? 'Create Account' : 'Welcome Back',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppConstant.secondaryColor.toColor(),
                shadows: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    spreadRadius: 4,
                    blurRadius: 5,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.white),
                            prefixIcon:
                                const Icon(Icons.email, color: Colors.white),
                            suffixIcon: _email.isNotEmpty &&
                                    EmailValidator.validate(_email)
                                ? const Icon(Icons.check_circle,
                                    color: Colors.white)
                                : null,
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !EmailValidator.validate(value)) {
                              return 'Invalid email';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _email = value;
                            });
                          },
                          onSaved: (value) {
                            _email = value!;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.white),
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.white),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          obscureText: !_showPassword,
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _password = value!;
                          },
                        ),
                        if (!_isLogin) ...[
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: const TextStyle(color: Colors.white),
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.white),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showConfirmPassword =
                                        !_showConfirmPassword;
                                  });
                                },
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            obscureText: !_showConfirmPassword,
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _submit,
                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: AppConstant.onPrimary.toColor()),
                      child: Text(
                        _isLogin ? 'Log In' : 'Sign Up',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Create new account'
                        : 'Already have an account? Log In',
                    style:
                        TextStyle(color: AppConstant.highlightColor.toColor()),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
