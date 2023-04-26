import 'package:finplan360_frontend/components/my_button.dart';
import 'package:finplan360_frontend/constants/ip.dart';
import 'package:finplan360_frontend/constants/routes.dart';
import 'package:finplan360_frontend/pages/salary_page.dart';
import 'package:finplan360_frontend/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final bool isFromAuthPage;
  final bool isFromSalaryPage;
  const LoginPage(
      {Key? key, required this.isFromAuthPage, required this.isFromSalaryPage})
      : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isloading = false;

  bool get isFromAuthPage => widget.isFromAuthPage;
  bool get isFromSalaryPage => widget.isFromSalaryPage;

  @override
  void initState() {
    super.initState();
    if (isFromAuthPage) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
            ),
          );
        },
      );
    } else if (isFromSalaryPage) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged Out successfully!'),
            ),
          );
        },
      );
    }
  }

  Future<String> _postlogindata(BuildContext context) async {
    try {
      setState(() {
        _isloading = true;
      });

      var response = await http.post(Uri.parse("http://$ip/api/login"), body: {
        "username": usernameController.text,
        "password": passwordController.text,
      });

      // print();

      var result = jsonDecode(response.body);
      print(result['response']);

      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences login = await SharedPreferences.getInstance();
      var firstlogin = login.getBool('firstTimeLogin') ?? false;
      print(firstlogin);
      if (result['response'] == 'logged in' && firstlogin == true) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          salaryRoute,
          (route) => false,
          arguments: usernameController.text,
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', usernameController.text);

        SharedPreferences login = await SharedPreferences.getInstance();
        login.setBool('firstTimeLogin', false);
      } else if (result['response'] == 'logged in' && firstlogin == false) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          homeRoute,
          (route) => false,
          arguments: usernameController.text,
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', usernameController.text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Username or Password!!'),
          ),
        );
      }
    } catch (e) {
      print("Error is $e ");
    } finally {
      setState(() {
        _isloading = false;
      });
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 25,
                ),
                const Icon(
                  Icons.currency_rupee_rounded,
                  size: 100,
                ),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),

                //username

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: usernameController,
                    obscureText: false,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Username',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    onSubmitted: (value) => usernameController.text = value,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                //password

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    onSubmitted: (value) => passwordController.text = value,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                //login button
                MyButton(
                  onTap: () async {
                    _postlogindata(context);
                  },
                  text: 'Sign In',
                  isloading: _isloading,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?'),
                    TextButton(
                      onPressed: () {
                        // register page
                        Navigator.of(context).pushNamed(
                          registerRoute,
                        );
                      },
                      child: const Text('Register Now'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
