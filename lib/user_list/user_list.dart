import 'dart:convert';
import 'package:demo/user_detail/github_user.dart';
import 'package:demo/user_detail/user_details.dart';
import 'package:demo/user_list/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}


class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: const MyHomePage(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void toggleThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<User> users = [];
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      setState(() {
        isLoading = true;
      });
      UserRepository repository = UserRepository(httpClient: http.Client());
      repository.fetchUsers().then((newUsers) {
        setState(() {
          users = newUsers.map((json) => User.fromJson(json)).toList();
          isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to load users'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GitHub Users"),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark // Use Theme.of(context).brightness
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => MyApp.of(context)?.toggleThemeMode(),
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: users.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == users.length && isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListTile(
            leading: Hero(
              tag: users[index].login,
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(users[index].avatarUrl),
              ),
            ),
            title: Text(users[index].login),
            subtitle: Text(users[index].htmlUrl),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailsPage(user: users[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}