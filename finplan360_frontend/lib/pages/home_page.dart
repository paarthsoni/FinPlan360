import 'package:finplan360_frontend/components/my_button.dart';
import 'package:finplan360_frontend/constants/ip.dart';
import 'package:finplan360_frontend/constants/routes.dart';
import 'package:finplan360_frontend/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:finplan360_frontend/pages/register_page.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // text editing controllers

  bool _isloading = false;

  int _selectedIndex = 0;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _readMessages();
  }

  Future<void> _checkPermission() async {
    final permissionStatus = await Permission.sms.status;
    setState(() {
      _permissionStatus = permissionStatus;
    });
  }

  Future<void> _requestPermission() async {
    final permissionStatus = await Permission.sms.request();
    setState(() {
      _permissionStatus = permissionStatus;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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

  Future<void> _readMessages() async {
    if (_permissionStatus != PermissionStatus.granted) {
      await _requestPermission();
    }

    final messages = await SmsQuery().getAllSms;

    List<SmsMessage> filteredMessagesdebit = messages
        .where((message) =>
            message.body!.contains('debited from a/c') ||
            message.body!.contains('Sent INR'))
        .toList();

    for (var message in filteredMessagesdebit) {
      // print('Sender: ${message.address}   Message: ${message.body}');

      String? messageBody = message.body;

      RegExp regexamount = RegExp(r'(?:Rs|INR)\s*(\d+(?:\.\d{2})?)');

      RegExpMatch? matchamount = regexamount.firstMatch(messageBody!);

      // RegExp regexdate = RegExp(
      //     r"\b(0?[1-9]|[12][0-9]|3[01])([-/])(0?[1-9]|1[012])\2(\d{2}|\d{4})\b|\b(0?[1-9]|[12][0-9]|3[01])(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)(\d{2})\b");

      // RegExpMatch? matchdate = regexdate.firstMatch(messageBody);

      String startWord = "on ";
      String endWord = " t";
      String desiredText = "";
      int startIndex = messageBody.indexOf(startWord);
      if (startIndex != -1) {
        startIndex += startWord.length;
        int endIndex = messageBody.indexOf(endWord, startIndex);
        if (endIndex != -1) {
          desiredText = messageBody.substring(startIndex, endIndex).trim();
        }
      }

      String startWord1 = "to ";
      String endWord1 = ".";
      String desiredText1 = "";
      int startIndex1 = messageBody.indexOf(startWord1);
      if (startIndex1 != -1) {
        startIndex1 += startWord1.length;
        int endIndex1 = messageBody.indexOf(endWord1, startIndex1);
        if (endIndex1 != -1) {
          desiredText1 = messageBody.substring(startIndex1, endIndex1).trim();
        }
      }

      if (matchamount != null) {
        String? debitedAmount = matchamount.group(1);

        print('Debited amount: $debitedAmount');
        print('Date on which amount Debited : ' + desiredText);
        print('Vpa: ' + desiredText1);
      } else {
        print('No debited amount found in message.');
      }
    }

    // for (var message in messages) {
    //   var response = await http.post(
    //     Uri.parse("http://$ip/api/messages"),
    //     body: {
    //       'from': message.address,
    //       'body': message.body,
    //       'date': message.date.toString(),
    //     },
    //   );
    //   print(response.body);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinPlan360'),
        backgroundColor: Colors.black,
        actions: [
          // IconButton(
          //   onPressed: () async {
          //     _readMessages();
          //   },
          //   icon: const Icon(Icons.message),
          // ),
          IconButton(
            onPressed: () async {
              _logoutuser();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            // First item content
            Center(
              child: Text('Pie Chart Content'),
            ),
            // Second item content
            Center(
              child: Text('Bar Chart Content'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Pie Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Bar Chart',
          ),
        ],
      ),
    );
  }
}
