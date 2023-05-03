import 'package:finplan360_frontend/constants/ip.dart';
import 'package:finplan360_frontend/constants/routes.dart';
import 'package:finplan360_frontend/pages/login_page.dart';
import 'package:finplan360_frontend/pages/profile_page.dart';
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
  Stream<List<Map<String, dynamic>>>? _stream;

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
    // _getrecommendations();
    _getUserSalary();
    // _getuncategorizedmessages();\
    _selectedCategories = {};
    _futureUncategorizedMessages = _getuncategorizedmessages();
    _stream = Stream.periodic(Duration(seconds: 10), (_) async {
      _readMessages();
      _futureUncategorizedMessages = _getuncategorizedmessages();
      return await _getcategorizedmessages();
    }).asyncMap((event) async => await event);
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
        // print('id: ${message.id}');

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

          // print('Debited amount: $debitedAmount');
          // print('Date on which amount Debited : ' + desiredText);
          // print('Vpa: ' + desiredText1);
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
        // print(response.body);
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

  int salary = 0;

  Future<int> _getUserSalary() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username') ?? 'null';
    try {
      var response =
          await http.get(Uri.parse("http://$ip/api/getsalary/$username"));
      if (response.statusCode == 200) {
        salary = json.decode(response.body);
        prefs.setInt('salary', salary);
        // print(salary);
        return salary;
      } else {
        throw Exception('Failed to load user salary');
      }
    } catch (e) {
      print("Error is $e");
    }
    return 0;
  }

  Future<void> _insertnetsavings(double savings) async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username') ?? 'null';
    try {
      var response =
          await http.post(Uri.parse("http://$ip/api/insertnetsavings"), body: {
        'username': username,
        'savings': savings.toString(),
      });
      var result = json.decode(response.body);
      if (result['response'] == 'updated') {
        print('updated');
      } else {
        print('no change');
      }
    } catch (e) {
      print("Error is $e");
    }
  }

  List<dynamic> recommendationList = [];
  String firstImageUrl =
      "https://pixabay.com/api/?key=25481727-f7a17116390afbe2ad4a0ead5&q=error&image_type=photo";

  Future<List<Map<String, dynamic>>> _getrecommendations() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username') ?? 'null';

    // final url = Uri.parse(
    //     'https://pixabay.com/api/?key=25481727-f7a17116390afbe2ad4a0ead5&q=yellow+flowers&image_type=photo');
    // final responseimg = await http.get(url);

    // try {
    //   if (responseimg.statusCode == 200) {
    //     final jsonBody = json.decode(responseimg.body);
    //     final firstHit = jsonBody['hits'][0];
    //     firstImageUrl = firstHit['webformatURL'];
    //     print(firstImageUrl);
    //   } else {
    //     throw Exception('Failed to load Pixabay API');
    //   }
    // } catch (e) {
    //   print('Error loading Pixabay API: $e');
    // }

    try {
      var response =
          await http.get(Uri.parse("http://$ip/api/recommendations/$username"));
      if (response.statusCode == 200) {
        recommendationList = json.decode(response.body) as List;
        print(recommendationList);
        // recommendationList.insert(0, {'imageURL': firstImageUrl});
        // return jsonList.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load recommendations');
      }
    } catch (e) {
      print('Error is $e');
    }
    return [];
  }

  Future<String> _imageofplace(String recomPlace) async {
    final url = Uri.parse(
        'https://pixabay.com/api/?key=25481727-f7a17116390afbe2ad4a0ead5&q=$recomPlace&image_type=photo');
    final responseimg = await http.get(url);

    try {
      if (responseimg.statusCode == 200) {
        final jsonBody = json.decode(responseimg.body);
        final firstHit = jsonBody['hits'][0];
        firstImageUrl = firstHit['webformatURL'];
        print(firstImageUrl);
      } else {
        throw Exception('Failed to load Pixabay API');
      }
    } catch (e) {
      print('Error loading Pixabay API: $e');
    }

    return firstImageUrl;
  }

  // final categoryAmounts = Map<String, double>();

  Map<String, double> categoryAmounts = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('FinPlan360'),
        backgroundColor: Colors.black,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),

          // IconButton(
          //   onPressed: () async {
          //     _logoutuser();
          //   },
          //   icon: const Icon(Icons.logout),
          // ),
        ],
      ),
      endDrawer: MyNavigationDrawer(
        username: username,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            // First item content
            Center(
              child: Column(
                children: [
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _stream,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasData) {
                        // call shared prefernce named salary
                        Future<int> userSalary = _getUserSalary();
                        // print(userSalary);
                        final categorizedMessages = snapshot.data;
                        // final categoryAmounts = Map<String, double>();
                        double spent = 0.0;

                        categoryAmounts.clear();

                        categorizedMessages?.forEach(
                          (message) {
                            final category = message['category'];
                            final amount = message['amount'];

                            if (categoryAmounts.containsKey(category)) {
                              final oldAmount = categoryAmounts[category]!;
                              final newAmount = oldAmount + amount;
                              categoryAmounts[category] = newAmount;
                              spent += amount;
                            } else {
                              categoryAmounts[category] = amount;
                              spent += amount;
                            }
                          },
                        );

                        // categoryAmounts.forEach((category, amount) {
                        //   double percentage = 0;
                        //   if (salary > 0) {
                        //     percentage = (amount / salary) * 100;
                        //     percentage =
                        //         double.parse(percentage.toStringAsFixed(2));
                        //   }
                        //   spent += percentage;
                        //   categoryAmounts[category] = percentage;
                        // });
                        spent = double.parse(spent.toStringAsFixed(2));

                        // print(categoryAmounts);
                        categoryAmounts['Savings'] =
                            (salary - spent).ceilToDouble();

                        DateTime lastDayOfMonth = DateTime(
                            DateTime.now().year, DateTime.now().month + 1, 0);
                        String formattedDate1 =
                            DateFormat('yyyy-MM-dd').format(lastDayOfMonth);
                        DateTime now = DateTime.now();
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(now);
                        // print(formattedDate1);
                        // print(formattedDate);
                        if (formattedDate == formattedDate1) {
                          var netsavings =
                              (categoryAmounts['Savings'] ?? 0) * salary / 100;
                          // print(netsavings.runtimeType);
                          _insertnetsavings(netsavings);
                        }
                        // else {
                        //   print('false');
                        // }

                        // print(categoryAmounts);

                        final List<PieChartSectionData> pieChartSections =
                            categoryAmounts.entries
                                .map((e) => PieChartSectionData(
                                      value: e.value,
                                      title: e.key +
                                          '\n' +
                                          (e.value / salary * 100)
                                              .toStringAsFixed(1) +
                                          '%',
                                      color: getColor(e.key),
                                      radius: 150,
                                      titleStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ))
                                .toList();

                        return Column(
                          children: [
                            Container(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: PieChart(
                                  PieChartData(
                                    sections: pieChartSections,
                                    centerSpaceRadius: 0,
                                    borderData: FlBorderData(show: false),
                                    sectionsSpace: 0,
                                    // pieTouchData: PieTouchData(
                                    //   touchCallback: (pieTouchResponse) => _onPieTouch(
                                    //       context, pieTouchResponse, categorizedMessages),
                                    // ),
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible:
                                  salary != 0 && categoryAmounts.isNotEmpty,
                              child: Column(
                                children: [
                                  const Text(
                                    'Your Monthly Salary',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '₹ ' + salary.toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Your Monthly Expenses',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  // salary - categoryAmounts['Savings']! * salary / 100
                                  Text(
                                    '₹ ${(salary - (categoryAmounts['Savings'] ?? 0)).toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      } else {
                        // return circular progress indicator in the center of the screen
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                  // const Text(
                  //   'Your Monthly Salary',
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 5),
                  // Text('₹ ' + salary.toString(),
                  //     style: const TextStyle(fontSize: 16)),

                  // const SizedBox(height: 10),
                  // const Text(
                  //   'Your Monthly Expenses',
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 5),
                  // // salary - categoryAmounts['Savings']! * salary / 100
                  // Text(
                  //   '₹ ${(salary - (categoryAmounts['Savings'] ?? 0) * salary / 100).toStringAsFixed(0)}',
                  //   style: const TextStyle(fontSize: 16),
                  // ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: categoryAmounts.length,
                      itemBuilder: (context, index) {
                        final category = categoryAmounts.keys.elementAt(index);
                        final amount = categoryAmounts[category]!;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: ListTile(
                            title: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Text(
                              '₹${(amount).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Second item content
            Center(
                child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getrecommendations(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: recommendationList.length,
                    itemBuilder: (context, index) {
                      final recommendations = recommendationList[index];
                      return Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.7),
                              spreadRadius: 2,
                              blurRadius: 3,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                leading: Icon(Icons.airplane_ticket),
                                title: Text('${recommendations['Place']}'),
                                subtitle: Text(
                                  '\nAmount: ${recommendations['amount']}\n\nDuration: ${recommendations['duration']} Nights',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Container(
                                width: 100.0,
                                child: FutureBuilder<String>(
                                  future:
                                      _imageofplace(recommendations['Place']),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      return ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text(
                                          'Error loading image: ${snapshot.error}');
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            )),
            Center(
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
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.7),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.currency_rupee),
                                  title: Text('${message['amount']}'),
                                  subtitle: Text(
                                      '\nDebit Date: ${message['date']}\n\nUPI ID: ${message['receiver']}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
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
                                          if (_selectedCategories[index] !=
                                              null) {
                                            _categorizemessages(message['id'],
                                                _selectedCategories[index]!);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'No Category Selected!!'),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
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

Color getColor(String category) {
  switch (category) {
    case 'Food':
      return Colors.red;
    case 'Travel':
      return Colors.blue;
    case 'Shopping':
      return Colors.yellow;
    case 'Entertainment':
      return Colors.green;
    case 'Others':
      return Colors.purple;
  }
  return Colors.grey.shade500;
}
