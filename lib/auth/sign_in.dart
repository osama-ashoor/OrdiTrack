import 'package:b2b/auth/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class signIn extends StatefulWidget {
  final Function toggleBetween;
  const signIn({super.key, required this.toggleBetween});

  @override
  State<signIn> createState() => _signInState();
}

class _signInState extends State<signIn> {
  bool _showPassword = true;
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  final AuthService _auth = AuthService();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            "Sign In",
            style: GoogleFonts.bebasNeue(fontSize: 30, color: Colors.black),
          ),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.shopping_bag,
                      size: 120,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      cursorColor: Colors.black,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 3,
                            ),
                          ),
                          labelText: "Email",
                          labelStyle: GoogleFonts.bebasNeue(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                          icon: Icon(Icons.email, color: Colors.black)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!(value.trim().endsWith('.com'))) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        email = value!.trim();
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      cursorColor: Colors.black,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      obscureText: _showPassword,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                            width: 3,
                          ),
                        ),
                        labelText: "Password",
                        labelStyle: GoogleFonts.bebasNeue(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        icon: Icon(
                          Icons.lock,
                          color: Colors.black,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              if (_showPassword) {
                                _showPassword = false;
                              } else {
                                _showPassword = true;
                              }
                            });
                          },
                          icon: Icon(
                            Icons.remove_red_eye_rounded,
                            size: 25,
                            color: _showPassword ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        password = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            widget.toggleBetween();
                          },
                          child: Text(
                            'Register an account',
                            style: GoogleFonts.bebasNeue(
                                fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? CircularProgressIndicator(
                            color: Colors.black,
                          )
                        : ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).colorScheme.inversePrimary,
                              ),
                              minimumSize: MaterialStateProperty.all<Size>(
                                Size(
                                  MediaQuery.of(context).size.width,
                                  50,
                                ),
                              ),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )),
                            ),
                            child: Text(
                              "Sign In",
                              style: GoogleFonts.bebasNeue(
                                fontSize: 30,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                setState(() {
                                  isLoading = true;
                                });
                                dynamic result =
                                    await _auth.SignIn(email, password);
                                if (result == null) {
                                  setState(() {
                                    isLoading = false;
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Sign In Failed'),
                                          content: Text(
                                              'Invalid email or password. Please try again.'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                _formKey.currentState!.reset();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  });
                                } else {
                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
