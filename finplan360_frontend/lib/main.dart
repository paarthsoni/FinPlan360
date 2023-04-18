import 'package:finplan360_frontend/constants/routes.dart';
import 'package:finplan360_frontend/pages/home_page.dart';
import 'package:finplan360_frontend/pages/login_page.dart';
import 'package:finplan360_frontend/pages/register_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: LoginPage(),
      // routes: {
      //   '/login/': (context) => LoginPage(),
      //   '/register/': (context) => RegisterPage(),
      // },

      // check if username is created or not, if created then pass it to home page
      // if not created then pass it to login page
      initialRoute: loginRoute,
      routes: {
        loginRoute: (context) => LoginPage(),
        registerRoute: (context) => RegisterPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == homeRoute) {
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => HomePage(username: args),
          );
        }
      },
    ),
  );
}
