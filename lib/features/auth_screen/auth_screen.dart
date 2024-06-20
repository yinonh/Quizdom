import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trivia/common_widgets/app_bar.dart';
import 'package:trivia/features/avatar_screen/avatar_screen.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = "/login";

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLogin = true;
  late String _email;
  late String _password;
  late String _confirmPassword;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _errorMessage = '';

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus(); // Close keyboard

    if (isValid) {
      _formKey.currentState!.save(); // Trigger save on all fields

      try {
        if (_isLogin) {
          await _auth.signInWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          print("Successful login");
          Navigator.pushReplacementNamed(context, AvatarScreen.routeName);
        } else {
          await _auth.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          print("Successful registration");
          // Navigate to home screen after successful registration
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString(),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
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
      appBar: const CustomAppBar(
        title: "Auth Screen",
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SvgPicture.asset(
            "assets/blob-scene-haikei.svg",
            fit: BoxFit.cover, // Ensure the SVG covers the entire screen
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          // Positioned(
          //   top: -100,
          //   left: -80,
          //   right: 0,
          //   child: SvgPicture.asset(
          //     "assets/blob.svg",
          //     fit: BoxFit.cover, // Ensure the SVG covers the entire screen
          //     height: 300,
          //     width: 500,
          //   ),
          // ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center vertically
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Invalid email';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value!;
                      },
                    ),
                    if (!_isLogin) ...[
                      SizedBox(height: 20),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        controller: _confirmPasswordController,
                        validator: (value) {
                          if (value!.isEmpty ||
                              value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _confirmPassword = value!;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isLogin ? 'Login' : 'Register'),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _errorMessage = ''; // Clear error message on toggle
                      });
                    },
                    child: Text(_isLogin
                        ? 'Create new account'
                        : 'Already have an account? Login'),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ))
        ],
      ),
    );
  }
}
