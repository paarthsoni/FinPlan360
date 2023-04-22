import 'dart:convert';
import 'package:finplan360_frontend/constants/globals.dart' as globals;
import 'package:finplan360_frontend/constants/routes.dart';
import 'package:finplan360_frontend/pages/home_page.dart';
import 'package:finplan360_frontend/pages/salary_page.dart';
import 'package:finplan360_frontend/pages/login_page.dart';
import 'package:finplan360_frontend/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:finplan360_frontend/constants/ip.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var username = prefs.getString('username') ?? 'null';
  Map<String, dynamic> myMap = {};
  print(username);
  if (username != 'null') {
    var response = await http.post(Uri.parse("http://$ip/api/is_authenticated"),
        body: {'username': username});

    print(response.body);
    myMap = json.decode(response.body);
    print(myMap['response']);
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,

      // check if username is created or not, if created then pass it to home page
      // if not created then pass it to login page

      initialRoute: loginRoute,
      routes: {
        loginRoute: (context) => LoginPage(
              isFromAuthPage: false,
              isFromSalaryPage: false,
            ),
        registerRoute: (context) => RegisterPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == salaryRoute) {
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => SalaryPage(username: args),
          );
        } else if (settings.name == homeRoute) {
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => HomePage(username: args),
          );
        }
      },
    ),
  );
}
