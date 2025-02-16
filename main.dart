import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ICMRNotifications(),
    );
  }
}

class ICMRNotifications extends StatefulWidget {
  @override
  _ICMRNotificationsState createState() => _ICMRNotificationsState();
}

class _ICMRNotificationsState extends State<ICMRNotifications> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final String apiUrl = "http://localhost:3000/notifications"; // Node.js API

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['success']) {
          setState(() {
            notifications =
                List<Map<String, dynamic>>.from(jsonData['notifications']);
          });
        }
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ICMR Notifications"),
        backgroundColor: Colors.blue,
      ),
      body: notifications.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ExpansionTile(
                    title: Text(
                      notifications[index]['title'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: notifications[index]['links']
                        .map<Widget>((link) => ListTile(
                              title: Text("Open Document",
                                  style: TextStyle(color: Colors.blue)),
                              trailing:
                                  Icon(Icons.open_in_new, color: Colors.blue),
                              onTap: () => _launchURL(link),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
    );
  }
}
