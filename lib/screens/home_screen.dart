import 'package:flutter/material.dart';
import 'package:flutter_html_parser/models/article.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Udemy Flutter'),
      ),
      body: FutureBuilder<List<Article>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  List<Article> _articleList = snapshot.data;
                  _articleList.sort((a, b) => a.duration.compareTo(b.duration));
                  _articleList = _articleList.reversed.toList();

                  var formatter = new DateFormat('mm:ss');

                  return Card(
                    child: ListTile(
                      title: Text(_articleList[index].title),
                      subtitle: Text(formatter
                          .format(_articleList[index].duration)
                          .toString()),
                    ),
                  );
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<List<Article>> fetchData() async {
    List<Article> result = [];
    http.Response response = await http.get(
        'https://www.udemy.com/course/learn-flutter-dart-to-build-ios-android-apps/');
    if (response.statusCode == 200) {
      Future.delayed(Duration(milliseconds: 300));
      try {
        dom.Document document = parser.parse(response.body);

        List<dom.Element> nestedList = document.body
            .getElementsByClassName('lectures-container collapse in')[0]
            .children;
        for (int i = 0; i < nestedList.length; i++) {
          if (nestedList[i].children[1].nodes.length == 5) {
            result.add(
              Article(
                title: nestedList[i]
                    .children[0]
                    .getElementsByClassName('title')
                    .first
                    .text
                    .trim(),
                duration: DateFormat('ms', 'en_US').parse(
                  nestedList[i].children[1].children[1].text.trim(),
                ),
              ),
            );
          }
        }
        return result;
      } catch (e) {
        print(e);
        return null;
      }
    } else {
      print(response.statusCode);
      return null;
    }
  }
}
