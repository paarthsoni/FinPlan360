import 'package:finplan360_frontend/constants/ip.dart';
import 'package:finplan360_frontend/constants/routes.dart';
import 'package:finplan360_frontend/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:finplan360_frontend/pages/register_page.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({
    super.key,
    required this.username,
  });

  @override
  State<HomePage> createState() => _HomePageState(username);
}

class _HomePageState extends State<HomePage> {
  final String username;
  _HomePageState(this.username);

  Future<String> _logoutuser() async {
    try {
      var response = await http.post(Uri.parse("http://$paarthip/api/logout"),
          body: {'username': widget.username});

      var result = jsonDecode(response.body);
      print(result['response']);

      if (result['response'] == 'logged out') {
        //route to login page
        Navigator.pushNamedAndRemoveUntil(
            context, loginRoute, (route) => false);
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
        actions: [
          IconButton(
            onPressed: () async {
              _logoutuser();
            },
            // () {
            //   // logout
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => LoginPage(),
            //     ),
            //   );
            // },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Text('Home Page Welcome $username'),
      ),
    );
  }
}
