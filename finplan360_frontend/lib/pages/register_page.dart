import 'package:finplan360_frontend/components/my_button.dart';
import 'package:finplan360_frontend/pages/auth_page.dart';
import 'package:finplan360_frontend/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        dobController.text = pickedDate.toString();
      });
    });
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

                // const SizedBox(
                //   height: 10,
                // ),

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 25),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       Text(
                //         'Forgot Password?',
                //         style: TextStyle(color: Colors.grey[600]),
                //       ),
                //     ],
                //   ),
                // ),

                const SizedBox(
                  height: 25,
                ),

                //login button
                MyButton(
                  onTap: () {
                    // login
                    try {} catch (e) {}
                    if (passwordController.text ==
                        confirmpasswordController.text) {
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
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password does not match'),
                        ),
                      );
                    }

                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => AuthPage(
                    //       firstName: firstNameController.text,
                    //       lastName: lastNameController.text,
                    //       username: usernameController.text,
                    //       password: passwordController.text,
                    //       dob: dobController.text,
                    //     ),
                    //   ),
                  },
                  text: 'Sign Up',
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
                            builder: (context) => const LoginPage(),
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
