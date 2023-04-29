import 'dart:ffi';

import 'package:finplan360_frontend/components/my_button.dart';
import 'package:finplan360_frontend/constants/ip.dart';
import 'package:finplan360_frontend/constants/routes.dart';
import 'package:finplan360_frontend/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:finplan360_frontend/pages/register_page.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
  late Future<List<Map<String, dynamic>>> _futureUncategorizedMessages;
  late Map<int, String> _selectedCategories;

  final List<String> _categories = [
    'Food',
    'Travel',
    'Shopping',
    'Entertainment',
    'Others',
  ];

// _categories = _categories.toSet().toList();

  // text editing controllers

  bool _isloading = false;

  List<dynamic> _uncategorizedMessages = [];

  int _selectedIndex = 0;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _readMessages();
    // _getuncategorizedmessages();\
    _selectedCategories = {};
    _futureUncategorizedMessages = _getuncategorizedmessages();
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

  Future<void> _readMessages() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username') ?? 'null';
    if (_permissionStatus != PermissionStatus.granted) {
      await _requestPermission();
    }

    final messages = await SmsQuery().getAllSms;

    List<SmsMessage> filteredMessagesdebit = messages
        .where((message) =>
            message.body!.contains('debited from a/c') ||
            message.body!.contains('Sent INR') ||
            message.body!.contains('debited by'))
        .toList();

    for (var message in filteredMessagesdebit) {
      DateTime now = DateTime.now(); // Get the current date and time
      DateTime startOfMonth = DateTime(
          now.year, now.month, 1); // Set the day to the 1st of the month
      String formattedDate = DateFormat('yyyy-MM-dd')
          .format(startOfMonth); // Format the date as desired

      if (message.date!.isAfter(startOfMonth)) {
        print('id: ${message.id}');

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

        String? debitedAmount = "";
        if (matchamount != null) {
          debitedAmount = matchamount.group(1);

          print('Debited amount: $debitedAmount');
          print('Date on which amount Debited : ' + desiredText);
          print('Vpa: ' + desiredText1);
        } else {
          print('No debited amount found in message.');
        }

        var response = await http.post(
          Uri.parse("http://$ip/api/messages"),
          body: {
            'username': username,
            'id': message.id.toString(),
            'amount': debitedAmount,
            'date': desiredText,
            'receiver': desiredText1,
          },
        );
        print(response.body);
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getuncategorizedmessages() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username') ?? 'null';
    try {
      var response =
          await http.get(Uri.parse("http://$ip/api/getmessages/$username"));

      // print(response.body);

      // var result = json.decode(response.body);
      // print(result);

      if (response.statusCode == 200) {
        final jsonList = json.decode(response.body) as List;
        return jsonList.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load uncategorized messages');
      }

      // print(_uncategorizedMessages);

      // final data = jsonDecode(response.body) as List<dynamic>;
      // List<dynamic> data1 = data;
      // List<int> ids = data1.map((item) => item['id'] as int).toList();
      // print(ids);
    } catch (e) {
      print('Error is $e');
    }

    return [];
  }

  Future<String> _categorizemessages(int message_id, String Category) async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username') ?? 'null';
    try {
      var response = await http
          .post(Uri.parse("http://$ip/api/categorizemessages"), body: {
        'username': username,
        'message_id': message_id.toString(),
        'category': Category
      });

      var result = jsonDecode(response.body);
      if (result['response'] == 'categorized') {
        setState(() {
          _getuncategorizedmessages();
        });
      }
    } catch (e) {
      print('Error is $e');
    }

    return "";
  }

  Future<List<Map<String, dynamic>>> _getcategorizedmessages() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username') ?? 'null';
    try {
      var response = await http
          .get(Uri.parse("http://$ip/api/getcategorizedmessages/$username"));
      if (response.statusCode == 200) {
        final jsonList = json.decode(response.body) as List;
        // print(jsonList);
        return jsonList.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load uncategorized messages');
      }
    } catch (e) {
      print("Error is $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinPlan360'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () async {
              _logoutuser();
              _getcategorizedmessages();
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
              child: Text('Table Content'),
            ),
            Center(
              // child: ListView.builder(
              //   itemCount: _uncategorizedMessages.length,
              //   itemBuilder: (BuildContext context, int index) {
              //     final message = _uncategorizedMessages[index];
              //     return ListTile(
              //       title: Text('Message ID: ${message['id']}'),
              //       subtitle: Text(
              //           'Amount: ${message['amount']}, Date: ${message['date']}'),
              //     );
              //   },
              // ),

              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getuncategorizedmessages(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final uncategorizedMessages = snapshot.data!;
                    if (snapshot.data!.length == 0) {
                      return Text('No Uncategorized Messages found');
                    } else {
                      return ListView.builder(
                        itemCount: uncategorizedMessages.length,
                        itemBuilder: (context, index) {
                          final message = uncategorizedMessages[index];
                          return Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color.fromARGB(255, 221, 7, 7),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.currency_rupee),
                                  title: Text('${message['amount']}'),
                                  subtitle: Text(
                                      '\nDebit Date: ${message['date']}\n\nUPI ID: ${message['receiver']}'),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    DropdownButton<String>(
                                      value: _selectedCategories[index],
                                      hint: Text('Select a category'),
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedCategories[index] =
                                              newValue!;
                                        });
                                      },
                                      items: _categories.map((category) {
                                        return DropdownMenuItem(
                                          value: category,
                                          child: Text(category),
                                        );
                                      }).toList(),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.done),
                                      onPressed: () {
                                        _categorizemessages(message['id'],
                                            _selectedCategories[index]!);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
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
            icon: Icon(Icons.recommend_rounded),
            label: 'Recommendation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorize',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.account_circle),
          //   label: 'Account',
          // ),
        ],
      ),
    );
  }
}
