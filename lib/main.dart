import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:translator/translator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExcuseApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ExcuseApp Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final translator = GoogleTranslator();
  List<Map> _excuses = [];

  String _translatedText = "";

  Future<void> _fetchData() async {

    _translatedText = "";
    _excuses = [];
    setState(() {});

    final answer = await get(Uri(
      host: "excuser.herokuapp.com",
      scheme: "https",
      pathSegments: ["v1", "excuse"],
    ));

    _excuses = (jsonDecode(answer.body) as List).cast();

    setState(() {});
  }

  @override
  void initState() {
    _fetchData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: _excuses.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
      : ListView(
        children: <Widget>[
          for (final excuse in _excuses)
            Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("category: ${excuse['category']}"),
                          Text(
                              excuse['excuse'],
                              style: Theme.of(context).textTheme.headline6
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if(_translatedText.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                          _translatedText,
                          style: Theme.of(context).textTheme.headline6
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(_excuses.isNotEmpty){
            final _excuse = _excuses.first;
            translator.translate(_excuse['excuse'], to: 'tr').then((_translate){
              _translatedText = _translate.text;
              setState(() {});
            });
          }
        },
        tooltip: 'Translate',
        child: const Icon(Icons.translate),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
