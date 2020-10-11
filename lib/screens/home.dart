import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xkcd/api/xkcd.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Comic> latestComic;

  @override
  void initState() {
    super.initState();
    latestComic = fetchLatestComic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Image.network("https://xkcd.com/s/0b7742.png"),
                      ),
                      Expanded(
                        child: Text(
                          'A webcomic of romance, sarcasm, math, and language.'
                              .toUpperCase(),
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16.0),
                child: FutureBuilder<Comic>(
                  future: latestComic,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.network(snapshot.data.img);
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    // By default, show a loading spinner.
                    return CircularProgressIndicator();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
