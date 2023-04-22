import 'package:finplan360_frontend/components/my_button.dart';
import 'package:finplan360_frontend/pages/auth_page.dart';
import 'package:finplan360_frontend/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  // date picker
  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    });
  }

  bool _validateInputs() {
    if (firstNameController.text.isEmpty) {
      _showErrorDialog('First name is required');
      return false;
    }
    // validate first name for only alphabets
    if (!RegExp(r"^[a-zA-Z]+$").hasMatch(firstNameController.text)) {
      _showErrorDialog('First name should contain only alphabets');
      return false;
    }
    if (lastNameController.text.isEmpty) {
      _showErrorDialog('Last name is required');
      return false;
    }
    // validate last name for only alphabets
    if (!RegExp(r"^[a-zA-Z]+$").hasMatch(lastNameController.text)) {
      _showErrorDialog('Last name should contain only alphabets');
      return false;
    }
    if (dobController.text.isEmpty) {
      _showErrorDialog('Date of birth is required');
      return false;
    }
    if (usernameController.text.isEmpty) {
      _showErrorDialog('Username is required');
      return false;
    }
    // validate username for only alphabets and numbers
    if (!RegExp(r"^[a-zA-Z0-9]+$").hasMatch(usernameController.text)) {
      _showErrorDialog('Username should contain only alphabets and numbers');
      return false;
    }
    if (passwordController.text.isEmpty) {
      _showErrorDialog('Password is required');
      return false;
    }
    // validate password for minimum 8 characters at least 1 Alphabet and 1 Number and 1 Special Character and no whitespace allowed
    if (!RegExp(
            r"^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*()_+])[A-Za-z\d!@#$%^&*()_+]{8,}$")
        .hasMatch(passwordController.text)) {
      _showErrorDialog(
          'Password should contain minimum 8 characters at least 1 Alphabet and 1 Number and 1 Special Character and no whitespace allowed');
      return false;
    }
    if (confirmpasswordController.text.isEmpty) {
      _showErrorDialog('Confirm password is required');
      return false;
    }
    if (passwordController.text != confirmpasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return false;
    }
    return true;
  }

  // show error dialog
  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
    // showDialog(
    //   context: context,
    //   builder: (ctx) => AlertDialog(
    //     title: const Text('Error'),
    //     content: Text(message),
    //     actions: [
    //       TextButton(
    //         onPressed: () {
    //           Navigator.of(ctx).pop();
    //         },
    //         child: const Text('OK'),
    //       ),
    //     ],
    //   ),
    // );
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
                  'Let\'s get started',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                // first name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: firstNameController,
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
                      hintText: "First Name",
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    onSubmitted: (value) => firstNameController.text = value,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // last name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: lastNameController,
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
                      hintText: "Last Name",
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    onSubmitted: (value) => lastNameController.text = value,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                //date of birth
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Choose Date of Birth: ',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      onPressed: _showDatePicker,
                      icon: const Icon(Icons.calendar_today),
                    ),
                    // display date of birth
                    Text(
                      dobController.text,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 10,
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

                // confirm password

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: confirmpasswordController,
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
                      hintText: 'Confirm Password',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    onSubmitted: (value) =>
                        confirmpasswordController.text = value,
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                //login button
                MyButton(
                  onTap: () {
                    // login
                    try {} catch (e) {}
                    if (!_validateInputs()) {
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthPage(
                          firstName: firstNameController.text,
                          lastName: lastNameController.text,
                          username: usernameController.text,
                          dob: dobController.text,
                          password: passwordController.text,
                        ),
                      ),
                    );
                    // }
                    // else {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //       content: Text('Password does not match'),
                    //     ),
                    //   );
                    // }
                  },
                  text: 'Sign Up',
                  isloading: false,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        // login page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(
                              isFromAuthPage: false,
                              isFromHomePage: false,
                            ),
                          ),
                        );
                      },
                      child: const Text('Login now'),
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
