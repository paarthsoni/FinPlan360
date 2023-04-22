import 'package:finplan360_frontend/components/my_button.dart';
import 'package:finplan360_frontend/constants/ip.dart';
import 'package:finplan360_frontend/constants/routes.dart';
import 'package:finplan360_frontend/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:finplan360_frontend/pages/register_page.dart';
import 'package:flutter/services.dart';

class SalaryPage extends StatefulWidget {
  final String username;
  const SalaryPage({
    super.key,
    required this.username,
  });

  @override
  State<SalaryPage> createState() => _SalaryPageState(username);
}

class _SalaryPageState extends State<SalaryPage> {
  final String username;
  _SalaryPageState(this.username);

  // text editing controllers
  final TextEditingController _salaryController = TextEditingController();

  bool _isloading = false;

  Future<String> _logoutuser() async {
    try {
      var response = await http.post(Uri.parse("http://$ip/api/logout"),
          body: {'username': widget.username});

      var result = jsonDecode(response.body);
      print(result['response']);

      if (result['response'] == 'logged out') {
        //route to login page
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => LoginPage(
                      isFromAuthPage: false,
                      isFromSalaryPage: true,
                    )),
            (route) => false);
      }
    } catch (e) {
      print("Error is $e ");
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinPlan360'),
        // color according to the theme
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () async {
              _logoutuser();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
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
                  Icons.account_balance_wallet,
                  size: 100,
                ),
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  'Enter your monthly salary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _salaryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Salary',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                MyButton(
                  onTap: () {
                    // try {
                    // var response = await http
                    //     .post(Uri.parse("http://$ip/api/salary"), body: {
                    //   'username': widget.username,
                    //   'salary': _salaryController.text,
                    // });

                    // var result = jsonDecode(response.body);
                    // print(result['response']);

                    // if (result['response'] == 'salary added') {
                    Navigator.pushNamedAndRemoveUntil(
                        context, homeRoute, (route) => false,
                        arguments: widget.username);
                    // }
                    // } catch (e) {
                    // print("Error is $e ");
                    // }
                  },
                  isloading: _isloading,
                  text: 'Next',
                ),
                const SizedBox(
                  height: 25,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     const Text(
                //       'Already entered salary?',
                //       style: TextStyle(
                //         fontSize: 15,
                //       ),
                //     ),
                //     MyButton(
                //       onTap: () {},
                //       text: "Next",
                //       isloading: _isloading,
                //     )
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
