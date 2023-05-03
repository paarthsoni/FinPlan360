import 'package:finplan360_frontend/constants/globals.dart';
import 'package:finplan360_frontend/constants/ip.dart';
import 'package:finplan360_frontend/constants/routes.dart';
import 'package:finplan360_frontend/pages/login_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:finplan360_frontend/pages/register_page.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyNavigationDrawer extends StatefulWidget {
  final String username;
  const MyNavigationDrawer({Key? key, required this.username})
      : super(key: key);

  @override
  State<MyNavigationDrawer> createState() => _MyNavigationDrawerState(username);
}

class _MyNavigationDrawerState extends State<MyNavigationDrawer> {
  final String username;
  _MyNavigationDrawerState(this.username);

  Future<String> _logoutuser() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username') ?? 'null';
    try {
      var response = await http.post(Uri.parse("http://$ip/api/logout"),
          body: {'username': username});

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

  // get net savings
  Future<String> _getNetSavings() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username') ?? 'null';
    try {
      var response = await http.get(
        Uri.parse("http://$ip/api/getnetsavings/$username"),
      );

      var result = jsonDecode(response.body);
      result['response'] = result['response'].toStringAsFixed(2);
      // print(result['response']);
      return result['response'];
    } catch (e) {
      print("Error is $e ");
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Center(
              child: Text(
                'Hello! $username',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: FutureBuilder(
              future: _getNetSavings(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data);
                  return Text(
                    'Net Savings: ${snapshot.data}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  );
                } else {
                  return Text(
                    'Net Savings: 0',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  );
                }
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              _logoutuser();
            },
          ),
        ],
      ),
    );
  }
}
