import 'dart:convert';
import 'package:finplan360_frontend/components/my_button.dart';
import 'package:finplan360_frontend/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:finplan360_frontend/constants/ip.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class AuthPage extends StatefulWidget {
  final String username;
  final String firstName;
  final String lastName;
  final String password;
  final String dob;

  const AuthPage({
    Key? key,
    required this.username,
    required this.password,
    required this.dob,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  State<AuthPage> createState() =>
      _AuthPageState(username, firstName, lastName, password, dob);
}

class _AuthPageState extends State<AuthPage> {
  final String username;
  final String firstName;
  final String lastName;
  final String password;
  final String dob;

  // text editing controllers
  final aadharorPanController = TextEditingController();

  bool _isloading = false;

  _AuthPageState(
      this.username, this.firstName, this.lastName, this.password, this.dob);

  Future<String> _postdata({String aadharorpan = ""}) async {
    try {
      setState(() {
        _isloading = true;
      });

      var response =
          await http.post(Uri.parse("http://$ip/api/register"), body: {
        "firstname": firstName,
        "lastname": lastName,
        "dob": dob,
        "username": username,
        "password": password,
        "aadharorpan": aadharorpan
      });

      var result = jsonDecode(response.body);

      print(result);

      if (result['response'] == 'Account Created Sucessfully') {
        SharedPreferences login = await SharedPreferences.getInstance();
        login.setBool('firstTimeLogin', true);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoginPage(
                      isFromAuthPage: true,
                      isFromSalaryPage: false,
                    )));
      } else if (result['response'] == 'Invalid Pan number') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Pan number!!'),
          ),
        );
      } else if (result['response'] == 'Username already exists') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username already exists'),
          ),
        );
      } else if (result['response'] == 'Pan exists') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Account Associated with this Pan number already exists!!'),
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
                  size: 50,
                ),
                const SizedBox(
                  height: 25,
                ),
                Text(
                  'Authenticate via Pan',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),

                //aadhar or pan

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: aadharorPanController,
                    inputFormatters: [UpperCaseTextFormatter()],
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
                      hintText: 'Pan number',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    onSubmitted: (value) => aadharorPanController.text = value,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                //authenticate button
                MyButton(
                  onTap: () async {
                    _postdata(aadharorpan: aadharorPanController.text);
                  },
                  text: 'Authenticate',
                  isloading: _isloading,
                ),

                // Google sign in ???
                // const SizedBox(
                //   height: 50,
                // ),

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 25),
                //   child: Row(
                //     children: [
                //       Expanded(
                //           child: Divider(
                //         color: Colors.grey[400],
                //         thickness: 0.7,
                //       )),
                //       Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 10),
                //         child: Text(
                //           'Or Continue With',
                //           style: TextStyle(color: Colors.grey[700]),
                //         ),
                //       ),
                //       Expanded(
                //           child: Divider(
                //         color: Colors.grey[400],
                //         thickness: 0.7,
                //       )),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
